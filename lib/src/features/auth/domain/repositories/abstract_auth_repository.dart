import 'package:dartz/dartz.dart';

abstract class AbstractAuthRepository {
  Future<Either<String, String?>> signInWithSoundCloud();

  Future<Either<String, String?>> fetchAccessToken();

  Future<Either<String, void>> signOut();
}