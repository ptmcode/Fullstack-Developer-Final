import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/bindings/app_bindings.dart';
import 'app/core/network/api_client.dart';
import 'app/core/services/preferences_service.dart';
import 'app/core/services/push_notification_service.dart';
import 'app/core/services/session_service.dart';
import 'app/core/services/token_storage_service.dart';
import 'app/core/theme/app_theme.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'firebase_options.dart';

/// Handles FCM messages that arrive while the app is terminated or in the
/// background. Must be a top-level entry point.
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Background message: ${message.notification?.title}');
}

/// School Management System — Flutter client.
///
/// Stack: GetX (state management / DI / routing), http (REST calls),
/// flutter_secure_storage (JWT tokens), get_storage (preferences),
/// JWT authentication with transparent refresh, FCM push notifications,
/// PDF/Excel export and QR badges.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Core services are ready before the first frame.
  final preferences = await PreferencesService().init();
  final tokens = await TokenStorageService().init();
  Get.put<PreferencesService>(preferences, permanent: true);
  Get.put<TokenStorageService>(tokens, permanent: true);

  final session = Get.put<SessionService>(
    SessionService(tokens: tokens, preferences: preferences),
    permanent: true,
  );

  final api = Get.put<ApiClient>(ApiClient(tokens: tokens), permanent: true);
  api.onSessionExpired = () => session.endSession(expired: true);

  // Firebase + push are optional at runtime: the app still works fully
  // when Firebase isn't reachable (e.g. no google-services config).
  final push = Get.put<PushNotificationService>(
    PushNotificationService(),
    permanent: true,
  );
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
    // Don't block the first frame on the permission dialog.
    unawaited(push.init());
  } catch (e) {
    push.unavailableReason.value = 'Firebase not configured: $e';
    debugPrint('Firebase init skipped: $e');
  }

  runApp(const SchoolManagementApp());
}

class SchoolManagementApp extends StatelessWidget {
  const SchoolManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'School Management System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: Get.find<PreferencesService>().themeMode,
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    );
  }
}
