import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum ActivityType {
  vendorRegistration,
  riderRegistration,
  newOrder,
  withdrawalRequest,
  systemAlert,
  supportTicket,
  general
}

class ActivityModel {
  final String id;
  final String title;
  final String subtitle;
  final ActivityType type;
  final DateTime timestamp;
  final Color color;
  final IconData icon;

  ActivityModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.timestamp,
    required this.color,
    required this.icon,
  });

  factory ActivityModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ActivityModel(
      id: doc.id,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      type: _parseType(data['type']),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      color: Color(data['color'] ?? 0xFF6366F1),
      icon: IconData(data['icon'] ?? 57672, fontFamily: 'MaterialIcons'),
    );
  }

  static ActivityType _parseType(String? type) {
    return ActivityType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => ActivityType.general,
    );
  }
}
