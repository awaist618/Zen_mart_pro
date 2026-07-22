import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../models/rider_notification_model.dart';

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

  /// Mark notification as read
  Future<void> markAsRead(String riderId, String notificationId) async {
    await _db
        .collection('users')
        .doc(riderId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  /// Delete notification
  Future<void> deleteNotification(String riderId, String notificationId) async {
    await _db
        .collection('users')
        .doc(riderId)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  /// Toggle Online/Offline status
  Future<void> toggleOnlineStatus(String uid, bool status) async {
    await _db.collection('users').doc(uid).update({'isOnline': status});
  }

  /// Get stream of available orders (Confirmed by vendor but no rider assigned)
  /// Excludes orders rejected by the current rider
  Stream<List<OrderModel>> getAvailableOrders(String riderId) {
    return _db
        .collection('orders')
        .where('status', isEqualTo: OrderStatus.confirmed.name)
        .where('riderId', isNull: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .where((order) {
            // Check if rider has already rejected this order
            final rejectedBy = order.rejectedBy ?? [];
            return !rejectedBy.contains(riderId);
          })
          .toList();
    });
  }

  /// Get stream of active orders for a specific rider
  Stream<List<OrderModel>> getActiveRiderOrders(String riderId) {
    return _db
        .collection('orders')
        .where('riderId', isEqualTo: riderId)
        .where('status', whereIn: [
          OrderStatus.accepted.name,
          OrderStatus.reachedVendor.name,
          OrderStatus.pickedUp.name,
          OrderStatus.outForDelivery.name,
        ])
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList());
  }

  /// Accept an order
  Future<void> acceptOrder(String orderId, String riderId) async {
    await _db.collection('orders').doc(orderId).update({
      'riderId': riderId,
      'status': OrderStatus.accepted.name,
    });
  }

  /// Reject an order (Hide from current rider)
  Future<void> rejectOrder(String orderId, String riderId) async {
    await _db.collection('orders').doc(orderId).update({
      'rejectedBy': FieldValue.arrayUnion([riderId]),
    });
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final orderDoc = await _db.collection('orders').doc(orderId).get();
    final order = OrderModel.fromFirestore(orderDoc);

    Map<String, dynamic> updateData = {'status': status.name};
    
    if (status == OrderStatus.delivered) {
      updateData['deliveredAt'] = FieldValue.serverTimestamp();
      
      // Update Rider Stats
      if (order.riderId != null) {
        await _db.collection('users').doc(order.riderId).update({
          'totalDeliveries': FieldValue.increment(1),
          'totalEarnings': FieldValue.increment(order.deliveryFee),
        });
      }
    }
    
    await _db.collection('orders').doc(orderId).update(updateData);
  }

  /// Get delivery history for a rider (Delivered and Cancelled)
  Stream<List<OrderModel>> getRiderHistory(String riderId) {
    return _db
        .collection('orders')
        .where('riderId', isEqualTo: riderId)
        .where('status', whereIn: [
          OrderStatus.delivered.name,
          OrderStatus.cancelled.name,
          OrderStatus.rejected.name,
        ])
        .snapshots()
        .map((snapshot) {
          final orders = snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
          // Sort manually because orderBy with whereIn on different fields might require more indexes
          orders.sort((a, b) => (b.deliveredAt ?? b.createdAt).compareTo(a.deliveredAt ?? a.createdAt));
          return orders;
        });
  }

  /// Get today's delivery history for a rider
  Stream<List<OrderModel>> getTodayRiderHistory(String riderId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    
    return _db
        .collection('orders')
        .where('riderId', isEqualTo: riderId)
        .where('status', isEqualTo: OrderStatus.delivered.name)
        .where('deliveredAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .orderBy('deliveredAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList());
  }
}
