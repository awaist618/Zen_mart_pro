import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers.dart';
import '../models/user_model.dart';
import '../screens/splash_screen.dart';
import '../features/auth/welcome_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/admin/admin_dashboard.dart';
import '../features/admin/add_vendor_screen.dart';
import '../features/admin/add_rider_screen.dart';
import '../features/admin/notifications_screen.dart';
import '../features/admin/admin_profile_screen.dart';
import '../features/admin/analytics_dashboard_screen.dart';
import '../features/admin/all_shops_screen.dart';
import '../features/admin/rider_management_screen.dart';
import '../features/admin/pending_orders_screen.dart';
import '../features/admin/customer_management_screen.dart';
import '../features/admin/vendor_management_screen.dart';
import '../features/admin/approval_center_screen.dart';
import '../features/admin/payout_management_screen.dart';
import '../features/admin/system_settings_screen.dart';
import '../features/admin/activity_log_screen.dart';
import '../features/admin/shop_management_screen.dart';
import '../features/admin/user_management_screen.dart';
import '../features/vendor/vendor_dashboard.dart';
import '../features/vendor/add_product_screen.dart';
import '../features/vendor/vendor_notifications_screen.dart';
import '../features/vendor/vendor_profile_screen.dart';
import '../features/vendor/sales_analytics_screen.dart';
import '../features/vendor/vendor_orders_screen.dart';
import '../features/vendor/vendor_order_details_screen.dart';
import '../features/vendor/product_management_screen.dart';
import '../features/vendor/low_stock_screen.dart';
import '../features/vendor/vendor_reviews_screen.dart';
import '../features/vendor/coupon_management_screen.dart';
import '../features/customer/customer_home.dart';
import '../features/customer/shop_detail_screen.dart';
import '../features/customer/customer_profile_screen.dart';
import '../features/customer/address_management_screen.dart';
import '../features/customer/search_screen.dart';
import '../features/customer/cart_screen.dart';
import '../features/customer/checkout_screen.dart';
import '../features/customer/order_success_screen.dart';
import '../features/customer/customer_orders_screen.dart';
import '../features/customer/customer_order_details_screen.dart';
import '../features/customer/category_shops_screen.dart';
import '../features/customer/featured_shops_screen.dart';
import '../features/customer/offer_details_screen.dart';
import '../features/customer/product_details_screen.dart';
import '../models/offer_model.dart';
import '../models/product_model.dart';
import '../features/rider/rider_dashboard.dart';
import '../features/rider/order_details_screen.dart';
import '../features/rider/rider_profile_screen.dart';
import '../features/rider/history_screen.dart';
import '../features/rider/earnings_screen.dart';
import '../features/chat/chat_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final userModel = ref.watch(userModelProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final loggingIn = state.matchedLocation == '/login' || 
                         state.matchedLocation == '/welcome' || 
                         state.matchedLocation == '/signup';

      // If either is loading, stay on the current screen (Splash)
      if (authState.isLoading || userModel.isLoading) return null;

      // Handle auth errors
      if (authState.hasError || userModel.hasError) {
        return loggingIn ? null : '/welcome';
      }

      final user = authState.asData?.value;
      
      // If no user is logged in
      if (user == null) {
        return loggingIn ? null : '/welcome';
      }

      final model = userModel.asData?.value;
      
      // If user exists in Auth but document is missing in Firestore after loading
      if (model == null && !userModel.isLoading) {
        debugPrint('Router: User logged in but no Firestore profile found for UID: ${user.uid}');
        return '/welcome';
      }

      // Still fetching role
      if (model == null) return null;

      // If logged in but on a public screen (Splash, Welcome, Login, Signup),
      // redirect to the appropriate dashboard
      final isPublicScreen = loggingIn || state.matchedLocation == '/' || state.matchedLocation == '/welcome';
      
      if (isPublicScreen) {
        switch (model.role) {
          case UserRole.superAdmin: return '/admin';
          case UserRole.vendor: return '/vendor';
          case UserRole.customer: return '/customer';
          case UserRole.rider: return '/rider';
          default: return '/welcome';
        }
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/welcome', builder: (context, state) => const WelcomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
      GoRoute(path: '/admin', builder: (context, state) => const AdminDashboard()),
      GoRoute(path: '/admin/add-vendor', builder: (context, state) => const AddVendorScreen()),
      GoRoute(path: '/admin/add-rider', builder: (context, state) => const AddRiderScreen()),
      GoRoute(path: '/admin/notifications', builder: (context, state) => const NotificationsScreen()),
      GoRoute(path: '/admin/profile', builder: (context, state) => const AdminProfileScreen()),
      GoRoute(path: '/admin/analytics', builder: (context, state) => const AnalyticsDashboardScreen()),
      GoRoute(path: '/admin/all-shops', builder: (context, state) => const AllShopsScreen()),
      GoRoute(path: '/admin/shops', builder: (context, state) => const ShopManagementScreen()),
      GoRoute(path: '/admin/users', builder: (context, state) => UserManagementScreen(initialTab: int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0)),
      GoRoute(path: '/admin/riders', builder: (context, state) => const RiderManagementScreen()),
      GoRoute(path: '/admin/pending-orders', builder: (context, state) => const PendingOrdersScreen()),
      GoRoute(path: '/admin/customers', builder: (context, state) => const CustomerManagementScreen()),
      GoRoute(path: '/admin/vendors', builder: (context, state) => const VendorManagementScreen()),
      GoRoute(path: '/admin/approvals', builder: (context, state) => const ApprovalCenterScreen()),
      GoRoute(path: '/admin/payouts', builder: (context, state) => const PayoutManagementScreen()),
      GoRoute(path: '/admin/system', builder: (context, state) => const SystemSettingsScreen()),
      GoRoute(path: '/admin/activity-log', builder: (context, state) => const ActivityLogScreen()),
      GoRoute(path: '/vendor', builder: (context, state) => const VendorDashboard()),
      GoRoute(path: '/vendor/add-product', builder: (context, state) => const AddProductScreen()),
      GoRoute(path: '/vendor/notifications', builder: (context, state) => const VendorNotificationsScreen()),
      GoRoute(path: '/vendor/profile', builder: (context, state) => const VendorProfileScreen()),
      GoRoute(path: '/vendor/analytics', builder: (context, state) => const VendorSalesAnalyticsScreen()),
      GoRoute(path: '/vendor/orders', builder: (context, state) => const VendorOrdersScreen()),
      GoRoute(path: '/vendor/order-details/:id', builder: (context, state) => VendorOrderDetailsScreen(orderId: state.pathParameters['id']!)),
      GoRoute(path: '/vendor/products', builder: (context, state) => const ProductManagementScreen()),
      GoRoute(path: '/vendor/low-stock', builder: (context, state) => const LowStockScreen()),
      GoRoute(path: '/vendor/reviews', builder: (context, state) => const VendorReviewsScreen()),
      GoRoute(path: '/vendor/coupons', builder: (context, state) => const CouponManagementScreen()),
      GoRoute(path: '/customer', builder: (context, state) => const CustomerHome()),
      GoRoute(path: '/customer/profile', builder: (context, state) => const CustomerProfileScreen()),
      GoRoute(path: '/customer/addresses', builder: (context, state) => const AddressManagementScreen()),
      GoRoute(path: '/customer/search', builder: (context, state) => const CustomerSearchScreen()),
      GoRoute(path: '/customer/cart', builder: (context, state) => const CartScreen()),
      GoRoute(path: '/customer/checkout', builder: (context, state) => const CheckoutScreen()),
      GoRoute(path: '/customer/orders', builder: (context, state) => const CustomerOrdersScreen()),
      GoRoute(path: '/customer/order-details/:id', builder: (context, state) => CustomerOrderDetailsScreen(orderId: state.pathParameters['id']!)),
      GoRoute(path: '/customer/order-success/:id', builder: (context, state) => OrderSuccessScreen(orderId: state.pathParameters['id']!)),
      GoRoute(path: '/customer/featured-shops', builder: (context, state) => const FeaturedShopsScreen()),
      GoRoute(path: '/customer/category/:name', builder: (context, state) => CategoryShopsScreen(category: state.pathParameters['name']!)),
      GoRoute(path: '/customer/offer', builder: (context, state) => OfferDetailsScreen(offer: state.extra as OfferModel)),
      GoRoute(path: '/customer/product', builder: (context, state) => ProductDetailsScreen(product: state.extra as ProductModel)),
      GoRoute(path: '/customer/shop/:id', builder: (context, state) => ShopDetailScreen(shopId: state.pathParameters['id']!)),
      GoRoute(path: '/rider', builder: (context, state) => const RiderDashboard()),
      GoRoute(path: '/rider/order-details/:id', builder: (context, state) => OrderDetailsScreen(orderId: state.pathParameters['id']!)),
      GoRoute(path: '/rider/profile', builder: (context, state) => const RiderProfileScreen()),
      GoRoute(path: '/rider/history', builder: (context, state) => const RiderHistoryScreen()),
      GoRoute(path: '/rider/earnings', builder: (context, state) => const RiderEarningsScreen()),
      GoRoute(
        path: '/chat/:orderId/:name',
        builder: (context, state) => ChatScreen(
          orderId: state.pathParameters['orderId']!,
          otherPartyName: state.pathParameters['name']!,
        ),
      ),
    ],
  );
});
