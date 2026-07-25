import 'package:get/get.dart';

import '../bindings/app_bindings.dart';
import '../modules/auth/forgot_password_view.dart';
import '../modules/auth/login_view.dart';
import '../modules/auth/reset_password_view.dart';
import '../modules/shell/shell_view.dart';
import '../modules/splash/splash_view.dart';
import '../modules/students/student_detail_view.dart';
import 'app_routes.dart';

/// GetX route table. Every page declares its binding so controllers are
/// created exactly when they are needed.
class AppPages {
  AppPages._();

  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.shell,
      page: () => const ShellView(),
      binding: ShellBinding(),
    ),
    GetPage(
      name: AppRoutes.studentDetail,
      page: () => const StudentDetailView(),
      binding: StudentDetailBinding(),
    ),
  ];
}
