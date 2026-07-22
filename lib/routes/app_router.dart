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
import '../features/vendor/vendor_dashboard.dart';
import '../features/vendor/add_product_screen.dart';
import '../features/customer/customer_home.dart';
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

      final user = authState.value;
      
      // If no user is logged in
      if (user == null) {
        return loggingIn ? null : '/welcome';
      }

      final model = userModel.value;
      
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
      GoRoute(path: '/vendor', builder: (context, state) => const VendorDashboard()),
      GoRoute(path: '/vendor/add-product', builder: (context, state) => const AddProductScreen()),
      GoRoute(path: '/customer', builder: (context, state) => const CustomerHome()),
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
