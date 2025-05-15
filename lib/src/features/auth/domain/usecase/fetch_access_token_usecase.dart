import 'package:dartz/dartz.dart';

import '../repositories/abstract_auth_repository.dart';

class FetchAccessTokenUseCase {
  final AbstractAuthRepository _authRepository;

  FetchAccessTokenUseCase(this._authRepository);

  Future<Either<String, String?>> call() async {
    return await _authRepository.fetchAccessToken();
  }
}
