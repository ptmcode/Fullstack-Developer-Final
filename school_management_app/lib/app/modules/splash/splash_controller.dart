import 'package:get/get.dart';

import '../../core/services/session_service.dart';
import '../../core/services/token_storage_service.dart';
import '../../data/repositories/user_repository.dart';
import '../../routes/app_routes.dart';

/// Decides where the app starts: shell when a session can be restored,
/// login otherwise. `/users/me` both validates the token and refreshes the
/// cached profile (the ApiClient transparently refreshes an expired access
/// token on the way).
class SplashController extends GetxController {
  SplashController({
    required TokenStorageService tokens,
    required SessionService session,
    required UserRepository users,
  })  : _tokens = tokens,
        _session = session,
        _users = users;

  final TokenStorageService _tokens;
  final SessionService _session;
  final UserRepository _users;

  @override
  void onReady() {
    super.onReady();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Small pause so the branding screen doesn't just flash.
    await Future.delayed(const Duration(milliseconds: 600));

    if (!_tokens.hasSession) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    _session.restoreCachedProfile();
    try {
      final me = await _users.me();
      await _session.setUser(me);
      Get.offAllNamed(AppRoutes.shell);
    } catch (_) {
      // Token pair beyond recovery — clean up and go to login.
      await _tokens.clear();
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
