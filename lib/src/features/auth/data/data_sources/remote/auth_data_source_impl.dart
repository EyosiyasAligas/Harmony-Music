import 'package:dio/dio.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/constants/local_storage_constants.dart';
import '../../../../../core/storage/local_storage_service.dart';
import 'abstract_auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AbstractAuthRemoteDataSource {
  final Dio dio;
  final FlutterAppAuth appAuth;
  final LocalStorageService localStorageService;

  AuthRemoteDataSourceImpl({
    required this.dio,
    required this.appAuth,
    required this.localStorageService,
  });

  @override
  Future<Map<String, dynamic>> signInWithSoundCloud() async {
    try {
      final authorizationResponse = await _authorize();

      final tokenResponse = await _tokenExchange(authorizationResponse);

      return {
        'accessToken': tokenResponse.accessToken,
        'refreshToken': tokenResponse.refreshToken,
        'expiresIn': tokenResponse.accessTokenExpirationDateTime?.toIso8601String(),
      };
    } on DioException catch (_) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await dio.post(
        ApiConstants.signOut,
        data: {
          "access_token": await localStorageService.getToken(
            tokenKey: LocalStorageConstants.accessToken,
          ),
        },
      );
    } on DioException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<AuthorizationResponse> _authorize() async {
    return await appAuth.authorize(
      AuthorizationRequest(
        ApiConstants.clientId,
        ApiConstants.redirectUri,
        serviceConfiguration: const AuthorizationServiceConfiguration(
          authorizationEndpoint: ApiConstants.authorise,
          tokenEndpoint: ApiConstants.getToken,
        ),
        scopes: ApiConstants.scopes,
      ),
    );
  }

  Future<TokenResponse> _tokenExchange(
    AuthorizationResponse authorizationResponse,
  ) async {
    return await appAuth.token(
      TokenRequest(
        ApiConstants.clientId,
        ApiConstants.redirectUri,
        serviceConfiguration: const AuthorizationServiceConfiguration(
          authorizationEndpoint: ApiConstants.authorise,
          tokenEndpoint: ApiConstants.getToken,
        ),
        additionalParameters: {'client_secret': ApiConstants.clientSecret},
        grantType: 'authorization_code',
        authorizationCode: authorizationResponse.authorizationCode,
        codeVerifier: authorizationResponse.codeVerifier,
        scopes: ApiConstants.scopes,
      ),
    );
  }
}
