import 'package:get/get.dart';

import '../../data/models/user_model.dart';
import '../../routes/app_routes.dart';
import 'preferences_service.dart';
import 'push_notification_service.dart';
import 'token_storage_service.dart';

/// Holds the signed-in user for the whole app lifetime and answers
/// permission checks for the UI. Registered once in the initial binding.
class SessionService extends GetxService {
  SessionService({
    required TokenStorageService tokens,
    required PreferencesService preferences,
  })  : _tokens = tokens,
        _preferences = preferences;

  final TokenStorageService _tokens;
  final PreferencesService _preferences;

  final Rxn<UserModel> currentUser = Rxn<UserModel>();

  bool get isSignedIn => currentUser.value != null;

  UserModel? get user => currentUser.value;

  /// Restores the cached profile so the UI has roles/permissions before the
  /// first `/users/me` call finishes.
  void restoreCachedProfile() {
    final cached = _preferences.cachedProfile;
    if (cached != null && _tokens.hasSession) {
      currentUser.value = UserModel.fromJson(cached);
    }
  }

  Future<void> setUser(UserModel user) async {
    currentUser.value = user;
    await _preferences.setCachedProfile(user.toJson());
    // The backend can only push to devices it knows about; register this
    // one for whoever just signed in (fire-and-forget, never blocks login).
    if (Get.isRegistered<PushNotificationService>()) {
      Get.find<PushNotificationService>().registerDeviceWithBackend();
    }
  }

  bool hasPermission(String code) => user?.hasPermission(code) ?? false;

  bool hasAnyPermission(Iterable<String> codes) =>
      codes.any((c) => hasPermission(c));

  /// Clears every trace of the session and returns to the login screen.
  Future<void> endSession({bool expired = false}) async {
    currentUser.value = null;
    await _tokens.clear();
    await _preferences.setCachedProfile(null);
    Get.offAllNamed(AppRoutes.login);
    if (expired) {
      Get.snackbar('Session expired', 'Please sign in again.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
