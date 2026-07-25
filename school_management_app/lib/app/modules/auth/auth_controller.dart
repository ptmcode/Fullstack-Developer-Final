import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/network/api_exception.dart';
import '../../core/services/preferences_service.dart';
import '../../core/services/session_service.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../data/repositories/auth_repository.dart';
import '../../routes/app_routes.dart';

/// Drives the login, forgot-password and reset-password screens.
class AuthController extends GetxController {
  AuthController({
    required AuthRepository auth,
    required SessionService session,
    required PreferencesService preferences,
  })  : _auth = auth,
        _session = session,
        _preferences = preferences;

  final AuthRepository _auth;
  final SessionService _session;
  final PreferencesService _preferences;

  // --- Login ----------------------------------------------------------------
  final loginFormKey = GlobalKey<FormState>();
  late final usernameController =
      TextEditingController(text: _preferences.rememberedUsername);
  final passwordController = TextEditingController();
  final obscurePassword = true.obs;
  final rememberMe = true.obs;
  final loggingIn = false.obs;

  Future<void> login() async {
    if (!(loginFormKey.currentState?.validate() ?? false)) return;
    loggingIn.value = true;
    try {
      final sessionData = await _auth.login(
        username: usernameController.text.trim(),
        password: passwordController.text,
      );
      await _preferences.setRememberedUsername(
        rememberMe.value ? usernameController.text.trim() : null,
      );
      await _session.setUser(sessionData.user);
      passwordController.clear();
      Get.offAllNamed(AppRoutes.shell);
    } on ApiException catch (e) {
      AppSnackbar.error(e.displayMessage);
    } catch (_) {
      AppSnackbar.error('Unable to sign in. Please try again.');
    } finally {
      loggingIn.value = false;
    }
  }

  // --- Forgot password --------------------------------------------------------
  final forgotFormKey = GlobalKey<FormState>();
  final forgotEmailController = TextEditingController();
  final sendingReset = false.obs;

  Future<void> requestPasswordReset() async {
    if (!(forgotFormKey.currentState?.validate() ?? false)) return;
    sendingReset.value = true;
    try {
      final message =
          await _auth.forgotPassword(forgotEmailController.text.trim());
      AppSnackbar.success(message);
      Get.toNamed(AppRoutes.resetPassword);
    } on ApiException catch (e) {
      AppSnackbar.error(e.displayMessage);
    } finally {
      sendingReset.value = false;
    }
  }

  // --- Reset password ----------------------------------------------------------
  final resetFormKey = GlobalKey<FormState>();
  final resetTokenController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final obscureNewPassword = true.obs;
  final resetting = false.obs;

  Future<void> resetPassword() async {
    if (!(resetFormKey.currentState?.validate() ?? false)) return;
    resetting.value = true;
    try {
      final message = await _auth.resetPassword(
        token: resetTokenController.text.trim(),
        newPassword: newPasswordController.text,
      );
      AppSnackbar.success(message);
      resetTokenController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
      Get.offAllNamed(AppRoutes.login);
    } on ApiException catch (e) {
      AppSnackbar.error(e.displayMessage);
    } finally {
      resetting.value = false;
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    forgotEmailController.dispose();
    resetTokenController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
