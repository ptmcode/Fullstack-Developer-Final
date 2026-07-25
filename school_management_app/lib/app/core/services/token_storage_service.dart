import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import 'token_store.dart';

/// Persists the JWT access / refresh tokens in the platform secure storage
/// (iOS Keychain, Android Keystore, encrypted storage on other platforms).
///
/// Tokens are security-sensitive, so they never go into GetStorage — that one
/// is reserved for harmless preferences (see PreferencesService).
class TokenStorageService extends GetxService implements TokenStore {
  static const _kAccessToken = 'access_token';
  static const _kRefreshToken = 'refresh_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  String? _accessToken;
  String? _refreshToken;

  /// Loads tokens into memory once at startup so that request building
  /// stays synchronous afterwards.
  Future<TokenStorageService> init() async {
    _accessToken = await _storage.read(key: _kAccessToken);
    _refreshToken = await _storage.read(key: _kRefreshToken);
    return this;
  }

  @override
  String? get accessToken => _accessToken;

  @override
  String? get refreshToken => _refreshToken;

  @override
  bool get hasSession => _refreshToken != null && _refreshToken!.isNotEmpty;

  @override
  Future<void> saveTokens({String? access, String? refresh}) async {
    if (access != null) {
      _accessToken = access;
      await _storage.write(key: _kAccessToken, value: access);
    }
    if (refresh != null) {
      _refreshToken = refresh;
      await _storage.write(key: _kRefreshToken, value: refresh);
    }
  }

  @override
  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    await _storage.delete(key: _kAccessToken);
    await _storage.delete(key: _kRefreshToken);
  }
}
