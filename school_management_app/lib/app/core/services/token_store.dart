/// Contract for JWT token persistence.
///
/// The app uses [TokenStorageService] (flutter_secure_storage) in production;
/// tests plug in an in-memory fake so the ApiClient refresh flow can be
/// verified without platform channels.
abstract class TokenStore {
  String? get accessToken;
  String? get refreshToken;
  bool get hasSession;

  Future<void> saveTokens({String? access, String? refresh});
  Future<void> clear();
}
