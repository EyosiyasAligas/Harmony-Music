import 'package:dartz/dartz.dart';

import '../repositories/abstract_auth_repository.dart';

class SignOutUseCase {
  final AbstractAuthRepository _authRepository;

  SignOutUseCase(this._authRepository);

  Future<Either<String, void>> call() async {
    return await _authRepository.signOut();
  }
}
