/// Route names used with `Get.toNamed` / `Get.offAllNamed`.
class AppRoutes {
  AppRoutes._();

  static const splash = '/splash';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';

  /// Main shell with the side navigation; every feature screen lives inside.
  static const shell = '/';

  static const studentDetail = '/students/detail';
  static const classDetail = '/classes/detail';
}
