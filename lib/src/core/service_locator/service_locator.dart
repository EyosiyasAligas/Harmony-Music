import 'package:dio/dio.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/data_sources/local/auth_local_data_source_impl.dart';
import '../../features/auth/data/data_sources/remote/auth_data_source_impl.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/abstract_auth_repository.dart';
import '../../features/auth/domain/usecase/fetch_access_token_usecase.dart';
import '../../features/auth/domain/usecase/sign_in_with_sound_cloud_usecase.dart';
import '../../features/auth/domain/usecase/sign_out_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../constants/api_constants.dart';
import '../network/dio_client.dart';
import '../storage/local_storage_service.dart';

final sl = GetIt.I;

Future<void> initAppInjections() async {
  /// storage
  sl.registerSingletonAsync<LocalStorageService>(() async {
    LocalStorageService localStorageService = LocalStorageService();
    await localStorageService.init();
    return localStorageService;
  });
  await sl.allReady();

  /// network
  sl.registerSingleton<Dio>(
    Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    ),
  );
  sl.registerSingleton<DioClient>(DioClient(sl<LocalStorageService>(), sl<Dio>()));
  sl.registerSingleton<FlutterAppAuth>(const FlutterAppAuth());

  /// data sources
  sl.registerLazySingleton<AuthLocalDataSourceImpl>(
    () => AuthLocalDataSourceImpl(sl<LocalStorageService>()),
  );

  sl.registerLazySingleton<AuthRemoteDataSourceImpl>(
    () => AuthRemoteDataSourceImpl(
      dio: sl<Dio>(),
      appAuth: sl<FlutterAppAuth>(),
      localStorageService: sl<LocalStorageService>(),
    ),
  );

  /// repositories
  sl.registerLazySingleton<AbstractAuthRepository>(
    () => AuthRepositoryImpl(
      sl<AuthLocalDataSourceImpl>(),
      sl<AuthRemoteDataSourceImpl>(),
    ),
  );

  /// usecases
  sl.registerLazySingleton<SignInWithSoundCloudUseCase>(
    () => SignInWithSoundCloudUseCase(sl<AbstractAuthRepository>()),
  );
  sl.registerLazySingleton<FetchAccessTokenUseCase>(
    () => FetchAccessTokenUseCase(sl<AbstractAuthRepository>()),
  );
  sl.registerLazySingleton<SignOutUseCase>(
    () => SignOutUseCase(sl<AbstractAuthRepository>()),
  );

  /// blocs
  sl.registerSingleton<AuthBloc>(
    AuthBloc(
      signInWithSoundCloudUseCase: sl<SignInWithSoundCloudUseCase>(),
      fetchAccessTokenUseCase: sl<FetchAccessTokenUseCase>(),
      signOutUseCase: sl<SignOutUseCase>(),
    ),
  );
}
