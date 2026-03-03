part of 'auth_session_cubit.dart';

enum AuthSessionStatus { initial, loading, authenticated, unauthenticated, error }

class AuthSessionState {
  final AuthSessionStatus status;
  final UserModel? user;
  final bool isLoading;

  const AuthSessionState({this.status = AuthSessionStatus.initial, this.user, this.isLoading = false});

  AuthSessionState copyWith({AuthSessionStatus? status, UserModel? user, bool? isLoading}) {
    return AuthSessionState(
      status: status ?? this.status,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
