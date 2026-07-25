import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/network/api_exception.dart';
import '../../core/services/session_service.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../data/repositories/user_repository.dart';

/// My profile: fresh `/users/me` data plus the change-password form.
class ProfileController extends GetxController {
  ProfileController({required UserRepository users, required SessionService session})
      : _users = users,
        _session = session;

  final UserRepository _users;
  final SessionService _session;

  SessionService get session => _session;

  final loading = false.obs;

  final passwordFormKey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final obscure = true.obs;
  final changingPassword = false.obs;

  @override
  void onInit() {
    super.onInit();
    refreshProfile();
  }

  Future<void> refreshProfile() async {
    loading.value = true;
    try {
      await _session.setUser(await _users.me());
    } on ApiException catch (e) {
      AppSnackbar.error(e.displayMessage);
    } finally {
      loading.value = false;
    }
  }

  /// Changing the password revokes all refresh tokens server-side, so a
  /// successful change must end the session and return to login.
  Future<void> changePassword() async {
    if (!(passwordFormKey.currentState?.validate() ?? false)) return;
    changingPassword.value = true;
    try {
      final message = await _users.changeMyPassword(
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
      );
      AppSnackbar.success('$message — please sign in again.');
      await _session.endSession();
    } on ApiException catch (e) {
      AppSnackbar.error(e.displayMessage);
    } finally {
      changingPassword.value = false;
    }
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
