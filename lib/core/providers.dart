import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/rider_service.dart';
import '../services/cloudinary_service.dart';
import '../services/upload_service.dart';
import '../services/vendor_service.dart';
import '../services/admin_service.dart';
import '../services/customer_service.dart';
import '../services/order_service.dart';
import '../services/support_service.dart';
import '../services/emergency_service.dart';
import '../services/notification_service.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../models/notification_model.dart';
import '../models/vendor_notification_model.dart';
import '../models/rider_notification_model.dart';
import '../models/shop_model.dart';
import '../models/approval_model.dart';
import '../models/payout_model.dart';
import '../models/activity_model.dart';
import '../models/review_model.dart';
import '../models/coupon_model.dart';
import '../models/address_model.dart';
import '../models/category_model.dart';
import '../models/support_chat_model.dart';
import '../models/support_ticket_model.dart';
import '../models/emergency_report_model.dart';
import '../models/offer_model.dart';
import '../models/cart_model.dart';

final authServiceProvider = Provider((ref) => AuthService());
final riderServiceProvider = Provider((ref) => RiderService());
final cloudinaryServiceProvider = Provider((ref) => CloudinaryService());
final uploadServiceProvider = Provider((ref) => UploadService(ref));
final vendorServiceProvider = Provider((ref) => VendorService());
final adminServiceProvider = Provider((ref) => AdminService());
final customerServiceProvider = Provider((ref) => CustomerService());
final orderServiceProvider = Provider((ref) => OrderService());
final supportServiceProvider = Provider((ref) => SupportService());
final emergencyServiceProvider = Provider((ref) => EmergencyService());
final notificationServiceProvider = Provider((ref) => NotificationService());

final authStateProvider = StreamProvider((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final userModelProvider = StreamProvider<UserModel?>((ref) async* {
  final authState = ref.watch(authStateProvider);
  final user = authState.asData?.value;
  if (user == null) {
    yield null;
  } else {
    // Save FCM Token when user logs in
    ref.read(notificationServiceProvider).saveTokenToFirestore(user.uid);
    yield* ref.read(authServiceProvider).getUserStream(user.uid);
  }
});

// --- RIDER PROVIDERS ---
final availableOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null || user.role != UserRole.rider) return Stream.value([]);
  return ref.watch(riderServiceProvider).getAvailableOrders(user.uid);
});

final activeRiderOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null || user.role != UserRole.rider) return Stream.value([]);
  return ref.watch(riderServiceProvider).getActiveRiderOrders(user.uid);
});

final riderHistoryProvider = StreamProvider<List<OrderModel>>((ref) {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null || user.role != UserRole.rider) return Stream.value([]);
  return ref.watch(riderServiceProvider).getRiderHistory(user.uid);
});

final todayRiderHistoryProvider = StreamProvider<List<OrderModel>>((ref) {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null || user.role != UserRole.rider) return Stream.value([]);
  return ref.watch(riderServiceProvider).getTodayRiderHistory(user.uid);
});

final riderNotificationsProvider = StreamProvider<List<RiderNotificationModel>>((ref) {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null || user.role != UserRole.rider) return Stream.value([]);
  return ref.watch(riderServiceProvider).getNotifications(user.uid);
});

final riderReviewsProvider = StreamProvider<List<ReviewModel>>((ref) {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null || user.role != UserRole.rider) return Stream.value([]);
  return ref.watch(riderServiceProvider).getRiderReviews(user.uid);
});

// --- VENDOR PROVIDERS ---
final shopProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null || user.role != UserRole.vendor || user.shopId == null) return Stream.value([]);
  return ref.watch(vendorServiceProvider).getShopProducts(user.shopId!);
});

final currentShopProvider = StreamProvider<ShopModel?>((ref) {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null || user.role != UserRole.vendor || user.shopId == null) return Stream.value(null);
  return ref.watch(vendorServiceProvider).getShopData(user.shopId!);
});

final lowStockProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null || user.role != UserRole.vendor || user.shopId == null) return Stream.value([]);
  return ref.watch(vendorServiceProvider).getLowStockProducts(user.shopId!);
});

final shopReviewsProvider = StreamProvider<List<ReviewModel>>((ref) {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null || user.role != UserRole.vendor || user.shopId == null) return Stream.value([]);
  return ref.watch(vendorServiceProvider).getShopReviews(user.shopId!);
});

final shopReviewsProviderFromService = StreamProvider.family<List<ReviewModel>, String>((ref, shopId) {
  return ref.watch(vendorServiceProvider).getShopReviews(shopId);
});

final productReviewsProvider = StreamProvider.family<List<ReviewModel>, String>((ref, productId) {
  return ref.watch(customerServiceProvider).getProductReviews(productId);
});

final incomingOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null || user.role != UserRole.vendor || user.shopId == null) return Stream.value([]);
  return ref.watch(vendorServiceProvider).getIncomingOrders(user.shopId!);
});

final allShopOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null || user.role != UserRole.vendor || user.shopId == null) return Stream.value([]);
  return ref.watch(vendorServiceProvider).getAllShopOrders(user.shopId!);
});

final shopCouponsProvider = StreamProvider<List<CouponModel>>((ref) {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null || user.role != UserRole.vendor || user.shopId == null) return Stream.value([]);
  return ref.watch(vendorServiceProvider).getShopCoupons(user.shopId!);
});

final vendorNotificationsProvider = StreamProvider<List<VendorNotificationModel>>((ref) {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null || user.role != UserRole.vendor) return Stream.value([]);
  return ref.watch(vendorServiceProvider).getNotifications(user.uid);
});

// --- CUSTOMER PROVIDERS ---
final customerAddressesProvider = StreamProvider<List<AddressModel>>((ref) {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null || user.role != UserRole.customer) return Stream.value([]);
  return ref.watch(customerServiceProvider).getSavedAddresses(user.uid);
});

final defaultAddressProvider = Provider<AddressModel?>((ref) {
  final addresses = ref.watch(customerAddressesProvider).asData?.value ?? [];
  try {
    return addresses.firstWhere((a) => a.isDefault);
  } catch (_) {
    return addresses.isNotEmpty ? addresses.first : null;
  }
});

final customerOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null || user.role != UserRole.customer) return Stream.value([]);
  return ref.watch(customerServiceProvider).getCustomerOrders(user.uid);
});

final customerWishlistProvider = StreamProvider<List<ProductModel>>((ref) {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null || user.role != UserRole.customer) return Stream.value([]);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('wishlist')
      .snapshots()
      .map((s) => s.docs.map((doc) => ProductModel.fromFirestore(doc)).toList());
});

final activeOffersProvider = StreamProvider<List<OfferModel>>((ref) {
  return ref.watch(customerServiceProvider).getActiveOffers();
});

final featuredShopsProvider = StreamProvider<List<ShopModel>>((ref) {
  return ref.watch(customerServiceProvider).getFeaturedShops();
});

final nearbyShopsProvider = StreamProvider<List<ShopModel>>((ref) {
  return ref.watch(customerServiceProvider).getNearbyShops();
});

final allCategoriesProvider = StreamProvider<List<String>>((ref) {
  return ref.watch(customerServiceProvider).getAllCategories();
});

final searchProductsProvider = StreamProvider.family<List<ProductModel>, String>((ref, query) {
  return ref.watch(customerServiceProvider).searchProducts(query);
});

final searchShopsProvider = StreamProvider.family<List<ShopModel>, String>((ref, query) {
  return ref.watch(customerServiceProvider).searchShops(query);
});

final shopDetailProvider = StreamProvider.family<ShopModel?, String>((ref, shopId) {
  return ref.watch(customerServiceProvider).getShopById(shopId);
});

final shopProductsByIdProvider = StreamProvider.family<List<ProductModel>, String>((ref, shopId) {
  return ref.watch(customerServiceProvider).getShopProducts(shopId);
});

final productDetailProvider = StreamProvider.family<ProductModel?, String>((ref, productId) {
  return FirebaseFirestore.instance.collection('products').doc(productId).snapshots().map((doc) {
    if (doc.exists) return ProductModel.fromFirestore(doc);
    return null;
  });
});

final categoryShopsProvider = StreamProvider.family<List<ShopModel>, String>((ref, category) {
  return ref.watch(customerServiceProvider).getCategoryShops(category);
});

final offerShopsProvider = StreamProvider.family<List<ShopModel>, List<String>>((ref, shopIds) {
  return ref.watch(customerServiceProvider).getShopsByIds(shopIds);
});

final offerProductsProvider = StreamProvider.family<List<ProductModel>, List<String>>((ref, productIds) {
  return ref.watch(customerServiceProvider).getProductsByIds(productIds);
});

// --- ADMIN PROVIDERS ---
final adminNotificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null || user.role != UserRole.superAdmin) return Stream.value([]);
  return ref.watch(adminServiceProvider).getNotifications();
});

final allShopsProvider = StreamProvider<List<ShopModel>>((ref) {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null || user.role != UserRole.superAdmin) return Stream.value([]);
  return ref.watch(adminServiceProvider).getAllShops();
});

final allRidersProvider = StreamProvider<List<UserModel>>((ref) {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null || user.role != UserRole.superAdmin) return Stream.value([]);
  return ref.watch(adminServiceProvider).getAllRiders();
});

final allPendingOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null || user.role != UserRole.superAdmin) return Stream.value([]);
  return ref.watch(adminServiceProvider).getPendingOrders();
});

final allOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null || user.role != UserRole.superAdmin) return Stream.value([]);
  return ref.watch(adminServiceProvider).getAllOrders();
});

final allCustomersProvider = StreamProvider<List<UserModel>>((ref) {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null || user.role != UserRole.superAdmin) return Stream.value([]);
  return ref.watch(adminServiceProvider).getAllCustomers();
});

final allVendorsProvider = StreamProvider<List<UserModel>>((ref) {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null || user.role != UserRole.superAdmin) return Stream.value([]);
  return ref.watch(adminServiceProvider).getAllVendors();
});

final pendingApprovalsProvider = StreamProvider<List<ApprovalModel>>((ref) {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null || user.role != UserRole.superAdmin) return Stream.value([]);
  return ref.watch(adminServiceProvider).getPendingApprovals();
});

final payoutRequestsProvider = StreamProvider<List<PayoutModel>>((ref) {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null || user.role != UserRole.superAdmin) return Stream.value([]);
  return ref.watch(adminServiceProvider).getPayoutRequests();
});

final allCategoriesStreamProvider = StreamProvider<List<CategoryModel>>((ref) {
  return ref.watch(adminServiceProvider).getCategories();
});

final activityLogsProvider = StreamProvider.family<List<ActivityModel>, DateTime?>((ref, start) {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null || user.role != UserRole.superAdmin) return Stream.value([]);
  return ref.watch(adminServiceProvider).getActivityLogs(start: start);
});

// Admin Stats Providers
final totalShopsCountProvider = StreamProvider<int>((ref) {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null || user.role != UserRole.superAdmin) return Stream.value(0);
  return FirebaseFirestore.instance.collection('shops').snapshots().map((s) => s.docs.length);
});

final totalRidersCountProvider = StreamProvider<int>((ref) {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null || user.role != UserRole.superAdmin) return Stream.value(0);
  return FirebaseFirestore.instance.collection('users')
      .where('role', isEqualTo: 'rider')
      .snapshots().map((s) => s.docs.length);
});

final totalCustomersCountProvider = StreamProvider<int>((ref) {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null || user.role != UserRole.superAdmin) return Stream.value(0);
  return FirebaseFirestore.instance.collection('users')
      .where('role', isEqualTo: 'customer')
      .snapshots().map((s) => s.docs.length);
});

final pendingOrdersCountProvider = StreamProvider<int>((ref) {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null || user.role != UserRole.superAdmin) return Stream.value(0);
  return FirebaseFirestore.instance.collection('orders')
      .where('status', isEqualTo: 'pending')
      .snapshots().map((s) => s.docs.length);
});

// Revenue Providers
final dailyRevenueProvider = StreamProvider<double>((ref) {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null || user.role != UserRole.superAdmin) return Stream.value(0.0);
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
  return ref.watch(adminServiceProvider).getRevenueStream(start: start, end: end);
});

final weeklyRevenueProvider = StreamProvider<double>((ref) {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null || user.role != UserRole.superAdmin) return Stream.value(0.0);
  final now = DateTime.now();
  final start = now.subtract(Duration(days: now.weekday - 1));
  final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
  return ref.watch(adminServiceProvider).getRevenueStream(start: start, end: end);
});

final monthlyRevenueProvider = StreamProvider<double>((ref) {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null || user.role != UserRole.superAdmin) return Stream.value(0.0);
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, 1);
  final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
  return ref.watch(adminServiceProvider).getRevenueStream(start: start, end: end);
});

// --- SUPPORT & EMERGENCY PROVIDERS ---
final supportChatProvider = StreamProvider.family<SupportChatModel?, String>((ref, chatId) {
  return ref.watch(supportServiceProvider).getChatStream(chatId);
});

final customerSupportChatProvider = StreamProvider<String?>((ref) async* {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null) {
    yield null;
  } else {
    // This is a bit tricky for a pure StreamProvider if we want it to be auto-creating.
    // For now, we'll assume the UI calls getOrCreateChat.
    // We'll just return the chatId if it exists.
    final db = FirebaseFirestore.instance;
    final snapshots = db.collection('support_chats')
        .where('customerId', isEqualTo: user.uid)
        .limit(1)
        .snapshots();
    
    await for (final snap in snapshots) {
      if (snap.docs.isNotEmpty) {
        yield snap.docs.first.id;
      } else {
        yield null;
      }
    }
  }
});

final supportMessagesProvider = StreamProvider.family<List<SupportMessageModel>, String>((ref, chatId) {
  return ref.watch(supportServiceProvider).getSupportMessages(chatId);
});

final customerEmergencyReportsProvider = StreamProvider<List<EmergencyReportModel>>((ref) {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null) return Stream.value([]);
  return ref.watch(emergencyServiceProvider).getCustomerReports(user.uid);
});

final emergencyReportStreamProvider = StreamProvider.family<EmergencyReportModel?, String>((ref, reportId) {
  return ref.watch(emergencyServiceProvider).getReportStream(reportId);
});

final emergencyTimelineProvider = StreamProvider.family<List<EmergencyTimelineEvent>, String>((ref, reportId) {
  return ref.watch(emergencyServiceProvider).getTimeline(reportId);
});

final emergencyMessagesProvider = StreamProvider.family<List<SupportMessageModel>, String>((ref, reportId) {
  return ref.watch(emergencyServiceProvider).getEmergencyMessages(reportId);
});

// --- CART ---
class CartNotifier extends StateNotifier<CartModel> {
  CartNotifier() : super(CartModel());

  void addItem(ProductModel product, {String? shopName, String? shopImageUrl}) {
    if (state.items.isEmpty) {
      state = CartModel(
        items: {product.id: CartItem(product: product)},
        shopId: product.shopId,
        shopName: shopName,
        shopImageUrl: shopImageUrl,
      );
      return;
    }

    if (state.items.containsKey(product.id)) {
      state = CartModel(
        items: {
          ...state.items,
          product.id: state.items[product.id]!.copyWith(
            quantity: state.items[product.id]!.quantity + 1,
          ),
        },
        shopId: state.shopId,
        shopName: state.shopName,
        shopImageUrl: state.shopImageUrl,
      );
    } else {
      state = CartModel(
        items: {
          ...state.items,
          product.id: CartItem(product: product),
        },
        shopId: state.shopId,
        shopName: state.shopName,
        shopImageUrl: state.shopImageUrl,
      );
    }
  }

  void removeItem(String productId) {
    if (!state.items.containsKey(productId)) return;
    if (state.items[productId]!.quantity > 1) {
      state = CartModel(
        items: {
          ...state.items,
          productId: state.items[productId]!.copyWith(
            quantity: state.items[productId]!.quantity - 1,
          ),
        },
        shopId: state.shopId,
        shopName: state.shopName,
        shopImageUrl: state.shopImageUrl,
      );
    } else {
      final newItems = Map<String, CartItem>.from(state.items);
      newItems.remove(productId);
      if (newItems.isEmpty) {
        state = CartModel();
      } else {
        state = CartModel(
          items: newItems,
          shopId: state.shopId,
          shopName: state.shopName,
          shopImageUrl: state.shopImageUrl,
        );
      }
    }
  }

  void clearCart() {
    state = CartModel();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartModel>((ref) {
  return CartNotifier();
});
