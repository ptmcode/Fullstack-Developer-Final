import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/services/token_store.dart';
import '../models/user_model.dart';

/// Authentication endpoints: login, logout, refresh handling is inside
/// [ApiClient]; this repository also persists the token pair.
class AuthRepository {
  AuthRepository({required ApiClient api, required TokenStore tokens})
      : _api = api,
        _tokens = tokens;

  final ApiClient _api;
  final TokenStore _tokens;

  Future<AuthSession> login({
    required String username,
    required String password,
  }) async {
    final envelope = await _api.post(
      ApiConstants.login,
      body: {'username': username, 'password': password},
      auth: false,
    );
    final session = AuthSession.fromJson(envelope.dataAsMap);
    await _tokens.saveTokens(
      access: session.accessToken,
      refresh: session.refreshToken,
    );
    return session;
  }

  /// Revokes all refresh tokens server-side. Local cleanup happens in
  /// SessionService regardless of whether this call succeeds.
  Future<void> logout() async {
    try {
      await _api.post(ApiConstants.logout);
    } catch (_) {
      // Signing out locally must never be blocked by a network error.
    }
  }

  Future<String> forgotPassword(String email) async {
    final envelope = await _api.post(
      ApiConstants.forgotPassword,
      body: {'email': email},
      auth: false,
    );
    return envelope.message;
  }

  Future<String> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final envelope = await _api.post(
      ApiConstants.resetPassword,
      body: {'token': token, 'newPassword': newPassword},
      auth: false,
    );
    return envelope.message;
  }
}
