import 'package:harmony_music/src/core/constants/local_storage_constants.dart';

import '../../../../../core/storage/local_storage_service.dart';
import 'abstract_auth_local_data_source.dart';

class AuthLocalDataSourceImpl implements AbstractAuthLocalDataSource {
  final LocalStorageService localStorageService;

  AuthLocalDataSourceImpl(this.localStorageService);

  @override
  Future<void> cacheToken({
    required String? accessToken,
    required String? refreshToken,
    required String? expiresIn,
  }) async {
    try {
      await Future.wait([
        localStorageService.saveToken(
          tokenKey: LocalStorageConstants.accessToken,
          token: accessToken,
        ),
        localStorageService.saveToken(
          tokenKey: LocalStorageConstants.refreshToken,
          token: refreshToken,
        ),
        if (expiresIn != null)
          localStorageService.saveString(
            LocalStorageConstants.expiresIn,
            expiresIn,
          ),
      ]);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String?> fetchAccessToken() async {
    try {
      return await localStorageService.getToken(
        tokenKey: LocalStorageConstants.accessToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await localStorageService.clear();
    } catch (_) {
      rethrow;
    }
  }
}
