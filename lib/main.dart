import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'routes/app_router.dart';
import 'core/settings_provider.dart';
import 'services/notification_service.dart';
import 'core/providers.dart';
import 'models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  
  try {
    await Firebase.initializeApp();
    // Initialize Notifications
    final notificationService = NotificationService();
    await notificationService.initialize();
  } catch (e) {
    debugPrint("Firebase Initialization Error: $e");
  }
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const ZenMartProApp(),
    ),
  );
}

class ZenMartProApp extends ConsumerWidget {
  const ZenMartProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsProvider);
    
    // Theme Logic: Apply Premium Light Theme ONLY to Customer module and Auth screens.
    // Admin, Vendor, and Rider dashboards are forced to stay Dark Mode as per requirements.
    final userModel = ref.watch(userModelProvider);
    
    ThemeMode activeThemeMode = settings.themeMode;
    
    userModel.whenData((user) {
      if (user != null && user.role != UserRole.customer) {
        activeThemeMode = ThemeMode.dark;
      }
    });

    return MaterialApp.router(
      title: 'Zen Mart Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: activeThemeMode,
      locale: settings.locale,
      routerConfig: router,
    );
  }
}
