abstract class AbstractAuthLocalDataSource {
  /// cache the jwt token
  Future<void> cacheToken({required String? accessToken, required String? refreshToken, required String? expiresIn});

  /// fetch user data
  Future<String?> fetchAccessToken();

  Future<void> signOut();
}