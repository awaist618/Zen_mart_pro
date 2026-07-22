import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class RiderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Toggle Online/Offline status
  Future<void> toggleOnlineStatus(String uid, bool status) async {
    await _db.collection('users').doc(uid).update({'isOnline': status});
  }

  /// Get stream of available orders (Confirmed by vendor but no rider assigned)
  Stream<List<OrderModel>> getAvailableOrders() {
    return _db
        .collection('orders')
        .where('status', isEqualTo: OrderStatus.confirmed.name)
        .where('riderId', isNull: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList());
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

  /// Get delivery history for a rider
  Stream<List<OrderModel>> getRiderHistory(String riderId) {
    return _db
        .collection('orders')
        .where('riderId', isEqualTo: riderId)
        .where('status', isEqualTo: OrderStatus.delivered.name)
        .orderBy('deliveredAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList());
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
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList());
  }
}
