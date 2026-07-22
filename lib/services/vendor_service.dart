import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/vendor_notification_model.dart';
import '../models/review_model.dart';
import '../models/shop_model.dart';
import '../models/coupon_model.dart';

class VendorService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get shop data
  Stream<ShopModel?> getShopData(String shopId) {
    return _db.collection('shops').doc(shopId).snapshots().map((doc) {
      if (doc.exists) return ShopModel.fromFirestore(doc);
      return null;
    });
  }

  /// Toggle shop status (online/offline)
  Future<void> updateShopStatus(String shopId, String status) async {
    await _db.collection('shops').doc(shopId).update({'status': status});
  }

  /// Get stream of vendor notifications
  Stream<List<VendorNotificationModel>> getNotifications(String vendorId) {
    return _db
        .collection('users')
        .doc(vendorId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VendorNotificationModel.fromFirestore(doc))
            .toList());
  }

  /// Mark notification as read
  Future<void> markAsRead(String vendorId, String notificationId) async {
    await _db
        .collection('users')
        .doc(vendorId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  /// Delete notification
  Future<void> deleteNotification(String vendorId, String notificationId) async {
    await _db
        .collection('users')
        .doc(vendorId)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  /// Add a new product to Firestore
  Future<void> addProduct(ProductModel product) async {
    await _db.collection('products').add(product.toMap());
  }

  /// Get stream of products for a specific shop
  Stream<List<ProductModel>> getShopProducts(String shopId) {
    return _db
        .collection('products')
        .where('shopId', isEqualTo: shopId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList());
  }

  /// Get stream of low stock products for a specific shop
  Stream<List<ProductModel>> getLowStockProducts(String shopId, {int threshold = 5}) {
    return _db
        .collection('products')
        .where('shopId', isEqualTo: shopId)
        .where('stock', isLessThan: threshold)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList());
  }

  /// Update an existing product
  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    await _db.collection('products').doc(productId).update(data);
  }

  /// Delete a product
  Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }

  /// Get stream of incoming orders for a shop (Pending)
  Stream<List<OrderModel>> getIncomingOrders(String shopId) {
    return _db
        .collection('orders')
        .where('shopId', isEqualTo: shopId)
        .where('status', isEqualTo: OrderStatus.pending.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList());
  }

  /// Get stream of all orders for a shop
  Stream<List<OrderModel>> getAllShopOrders(String shopId) {
    return _db
        .collection('orders')
        .where('shopId', isEqualTo: shopId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList());
  }

  /// Update Order Status (Accept/Reject/Complete)
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _db.collection('orders').doc(orderId).update({'status': status.name});
  }

  /// Get a single order
  Future<OrderModel?> getOrder(String orderId) async {
    final doc = await _db.collection('orders').doc(orderId).get();
    if (doc.exists) return OrderModel.fromFirestore(doc);
    return null;
  }

  /// Get stream of reviews for a specific shop
  Stream<List<ReviewModel>> getShopReviews(String shopId) {
    return _db
        .collection('shops')
        .doc(shopId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ReviewModel.fromFirestore(doc)).toList());
  }

  /// Reply to a review
  Future<void> replyToReview(String shopId, String reviewId, String reply) async {
    await _db
        .collection('shops')
        .doc(shopId)
        .collection('reviews')
        .doc(reviewId)
        .update({'reply': reply});
  }

  /// Add Coupon
  Future<void> addCoupon(CouponModel coupon) async {
    await _db.collection('coupons').add(coupon.toMap());
  }

  /// Update Coupon
  Future<void> updateCoupon(String couponId, Map<String, dynamic> data) async {
    await _db.collection('coupons').doc(couponId).update(data);
  }

  /// Delete Coupon
  Future<void> deleteCoupon(String couponId) async {
    await _db.collection('coupons').doc(couponId).delete();
  }

  /// Get stream of coupons for a specific shop
  Stream<List<CouponModel>> getShopCoupons(String shopId) {
    return _db
        .collection('coupons')
        .where('shopId', isEqualTo: shopId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CouponModel.fromFirestore(doc)).toList());
  }
}
