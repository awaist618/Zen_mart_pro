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
import '../features/admin/system_info_screen.dart';
import '../features/admin/activity_log_screen.dart';
import '../features/admin/shop_management_screen.dart';
import '../features/admin/category_management_screen.dart';
import '../features/admin/user_management_screen.dart';
import '../features/admin/support_list_screen.dart';
import '../features/admin/support_chat_detail_screen.dart';
import '../features/admin/order_management_screen.dart';
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
import '../features/vendor/edit_shop_screen.dart';
import '../features/vendor/coupon_management_screen.dart';
import '../features/vendor/vendor_earnings_screen.dart';
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
import '../features/customer/nearby_shops_screen.dart';
import '../features/customer/trending_products_screen.dart';
import '../features/customer/product_reviews_screen.dart';
import '../features/customer/offer_details_screen.dart';
import '../features/customer/product_details_screen.dart';
import '../features/customer/notifications_screen.dart';
import '../features/customer/wishlist_screen.dart';
import '../models/offer_model.dart';
import '../models/product_model.dart';
import '../features/rider/rider_dashboard.dart';
import '../features/rider/order_details_screen.dart';
import '../features/rider/active_tasks_screen.dart';
import '../features/rider/performance_details_screen.dart';
import '../features/rider/rider_reviews_screen.dart';
import '../features/rider/rider_profile_screen.dart';
import '../features/rider/history_screen.dart';
import '../features/rider/earnings_screen.dart';
import '../features/rider/vehicle_details_screen.dart';
import '../features/rider/support_center_screen.dart';
import '../features/rider/alerts_screen.dart';
import '../features/rider/documents_screen.dart';
import '../features/chat/chat_screen.dart';
import '../features/chat/support_chat_screen.dart';
import '../features/support/screens/support_hub_screen.dart';
import '../features/support/screens/create_ticket_screen.dart';
import '../features/support/screens/ticket_chat_screen.dart';
import '../features/support/screens/my_tickets_screen.dart';
import '../features/support/screens/live_chat_screen.dart';
import '../features/support/screens/emergency_report_screen.dart';
import '../features/support/screens/emergency_details_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final userModel = ref.watch(userModelProvider);
  final splashWait = ref.watch(splashDurationProvider);
  final forcedSplash = ref.watch(forcedSplashProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final loggingIn = state.matchedLocation == '/login' || 
                         state.matchedLocation == '/welcome' || 
                         state.matchedLocation == '/signup';

      // If either is loading, or we are still in the splash duration, stay on the current screen (Splash)
      if (authState.isLoading || userModel.isLoading || splashWait.isLoading) return null;

      // Force navigation to Splash if forcedSplash is active (e.g., during login transition)
      if (forcedSplash && state.matchedLocation != '/') return '/';

      final user = authState.asData?.value;
      final model = userModel.asData?.value;
      
      // If no user is logged in
      if (user == null) {
        return loggingIn ? null : '/welcome';
      }
      
      // If user exists in Auth but document is missing in Firestore after loading
      if (model == null && !userModel.isLoading) {
        debugPrint('Router: User logged in but no Firestore profile found for UID: ${user.uid}');
        return '/welcome';
      }

      // Still fetching profile data
      if (model == null) return null;

      // Logic to prevent redirect loops and correctly route based on role
      final isPublicScreen = loggingIn || state.matchedLocation == '/' || state.matchedLocation == '/welcome';
      
      if (isPublicScreen) {
        String target = '/welcome';
        switch (model.role) {
          case UserRole.superAdmin: target = '/admin'; break;
          case UserRole.vendor: target = '/vendor'; break;
          case UserRole.customer: target = '/customer'; break;
          case UserRole.rider: target = '/rider'; break;
          default: target = '/welcome';
        }
        
        // ONLY redirect if the current location isn't already the target
        if (state.matchedLocation != target) {
          return target;
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
      GoRoute(path: '/admin/categories', builder: (context, state) => const CategoryManagementScreen()),
      GoRoute(path: '/admin/users', builder: (context, state) => UserManagementScreen(initialTab: int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0)),
      GoRoute(path: '/admin/riders', builder: (context, state) => const RiderManagementScreen()),
      GoRoute(path: '/admin/pending-orders', builder: (context, state) => const PendingOrdersScreen()),
      GoRoute(path: '/admin/customers', builder: (context, state) => const CustomerManagementScreen()),
      GoRoute(path: '/admin/vendors', builder: (context, state) => const VendorManagementScreen()),
      GoRoute(path: '/admin/approvals', builder: (context, state) => const ApprovalCenterScreen()),
      GoRoute(path: '/admin/payouts', builder: (context, state) => const PayoutManagementScreen()),
      GoRoute(path: '/admin/system', builder: (context, state) => const SystemSettingsScreen()),
      GoRoute(path: '/admin/system-info', builder: (context, state) => const SystemInfoScreen()),
      GoRoute(path: '/admin/activity-log', builder: (context, state) => const ActivityLogScreen()),
      GoRoute(path: '/admin/orders', builder: (context, state) => const OrderManagementScreen()),
      GoRoute(path: '/admin/support', builder: (context, state) => const SupportListScreen()),
      GoRoute(
        path: '/admin/support-chat/:userId/:userName',
        builder: (context, state) => SupportChatDetailScreen(
          userId: state.pathParameters['userId']!,
          userName: state.pathParameters['userName']!,
        ),
      ),
      GoRoute(path: '/vendor', builder: (context, state) => const VendorDashboard()),
      GoRoute(path: '/vendor/add-product', builder: (context, state) => const AddProductScreen()),
      GoRoute(path: '/vendor/notifications', builder: (context, state) => const VendorNotificationsScreen()),
      GoRoute(path: '/vendor/profile', builder: (context, state) => const VendorProfileScreen()),
      GoRoute(path: '/vendor/edit-shop', builder: (context, state) => const EditShopScreen()),
      GoRoute(path: '/vendor/analytics', builder: (context, state) => const VendorSalesAnalyticsScreen()),
      GoRoute(path: '/vendor/orders', builder: (context, state) => const VendorOrdersScreen()),
      GoRoute(path: '/vendor/order-details/:id', builder: (context, state) => VendorOrderDetailsScreen(orderId: state.pathParameters['id']!)),
      GoRoute(path: '/vendor/products', builder: (context, state) => const ProductManagementScreen()),
      GoRoute(path: '/vendor/low-stock', builder: (context, state) => const LowStockScreen()),
      GoRoute(path: '/vendor/reviews', builder: (context, state) => const VendorReviewsScreen()),
      GoRoute(path: '/vendor/coupons', builder: (context, state) => const CouponManagementScreen()),
      GoRoute(path: '/vendor/earnings', builder: (context, state) => const VendorEarningsScreen()),
      GoRoute(path: '/customer', builder: (context, state) => const CustomerHome()),
      GoRoute(path: '/customer/profile', builder: (context, state) => const CustomerProfileScreen()),
      GoRoute(path: '/customer/addresses', builder: (context, state) => const AddressManagementScreen()),
      GoRoute(path: '/customer/search', builder: (context, state) => const CustomerSearchScreen()),
      GoRoute(path: '/customer/wishlist', builder: (context, state) => const WishlistScreen()),
      GoRoute(path: '/customer/cart', builder: (context, state) => const CartScreen()),
      GoRoute(path: '/customer/checkout', builder: (context, state) => const CheckoutScreen()),
      GoRoute(path: '/customer/orders', builder: (context, state) => const CustomerOrdersScreen()),
      GoRoute(path: '/customer/order-details/:id', builder: (context, state) => CustomerOrderDetailsScreen(orderId: state.pathParameters['id']!)),
      GoRoute(path: '/customer/order-success/:id', builder: (context, state) => OrderSuccessScreen(orderId: state.pathParameters['id']!)),
      GoRoute(path: '/customer/featured-shops', builder: (context, state) => const FeaturedShopsScreen()),
      GoRoute(path: '/customer/nearby-shops', builder: (context, state) => const NearbyShopsScreen()),
      GoRoute(path: '/customer/trending-products', builder: (context, state) => const TrendingProductsScreen()),
      GoRoute(path: '/customer/category/:name', builder: (context, state) => CategoryShopsScreen(category: state.pathParameters['name']!)),
      GoRoute(path: '/customer/offer', builder: (context, state) => OfferDetailsScreen(offer: state.extra as OfferModel)),
      GoRoute(path: '/customer/product', builder: (context, state) => ProductDetailsScreen(product: state.extra as ProductModel)),
      GoRoute(
        path: '/customer/product-reviews/:id/:name', 
        builder: (context, state) => ProductReviewsScreen(
          productId: state.pathParameters['id']!,
          productName: state.pathParameters['name']!,
        )
      ),
      GoRoute(path: '/customer/shop/:id', builder: (context, state) => ShopDetailScreen(shopId: state.pathParameters['id']!)),
      GoRoute(path: '/customer/notifications', builder: (context, state) => const CustomerNotificationsScreen()),
      GoRoute(path: '/rider', builder: (context, state) => const RiderDashboard()),
      GoRoute(path: '/rider/order-details/:id', builder: (context, state) => OrderDetailsScreen(orderId: state.pathParameters['id']!)),
      GoRoute(path: '/rider/active-tasks', builder: (context, state) => const ActiveTasksScreen()),
      GoRoute(path: '/rider/performance', builder: (context, state) => const PerformanceDetailsScreen()),
      GoRoute(path: '/rider/reviews', builder: (context, state) => const RiderReviewsScreen()),
      GoRoute(path: '/rider/profile', builder: (context, state) => const RiderProfileScreen()),
      GoRoute(path: '/rider/history', builder: (context, state) => const RiderHistoryScreen()),
      GoRoute(path: '/rider/earnings', builder: (context, state) => const RiderEarningsScreen()),
      GoRoute(path: '/rider/vehicle', builder: (context, state) => const VehicleDetailsScreen()),
      GoRoute(path: '/rider/support', builder: (context, state) => const SupportCenterScreen()),
      GoRoute(path: '/rider/support-chat', builder: (context, state) => const SupportChatScreen()),
      GoRoute(path: '/rider/alerts', builder: (context, state) => const AlertsScreen()),
      GoRoute(path: '/rider/documents', builder: (context, state) => const DocumentsScreen()),
      GoRoute(path: '/support', builder: (context, state) => const SupportHubScreen()),
      GoRoute(path: '/support/create-ticket', builder: (context, state) => CreateTicketScreen(initialCategory: state.extra as String?)),
      GoRoute(path: '/support/ticket-chat/:id', builder: (context, state) => TicketChatScreen(ticketId: state.pathParameters['id']!)),
      GoRoute(path: '/support/live-chat/:id', builder: (context, state) => LiveChatScreen(chatId: state.pathParameters['id']!)),
      GoRoute(path: '/support/emergency', builder: (context, state) => const EmergencyReportScreen()),
      GoRoute(path: '/support/emergency-details/:id', builder: (context, state) => EmergencyDetailsScreen(reportId: state.pathParameters['id']!)),
      GoRoute(path: '/support/tickets', builder: (context, state) => const MyTicketsScreen()),
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
