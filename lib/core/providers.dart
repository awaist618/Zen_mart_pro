import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/rider_service.dart';
import '../services/cloudinary_service.dart';
import '../services/vendor_service.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

final authServiceProvider = Provider((ref) => AuthService());
final riderServiceProvider = Provider((ref) => RiderService());
final cloudinaryServiceProvider = Provider((ref) => CloudinaryService());
final vendorServiceProvider = Provider((ref) => VendorService());

final authStateProvider = StreamProvider((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final userModelProvider = StreamProvider<UserModel?>((ref) async* {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
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
  final user = ref.watch(userModelProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(riderServiceProvider).getActiveRiderOrders(user.uid);
});

final riderHistoryProvider = StreamProvider<List<OrderModel>>((ref) {
  final user = ref.watch(userModelProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(riderServiceProvider).getRiderHistory(user.uid);
});

final shopProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  final user = ref.watch(userModelProvider).value;
  if (user == null || user.shopId == null) return Stream.value([]);
  return ref.watch(vendorServiceProvider).getShopProducts(user.shopId!);
});
