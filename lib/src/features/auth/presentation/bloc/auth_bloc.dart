import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/usecase/fetch_access_token_usecase.dart';
import '../../domain/usecase/sign_in_with_sound_cloud_usecase.dart';
import '../../domain/usecase/sign_out_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithSoundCloudUseCase signInWithSoundCloudUseCase;
  final FetchAccessTokenUseCase fetchAccessTokenUseCase;
  final SignOutUseCase signOutUseCase;

  AuthBloc({
    required this.signInWithSoundCloudUseCase,
    required this.fetchAccessTokenUseCase,
    required this.signOutUseCase,
}) : super(AuthState.initialState()) {
    on<SignInWithSoundCloudEvent>(_onSignInWithSoundCloudEventHandler);
    on<FetchAccessTokenEvent>(_onFetchAccessTokenEventHandler);
    on<SignOutEvent>(_onSignOutEventHandler);

    add(const FetchAccessTokenEvent());
  }

  void _onSignInWithSoundCloudEventHandler(
    SignInWithSoundCloudEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, setErrorToNull: true));
    final result = await signInWithSoundCloudUseCase.call();
    result.fold(
      (failure) => emit(state.copyWith(error: failure, isLoading: false)),
      (accessToken) => emit(state.copyWith(accessToken: accessToken, setErrorToNull: true, isLoading: false)),
    );
  }

  void _onFetchAccessTokenEventHandler(
    FetchAccessTokenEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, setErrorToNull: true));
    final result = await fetchAccessTokenUseCase.call();
    result.fold(
      (failure) => emit(state.copyWith(error: failure)),
      (accessToken) => emit(state.copyWith(accessToken: accessToken, setErrorToNull: true)),
    );
  }

  void _onSignOutEventHandler(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, setErrorToNull: true));
    final result = await signOutUseCase.call();
    print('Sign out result from bloc: $result');
    result.fold(
      (failure) => emit(state.copyWith(error: failure)),
      (_) => emit(state.copyWith(setAccessTokenToNull: true, setErrorToNull: true, isLoading: false)),
    );
  }
}
