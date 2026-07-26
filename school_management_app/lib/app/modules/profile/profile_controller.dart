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

  // Text state lives in the widget (see _PasswordCard): a GetX controller
  // can be disposed while its view is still mounted, and disposed
  // TextEditingControllers throw on the next tap.
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
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (changingPassword.value) return;
    changingPassword.value = true;
    try {
      final message = await _users.changeMyPassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      AppSnackbar.success('$message — please sign in again.');
      await _session.endSession();
    } on ApiException catch (e) {
      AppSnackbar.error(e.displayMessage);
    } finally {
      changingPassword.value = false;
    }
  }
}
