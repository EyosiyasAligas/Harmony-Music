import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:harmony_music/src/core/constants/local_storage_constants.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../constants/api_constants.dart';
import '../service_locator/service_locator.dart';
import '../storage/local_storage_service.dart';
import '../utils/helper.dart';

class DioClient {
  final Dio dio;

  bool _isRefreshing = false;
  final LocalStorageService _storage;

  DioClient(this._storage, this.dio) {
    initializeDio();
  }

  /// Initialize the Dio
  Future<void> initializeDio() async {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final accessToken = await _storage.getToken(
            tokenKey: LocalStorageConstants.accessToken,
          );
          if (accessToken != null) {
            options.headers['Authorization'] = 'OAuth $accessToken';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            if (_storage.isTokenExpired() && !_isRefreshing) {
              _isRefreshing = true;
              try {
                final newToken = await _refreshTokenRequest();

                if (newToken != null) {
                  final newResponse = await _retryRequest(error.requestOptions);
                  return handler.resolve(newResponse);
                } else {
                  sl<AuthBloc>().add(const SignOutEvent());
                  return handler.reject(
                    DioException(
                      requestOptions: error.requestOptions,
                      response: error.response,
                      error: error.error,
                      message: 'Session expired. Please log in again.',
                    ),
                  );
                }
              } on DioException catch (error) {
                if (kDebugMode) {
                  print('Token refresh error: ${error.response}');
                }
                return handler.reject(error);
              } catch (e) {
                if (kDebugMode) {
                  print('Token refresh failed: $e');
                }
                return handler.reject(error);
              } finally {
                _isRefreshing = false;
              }
            }
          }

          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              error: error.error,
              message:
                  Helper.convertRemoteErrorMessage(error) ??
                  'Some thing went wrong. Please try again.',
            ),
          );
        },
      ),
    );
  }

  /// Refresh the access token
  Future<String?> _refreshTokenRequest() async {
    try {
      final response = await dio.post(
        ApiConstants.getToken,
        data: {
          'grant_type': 'refresh_token',
          'client_id': ApiConstants.clientId,
          'client_secret': ApiConstants.clientSecret,
          'refresh_token': await _storage.getToken(
            tokenKey: LocalStorageConstants.refreshToken,
          ),
        },
      );
      if (response.data != null && response.data['access'] != null) {
        final newAccessToken = response.data['access'];
        _storage.saveToken(
          tokenKey: LocalStorageConstants.accessToken,
          token: newAccessToken,
        );
        dio.options.headers['Authorization'] = 'OAuth $newAccessToken';
      }

      return response.data['access_token'];
    } on DioException catch (error) {
      if (kDebugMode) {
        print('Token refresh error: ${error.response}');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Token refresh error: $e');
      }
      return null;
    }
  }

  /// Retry the original request after refreshing the token
  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    dynamic data = requestOptions.data;

    if (data is FormData) {
      data = await cloneFormData(data);
    }

    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );

    return await dio.request(
      requestOptions.path,
      data: data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  /// Clone the FormData object
  Future<FormData> cloneFormData(FormData original) async {
    final Map<String, dynamic> newMap = {};

    for (var entry in original.fields) {
      newMap[entry.key] = entry.value;
    }

    for (var fileEntry in original.files) {
      final MultipartFile file = fileEntry.value.clone();

      if (file.filename != null) {
        newMap[fileEntry.key] = file;
      }
    }

    return FormData.fromMap(newMap);
  }
}
