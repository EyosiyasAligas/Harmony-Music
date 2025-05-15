import 'package:dartz/dartz.dart';

import '../repositories/abstract_auth_repository.dart';

class SignInWithSoundCloudUseCase {
  final AbstractAuthRepository _authRepository;

  SignInWithSoundCloudUseCase(this._authRepository);

  Future<Either<String, String?>> call() async {
    return await _authRepository.signInWithSoundCloud();
  }
}