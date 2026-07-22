import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/rider_service.dart';
import '../services/cloudinary_service.dart';
import '../services/vendor_service.dart';
import '../services/admin_service.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../models/notification_model.dart';
import '../models/shop_model.dart';
import '../models/approval_model.dart';
import '../models/payout_model.dart';
import '../models/activity_model.dart';

final authServiceProvider = Provider((ref) => AuthService());
final riderServiceProvider = Provider((ref) => RiderService());
final cloudinaryServiceProvider = Provider((ref) => CloudinaryService());
final vendorServiceProvider = Provider((ref) => VendorService());
final adminServiceProvider = Provider((ref) => AdminService());

final authStateProvider = StreamProvider((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final userModelProvider = StreamProvider<UserModel?>((ref) async* {
  final authState = ref.watch(authStateProvider);
  final user = authState.asData?.value;
  if (user == null) {
    yield null;
  } else {
    yield* ref.read(authServiceProvider).getUserStream(user.uid);
  }
});

final availableOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  return ref.watch(riderServiceProvider).getAvailableOrders();
});

final activeRiderOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null) return Stream.value([]);
  return ref.watch(riderServiceProvider).getActiveRiderOrders(user.uid);
});

final riderHistoryProvider = StreamProvider<List<OrderModel>>((ref) {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null) return Stream.value([]);
  return ref.watch(riderServiceProvider).getRiderHistory(user.uid);
});

final shopProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  final user = ref.watch(userModelProvider).asData?.value;
  if (user == null || user.shopId == null) return Stream.value([]);
  return ref.watch(vendorServiceProvider).getShopProducts(user.shopId!);
});

final adminNotificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  return ref.watch(adminServiceProvider).getNotifications();
});

final allShopsProvider = StreamProvider<List<ShopModel>>((ref) {
  return ref.watch(adminServiceProvider).getAllShops();
});

final allRidersProvider = StreamProvider<List<UserModel>>((ref) {
  return ref.watch(adminServiceProvider).getAllRiders();
});

final allPendingOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  return ref.watch(adminServiceProvider).getPendingOrders();
});

final allCustomersProvider = StreamProvider<List<UserModel>>((ref) {
  return ref.watch(adminServiceProvider).getAllCustomers();
});

final allVendorsProvider = StreamProvider<List<UserModel>>((ref) {
  return ref.watch(adminServiceProvider).getAllVendors();
});

final pendingApprovalsProvider = StreamProvider<List<ApprovalModel>>((ref) {
  return ref.watch(adminServiceProvider).getPendingApprovals();
});

final payoutRequestsProvider = StreamProvider<List<PayoutModel>>((ref) {
  return ref.watch(adminServiceProvider).getPayoutRequests();
});

final activityLogsProvider = StreamProvider.family<List<ActivityModel>, DateTime?>((ref, start) {
  return ref.watch(adminServiceProvider).getActivityLogs(start: start);
});

// Admin Stats Providers
final totalShopsCountProvider = StreamProvider<int>((ref) {
  return FirebaseFirestore.instance.collection('shops').snapshots().map((s) => s.docs.length);
});

final totalRidersCountProvider = StreamProvider<int>((ref) {
  return FirebaseFirestore.instance.collection('users')
      .where('role', isEqualTo: 'rider')
      .snapshots().map((s) => s.docs.length);
});

final totalCustomersCountProvider = StreamProvider<int>((ref) {
  return FirebaseFirestore.instance.collection('users')
      .where('role', isEqualTo: 'customer')
      .snapshots().map((s) => s.docs.length);
});

final pendingOrdersCountProvider = StreamProvider<int>((ref) {
  return FirebaseFirestore.instance.collection('orders')
      .where('status', isEqualTo: 'pending')
      .snapshots().map((s) => s.docs.length);
});

// Revenue Providers
final dailyRevenueProvider = StreamProvider<double>((ref) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
  return ref.watch(adminServiceProvider).getRevenueStream(start: start, end: end);
});

final weeklyRevenueProvider = StreamProvider<double>((ref) {
  final now = DateTime.now();
  final start = now.subtract(Duration(days: now.weekday - 1));
  final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
  return ref.watch(adminServiceProvider).getRevenueStream(start: start, end: end);
});

final monthlyRevenueProvider = StreamProvider<double>((ref) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, 1);
  final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
  return ref.watch(adminServiceProvider).getRevenueStream(start: start, end: end);
});
