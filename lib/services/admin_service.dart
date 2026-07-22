import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get stream of admin notifications
  Stream<List<NotificationModel>> getNotifications() {
    return _db
        .collection('admin_notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _db
        .collection('admin_notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    await _db.collection('admin_notifications').doc(notificationId).delete();
  }

  /// Get revenue stats based on time range
  Stream<double> getRevenueStream({required DateTime start, required DateTime end}) {
    return _db
        .collection('orders')
        .where('status', isEqualTo: 'delivered')
        .where('deliveredAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('deliveredAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .snapshots()
        .map((snapshot) {
      double total = 0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['totalAmount'] ?? 0.0).toDouble();
      }
      return total;
    });
  }

  /// Create a notification (Helper for testing and system triggers)
  Future<void> createNotification({
    required String title,
    required String message,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) async {
    await _db.collection('admin_notifications').add({
      'title': title,
      'message': message,
      'type': type.name,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'data': data,
    });
  }
}
