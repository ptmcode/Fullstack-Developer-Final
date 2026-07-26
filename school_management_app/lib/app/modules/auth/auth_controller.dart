import 'package:get/get.dart';

import '../../core/network/api_exception.dart';
import '../../core/services/preferences_service.dart';
import '../../core/services/session_service.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../data/repositories/auth_repository.dart';
import '../../routes/app_routes.dart';

/// Drives the login, forgot-password and reset-password screens.
///
/// Deliberately holds **no** `TextEditingController`s: login, forgot and
/// reset share one binding, so popping a sub-route would dispose this
/// controller while the login screen below is still mounted — its fields
/// would then throw "used after being disposed" on the next tap. Text state
/// therefore lives in the widgets; this controller only takes values in.
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

  /// Prefills the login field with the last signed-in username.
  String? get rememberedUsername => _preferences.rememberedUsername;

  // --- Login ----------------------------------------------------------------
  final obscurePassword = true.obs;
  final rememberMe = true.obs;
  final loggingIn = false.obs;

  Future<void> login({
    required String username,
    required String password,
  }) async {
    if (loggingIn.value) return;
    loggingIn.value = true;
    try {
      final sessionData = await _auth.login(
        username: username,
        password: password,
      );
      await _preferences.setRememberedUsername(
        rememberMe.value ? username : null,
      );
      await _session.setUser(sessionData.user);
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
  final sendingReset = false.obs;

  Future<void> requestPasswordReset(String email) async {
    if (sendingReset.value) return;
    sendingReset.value = true;
    try {
      final message = await _auth.forgotPassword(email);
      AppSnackbar.success(message);
      Get.toNamed(AppRoutes.resetPassword);
    } on ApiException catch (e) {
      AppSnackbar.error(e.displayMessage);
    } finally {
      sendingReset.value = false;
    }
  }

  // --- Reset password ----------------------------------------------------------
  final obscureNewPassword = true.obs;
  final resetting = false.obs;

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    if (resetting.value) return;
    resetting.value = true;
    try {
      final message = await _auth.resetPassword(
        token: token,
        newPassword: newPassword,
      );
      AppSnackbar.success(message);
      Get.offAllNamed(AppRoutes.login);
    } on ApiException catch (e) {
      AppSnackbar.error(e.displayMessage);
    } finally {
      resetting.value = false;
    }
  }
}
