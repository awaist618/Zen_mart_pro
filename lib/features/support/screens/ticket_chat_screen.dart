import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../core/providers.dart';
import '../../../models/user_model.dart';
import '../../../models/support_ticket_model.dart';
import '../../../services/support_service.dart';

class TicketChatScreen extends ConsumerStatefulWidget {
  final String ticketId;
  const TicketChatScreen({super.key, required this.ticketId});

  @override
  ConsumerState<TicketChatScreen> createState() => _TicketChatScreenState();
}

class _TicketChatScreenState extends ConsumerState<TicketChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(userModelProvider).asData?.value;
    if (user == null) return;

    _messageController.clear();

    final message = SupportMessageModel(
      id: '',
      senderId: user.uid,
      senderName: user.name,
      senderRole: user.role.name,
      message: text,
      timestamp: DateTime.now(),
    );

    await ref.read(supportServiceProvider).sendMessage(widget.ticketId, message);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userModelProvider).asData?.value;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('support_tickets').doc(widget.ticketId).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Text('Support Chat');
            }
            final ticket = SupportTicketModel.fromFirestore(snapshot.data!);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ticket.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('#${ticket.id.substring(0, 8).toUpperCase()} • ${ticket.status.name.toUpperCase()}', 
                  style: TextStyle(fontSize: 10, color: _getStatusColor(ticket.status))),
              ],
            );
          }
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
        actions: [
          // If admin, show status update options
          if (user.role == UserRole.superAdmin)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: PopupMenuButton<TicketStatus>(
                onSelected: (status) {
                  ref.read(supportServiceProvider).updateTicketStatus(widget.ticketId, status);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Status updated to ${status.name.toUpperCase()}')),
                  );
                },
                offset: const Offset(0, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                itemBuilder: (context) => TicketStatus.values.map((s) => PopupMenuItem(
                  value: s, 
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(color: _getStatusColor(s), shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 12),
                      Text(s.name.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )).toList(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 18),
                      const SizedBox(width: 4),
                      const Text('STATUS', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Admin Status Bar
          if (user.role == UserRole.superAdmin)
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('support_tickets').doc(widget.ticketId).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) return const SizedBox.shrink();
                final ticket = SupportTicketModel.fromFirestore(snapshot.data!);
                if (ticket.status == TicketStatus.resolved || ticket.status == TicketStatus.closed) return const SizedBox.shrink();
                
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  color: Colors.green.withOpacity(0.05),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 20),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Issue resolved? Mark it as solved to notify the user.',
                          style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w500),
                        ),
                      ),
                      TextButton(
                        onPressed: () => ref.read(supportServiceProvider).updateTicketStatus(widget.ticketId, TicketStatus.resolved),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text('Resolve Now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              }
            ),
          Expanded(
            child: StreamBuilder<List<SupportMessageModel>>(
              stream: ref.watch(supportServiceProvider).getTicketMessages(widget.ticketId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data ?? [];
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == user.uid;
                    return _ChatBubble(message: message, isMe: isMe);
                  },
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: AppColors.primary,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.open: return Colors.blue;
      case TicketStatus.inProgress: return Colors.orange;
      case TicketStatus.resolved: return Colors.green;
      case TicketStatus.closed: return Colors.grey;
      default: return Colors.blue;
    }
  }
}

class _ChatBubble extends StatelessWidget {
  final SupportMessageModel message;
  final bool isMe;
  const _ChatBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 20),
          ),
          boxShadow: [if (!isMe) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(message.senderName, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 4),
            Text(
              message.message,
              style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('hh:mm a').format(message.timestamp),
              style: TextStyle(color: isMe ? Colors.white70 : Colors.grey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
