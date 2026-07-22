import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/support_ticket_model.dart';
import '../models/notification_model.dart';
import '../models/activity_model.dart';
import 'package:flutter/material.dart';

class SupportService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Create a new support ticket
  Future<String> createTicket(SupportTicketModel ticket) async {
    final docRef = await _db.collection('support_tickets').add(ticket.toMap());
    
    // Create admin notification
    await _db.collection('admin_notifications').add({
      'title': 'New Support Ticket',
      'message': '${ticket.userName} (${ticket.userRole.name}) created a new ticket: ${ticket.title}',
      'type': NotificationType.supportTicket.name,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'data': {
        'ticketId': docRef.id,
        'userId': ticket.userId,
      },
    });

    // Also add to activity log
    await _db.collection('activity_logs').add({
      'title': 'Support Ticket Created',
      'subtitle': '${ticket.userName} created ticket #${docRef.id.substring(0, 5)}',
      'type': ActivityType.supportTicket.name,
      'timestamp': FieldValue.serverTimestamp(),
      'userId': ticket.userId,
      'color': Colors.blue.value,
      'icon': Icons.support_agent_rounded.codePoint,
    });

    return docRef.id;
  }

  /// Get stream of tickets for a specific user
  Stream<List<SupportTicketModel>> getUserTickets(String userId) {
    return _db
        .collection('support_tickets')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final tickets = snapshot.docs
            .map((doc) => SupportTicketModel.fromFirestore(doc))
            .toList();
          // Manual sorting to avoid index requirement for now
          tickets.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          return tickets;
        });
  }

  /// Get stream of all tickets for Admin
  Stream<List<SupportTicketModel>> getAllTickets() {
    return _db
        .collection('support_tickets')
        .snapshots()
        .map((snapshot) {
          final tickets = snapshot.docs
            .map((doc) => SupportTicketModel.fromFirestore(doc))
            .toList();
          tickets.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          return tickets;
        });
  }

  /// Update ticket status
  Future<void> updateTicketStatus(String ticketId, TicketStatus status) async {
    await _db.collection('support_tickets').doc(ticketId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Add a message to a ticket
  Future<void> sendMessage(String ticketId, SupportMessageModel message) async {
    await _db
        .collection('support_tickets')
        .doc(ticketId)
        .collection('messages')
        .add(message.toMap());
    
    // Update the ticket's updatedAt timestamp
    await _db.collection('support_tickets').doc(ticketId).update({
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get real-time stream of messages for a ticket
  Stream<List<SupportMessageModel>> getTicketMessages(String ticketId) {
    return _db
        .collection('support_tickets')
        .doc(ticketId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SupportMessageModel.fromFirestore(doc))
            .toList());
  }

  /// Mark ticket messages as read (reset unread count)
  Future<void> markAsRead(String ticketId) async {
    await _db.collection('support_tickets').doc(ticketId).update({
      'unreadCount': 0,
    });
  }
}
