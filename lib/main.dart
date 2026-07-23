import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'routes/app_router.dart';
import 'core/settings_provider.dart';
import 'services/notification_service.dart';

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
    
    return MaterialApp.router(
      title: 'Zen MArt Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      locale: settings.locale,
      routerConfig: router,
    );
  }
}
