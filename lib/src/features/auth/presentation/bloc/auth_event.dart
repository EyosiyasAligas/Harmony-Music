part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
}

class SignInWithSoundCloudEvent extends AuthEvent {
  const SignInWithSoundCloudEvent();

  @override
  List<Object?> get props => [];
}

class FetchAccessTokenEvent extends AuthEvent {
  const FetchAccessTokenEvent();

  @override
  List<Object?> get props => [];
}

class SignOutEvent extends AuthEvent {
  const SignOutEvent();

  @override
  List<Object?> get props => [];
}
