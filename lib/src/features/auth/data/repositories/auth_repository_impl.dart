import 'package:dartz/dartz.dart';

import '../../domain/repositories/abstract_auth_repository.dart';
import '../data_sources/local/abstract_auth_local_data_source.dart';
import '../data_sources/remote/abstract_auth_remote_data_source.dart';

class AuthRepositoryImpl implements AbstractAuthRepository {
  final AbstractAuthLocalDataSource _localDataSource;
  final AbstractAuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._localDataSource, this._remoteDataSource);

  @override
  Future<Either<String, String?>> signInWithSoundCloud() async {
    try {
      final result = await _remoteDataSource.signInWithSoundCloud();
      _localDataSource.cacheToken(accessToken: result['accessToken'], refreshToken: result['refreshToken'], expiresIn: result['expiresIn']);
      return Right(result['accessToken']);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, String?>> fetchAccessToken() async {
    try {
      final result = await _localDataSource.fetchAccessToken();
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      await _localDataSource.signOut();
      return Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}