import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/address_model.dart';
import '../models/product_model.dart';
import '../models/shop_model.dart';
import '../models/offer_model.dart';
import '../models/order_model.dart';
import '../models/notification_model.dart';
import '../models/review_model.dart';

class CustomerService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get all active promotional offers
  Stream<List<OfferModel>> getActiveOffers() {
    return _db
        .collection('offers')
        .where('expiryDate', isGreaterThan: Timestamp.now())
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OfferModel.fromFirestore(doc))
            .toList());
  }

  /// Get shops in a specific category
  Stream<List<ShopModel>> getCategoryShops(String category) {
    return _db
        .collection('shops')
        .where('status', isEqualTo: 'active')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ShopModel.fromFirestore(doc))
            .toList());
  }

  /// Get featured shops
  Stream<List<ShopModel>> getFeaturedShops() {
    return _db
        .collection('shops')
        .where('status', isEqualTo: 'active')
        .where('isFeatured', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ShopModel.fromFirestore(doc))
            .toList());
  }

  /// Get nearby shops (simple implementation fetching all active for now)
  Stream<List<ShopModel>> getNearbyShops() {
    return _db
        .collection('shops')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ShopModel.fromFirestore(doc))
            .toList());
  }

  /// Get a single shop by ID
  Stream<ShopModel?> getShopById(String shopId) {
    return _db.collection('shops').doc(shopId).snapshots().map((doc) {
      if (doc.exists) return ShopModel.fromFirestore(doc);
      return null;
    });
  }

  /// Get products of a shop
  Stream<List<ProductModel>> getShopProducts(String shopId) {
    return _db
        .collection('products')
        .where('shopId', isEqualTo: shopId)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromFirestore(doc))
            .toList());
  }

  /// Place a new order
  Future<String> placeOrder(Map<String, dynamic> orderData) async {
    final docRef = await _db.collection('orders').add(orderData);
    return docRef.id;
  }

  /// Get stream of a single order
  Stream<OrderModel?> getOrderStream(String orderId) {
    return _db.collection('orders').doc(orderId).snapshots().map((doc) {
      if (doc.exists) return OrderModel.fromFirestore(doc);
      return null;
    });
  }

  /// Get stream of orders for a specific customer
  Stream<List<OrderModel>> getCustomerOrders(String userId) {
    return _db
        .collection('orders')
        .where('customerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final orders = snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
      // Sort in memory to avoid index requirement for now
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    });
  }

  /// Get products by multiple IDs (for Offer details)
  Stream<List<ProductModel>> getProductsByIds(List<String> productIds) {
    if (productIds.isEmpty) return Stream.value([]);
    return _db
        .collection('products')
        .where(FieldPath.documentId, whereIn: productIds)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromFirestore(doc))
            .toList());
  }

  /// Get shops by multiple IDs (for Offer details)
  Stream<List<ShopModel>> getShopsByIds(List<String> shopIds) {
    if (shopIds.isEmpty) return Stream.value([]);
    return _db
        .collection('shops')
        .where(FieldPath.documentId, whereIn: shopIds)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ShopModel.fromFirestore(doc))
            .toList());
  }

  /// Submit a review for an order, shop, rider, and specific products
  Future<void> submitReview({
    required String orderId,
    required String shopId,
    required String? riderId,
    required String customerName,
    required double rating,
    required String review,
    List<Map<String, dynamic>> productRatings = const [],
  }) async {
    final batch = _db.batch();
    
    // 1. Add to shop reviews
    final shopReviewRef = _db.collection('shops').doc(shopId).collection('reviews').doc();
    batch.set(shopReviewRef, {
      'orderId': orderId,
      'customerName': customerName,
      'rating': rating,
      'review': review,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2. Add to rider reviews if rider assigned
    if (riderId != null) {
      final riderReviewRef = _db.collection('rider_reviews').doc();
      batch.set(riderReviewRef, {
        'orderId': orderId,
        'riderId': riderId,
        'customerName': customerName,
        'rating': rating,
        'review': review,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // 3. Add individual product reviews
    for (var prodRate in productRatings) {
      final productId = prodRate['productId'];
      final pRating = prodRate['rating'];
      final pReview = prodRate['review'] ?? '';

      final prodReviewRef = _db.collection('product_reviews').doc();
      batch.set(prodReviewRef, {
        'orderId': orderId,
        'productId': productId,
        'customerName': customerName,
        'rating': pRating,
        'review': pReview,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // 4. Update order record to mark as reviewed
    batch.update(_db.collection('orders').doc(orderId), {'isReviewed': true});

    await batch.commit();
  }

  /// Get reviews for a specific product
  Stream<List<ReviewModel>> getProductReviews(String productId) {
    return _db
        .collection('product_reviews')
        .where('productId', isEqualTo: productId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromFirestore(doc))
            .toList());
  }

  /// Toggle Wishlist item
  Future<void> toggleWishlist(String userId, ProductModel product) async {
    final docRef = _db
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .doc(product.id);
    
    final doc = await docRef.get();
    if (doc.exists) {
      await docRef.delete();
    } else {
      await docRef.set(product.toMap());
    }
  }

  Stream<List<AddressModel>> getSavedAddresses(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AddressModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addAddress(String userId, AddressModel address) async {
    if (address.isDefault) {
      await _clearDefaultAddress(userId);
    }
    await _db
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .add(address.toMap());
  }

  Future<void> updateAddress(String userId, AddressModel address) async {
    if (address.isDefault) {
      await _clearDefaultAddress(userId);
    }
    await _db
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .doc(address.id)
        .update(address.toMap());
  }

  Future<void> deleteAddress(String userId, String addressId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .doc(addressId)
        .delete();
  }

  Future<void> setDefaultAddress(String userId, String addressId) async {
    await _clearDefaultAddress(userId);
    await _db
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .doc(addressId)
        .update({'isDefault': true});
  }

  Future<void> _clearDefaultAddress(String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .where('isDefault', isEqualTo: true)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.update({'isDefault': false});
    }
  }

  /// Search Products
  Stream<List<ProductModel>> searchProducts(String query) {
    return _db
        .collection('products')
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromFirestore(doc))
            .where((p) =>
                p.name.toLowerCase().contains(query.toLowerCase()) ||
                p.category.toLowerCase().contains(query.toLowerCase()) ||
                p.brand.toLowerCase().contains(query.toLowerCase()))
            .toList());
  }

  /// Search Shops
  Stream<List<ShopModel>> searchShops(String query) {
    return _db
        .collection('shops')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ShopModel.fromFirestore(doc))
            .where((s) => s.name.toLowerCase().contains(query.toLowerCase()))
            .toList());
  }

  /// Get all categories from products
  Stream<List<String>> getAllCategories() {
    return _db.collection('products').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => doc.data()['category'] as String? ?? 'General')
          .toSet()
          .toList();
    });
  }

  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }

  Future<void> deleteNotification(String userId, String notificationId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  Future<void> markNotificationAsRead(String userId, String notificationId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    final batch = _db.batch();
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
