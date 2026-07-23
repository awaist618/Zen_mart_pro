import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import '../models/shop_model.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';
import '../models/approval_model.dart';
import '../models/payout_model.dart';
import '../models/activity_model.dart';
import '../models/category_model.dart';

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Manage Platform Categories
  Stream<List<CategoryModel>> getCategories() {
    return _db.collection('categories').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList());
  }

  Future<void> addCategory(CategoryModel category) async {
    await _db.collection('categories').add(category.toMap());
  }

  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    await _db.collection('categories').doc(id).update(data);
  }

  Future<void> deleteCategory(String id) async {
    await _db.collection('categories').doc(id).delete();
  }

  /// Get stream of all activity logs
  Stream<List<ActivityModel>> getActivityLogs({DateTime? start}) {
    Query query = _db.collection('activity_logs').orderBy('timestamp', descending: true);
    if (start != null) {
      query = query.where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(start));
    }
    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => ActivityModel.fromFirestore(doc)).toList());
  }

  /// Get stream of all pending approvals
  Stream<List<ApprovalModel>> getPendingApprovals() {
    return _db
        .collection('approvals')
        .where('status', isEqualTo: ApprovalStatus.pending.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ApprovalModel.fromFirestore(doc))
            .toList());
  }

  /// Update approval status
  Future<void> updateApprovalStatus(String id, ApprovalStatus status) async {
    await _db.collection('approvals').doc(id).update({'status': status.name});
  }

  /// Get stream of all payout requests
  Stream<List<PayoutModel>> getPayoutRequests() {
    return _db
        .collection('payouts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PayoutModel.fromFirestore(doc))
            .toList());
  }

  /// Update payout status
  Future<void> updatePayoutStatus(String id, PayoutStatus status, {String? txId, String? method}) async {
    Map<String, dynamic> updateData = {'status': status.name};
    if (status == PayoutStatus.paid) {
      updateData['processedAt'] = FieldValue.serverTimestamp();
      updateData['transactionId'] = txId;
      updateData['paymentMethod'] = method;
    }
    await _db.collection('payouts').doc(id).update(updateData);
  }

  /// Get stream of all customers
  Stream<List<UserModel>> getAllCustomers() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'customer')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromFirestore(doc))
            .toList());
  }

  /// Get stream of all vendors
  Stream<List<UserModel>> getAllVendors() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'vendor')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromFirestore(doc))
            .toList());
  }

  /// Update user status (active/suspended)
  Future<void> updateUserStatus(String uid, String status) async {
    await _db.collection('users').doc(uid).update({'status': status});
  }

  /// Delete user
  Future<void> deleteUser(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }

  /// Reset Password logic (Sending password reset email)
  Future<void> sendResetPasswordEmail(String email) async {
    await FirebaseFirestore.instance.app.options; // Placeholder for logic if needed
    // Typically this would use FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  /// Get stream of all riders
  Stream<List<UserModel>> getAllRiders() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'rider')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromFirestore(doc))
            .toList());
  }

  /// Update rider status (active/suspended)
  Future<void> updateRiderStatus(String uid, String status) async {
    await _db.collection('users').doc(uid).update({'status': status});
  }

  /// Delete rider
  Future<void> deleteRider(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }

  /// Get stream of all pending orders
  Stream<List<OrderModel>> getPendingOrders() {
    return _db
        .collection('orders')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc))
            .toList());
  }

  /// Get a single order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    final doc = await _db.collection('orders').doc(orderId).get();
    if (doc.exists) return OrderModel.fromFirestore(doc);
    return null;
  }

  /// Get all orders
  Stream<List<OrderModel>> getAllOrders() {
    return _db
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc))
            .toList());
  }

  /// Cancel order
  Future<void> cancelOrder(String orderId) async {
    await _db.collection('orders').doc(orderId).update({'status': 'cancelled'});
  }

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

  /// Get stream of orders based on time range
  Stream<List<OrderModel>> getOrdersStream({required DateTime start, required DateTime end}) {
    return _db
        .collection('orders')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc))
            .toList());
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

  /// Get stream of all shops
  Stream<List<ShopModel>> getAllShops() {
    return _db
        .collection('shops')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ShopModel.fromFirestore(doc))
            .toList());
  }

  /// Update shop status
  Future<void> updateShopStatus(String shopId, String status) async {
    await _db.collection('shops').doc(shopId).update({'status': status});
  }

  /// Delete shop
  Future<void> deleteShop(String shopId) async {
    await _db.collection('shops').doc(shopId).delete();
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
