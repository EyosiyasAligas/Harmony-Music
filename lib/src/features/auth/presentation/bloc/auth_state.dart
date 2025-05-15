part of 'auth_bloc.dart';

class AuthState extends Equatable {
  final String? accessToken;
  final String? error;
  final bool isLoading;

  const AuthState({this.accessToken, this.error, required this.isLoading});

  static initialState() {
    return const AuthState(
      accessToken: null,
      error: null,
      isLoading: false,
    );
  }

  AuthState copyWith({
    String? accessToken,
    bool setAccessTokenToNull = false,
    String? error,
    bool setErrorToNull = false,
    bool isLoading = false,
  }) {
    return AuthState(
      accessToken: setAccessTokenToNull ? null : accessToken ?? this.accessToken,
      error: setErrorToNull ? null : error ?? this.error,
      isLoading: isLoading,
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [accessToken, error, isLoading];
}
