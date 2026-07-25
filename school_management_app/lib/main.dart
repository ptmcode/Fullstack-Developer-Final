import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/bindings/app_bindings.dart';
import 'app/core/network/api_client.dart';
import 'app/core/services/preferences_service.dart';
import 'app/core/services/session_service.dart';
import 'app/core/services/token_storage_service.dart';
import 'app/core/theme/app_theme.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';

/// School Management System — Flutter client.
///
/// Stack: GetX (state management / DI / routing), http (REST calls),
/// flutter_secure_storage (JWT tokens), get_storage (preferences),
/// JWT authentication with transparent refresh.
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
