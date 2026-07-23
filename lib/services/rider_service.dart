import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../models/rider_notification_model.dart';
import '../models/review_model.dart';

class RiderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get stream of rider notifications
  Stream<List<RiderNotificationModel>> getNotifications(String riderId) {
    return _db
        .collection('users')
        .doc(riderId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RiderNotificationModel.fromFirestore(doc))
            .toList());
  }

  /// Update online/offline status
  Future<void> toggleOnlineStatus(String uid, bool isOnline) async {
    await _db.collection('users').doc(uid).update({'isOnline': isOnline});
  }

  /// Get available orders for riders
  Stream<List<OrderModel>> getAvailableOrders(String riderId) {
    return _db
        .collection('orders')
        .where('status', isEqualTo: OrderStatus.confirmed.name)
        .snapshots()
        .map((snapshot) {
      final orders = snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
      // Remove orders already rejected by this rider
      return orders.where((o) => o.rejectedBy == null || !o.rejectedBy!.contains(riderId)).toList();
    });
  }

  /// Reject/Decline an order request
  Future<void> rejectOrder(String orderId, String riderId) async {
    await _db.collection('orders').doc(orderId).update({
      'rejectedBy': FieldValue.arrayUnion([riderId]),
    });
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final Map<String, dynamic> data = {'status': status.name};
    if (status == OrderStatus.delivered) {
      data['deliveredAt'] = FieldValue.serverTimestamp();
    }
    await _db.collection('orders').doc(orderId).update(data);
  }

  /// Get active tasks for a rider
  Stream<List<OrderModel>> getActiveRiderOrders(String riderId) {
    return _db
        .collection('orders')
        .where('riderId', isEqualTo: riderId)
        .snapshots()
        .map((snapshot) {
      final all = snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
      return all.where((o) => 
        o.status != OrderStatus.delivered && 
        o.status != OrderStatus.cancelled && 
        o.status != OrderStatus.rejected
      ).toList();
    });
  }

  /// Get total history for a rider
  Stream<List<OrderModel>> getRiderHistory(String riderId) {
    return _db
        .collection('orders')
        .where('riderId', isEqualTo: riderId)
        .where('status', isEqualTo: OrderStatus.delivered.name)
        .snapshots()
        .map((snapshot) {
      final orders = snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
      // Sort in-memory to avoid index requirement
      orders.sort((a, b) => (b.deliveredAt ?? b.createdAt).compareTo(a.deliveredAt ?? a.createdAt));
      return orders;
    });
  }

  /// Get today's history for earnings calculation
  Stream<List<OrderModel>> getTodayRiderHistory(String riderId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    
    return _db
        .collection('orders')
        .where('riderId', isEqualTo: riderId)
        .where('status', isEqualTo: OrderStatus.delivered.name)
        .snapshots()
        .map((snapshot) {
      final orders = snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .where((o) => o.deliveredAt != null && o.deliveredAt!.isAfter(startOfDay))
          .toList();
      // Sort in-memory
      orders.sort((a, b) => b.deliveredAt!.compareTo(a.deliveredAt!));
      return orders;
    });
  }

  /// Get stream of reviews for a specific rider
  Stream<List<ReviewModel>> getRiderReviews(String riderId) {
    return _db
        .collection('rider_reviews')
        .where('riderId', isEqualTo: riderId)
        .snapshots()
        .map((snapshot) {
          final reviews = snapshot.docs.map((doc) => ReviewModel.fromFirestore(doc)).toList();
          // Sort in-memory by date descending
          reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return reviews;
        });
  }

  /// Mark notification as read
  Future<void> markAsRead(String userId, String notificationId) async {
    await _db.collection('users').doc(userId).collection('notifications').doc(notificationId).update({'isRead': true});
  }

  /// Delete notification
  Future<void> deleteNotification(String userId, String notificationId) async {
    await _db.collection('users').doc(userId).collection('notifications').doc(notificationId).delete();
  }

  /// Upload document
  Future<void> uploadDocument(String uid, String type, String url) async {
    await _db.collection('users').doc(uid).update({
      'documents.$type': 'uploaded',
      'documentUrls.$type': url,
    });
  }

  /// Update Rider Profile
  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }
}
