import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:memories/data/models/user_model.dart';
import 'package:memories/data/repositories/interfaces/i_supabase_repository.dart';

part 'auth_session_state.dart';

class AuthSessionCubit extends Cubit<AuthSessionState> {
  AuthSessionCubit({required ISupabaseRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthSessionState());

  final ISupabaseRepository _authRepository;

  Future<void> checkAuth() async {
    emit(state.copyWith(status: AuthSessionStatus.loading));
    try {
      final either = await _authRepository.isAuthenticated().timeout(const Duration(seconds: 5));
      await either.fold((_) async => emit(state.copyWith(status: AuthSessionStatus.error)), (isAuth) async {
        if (isAuth) {
          await loadCurrentUser();
        } else {
          emit(state.copyWith(status: AuthSessionStatus.unauthenticated));
        }
      });
    } on TimeoutException {
      emit(state.copyWith(status: AuthSessionStatus.unauthenticated));
    } catch (_) {
      emit(state.copyWith(status: AuthSessionStatus.error));
    }
  }

  Future<void> loadCurrentUser() async {
    final either = await _authRepository.getCurrentUser();
    await either.fold(
      (_) async => emit(state.copyWith(status: AuthSessionStatus.error, isLoading: false)),
      (user) async => emit(AuthSessionState(status: AuthSessionStatus.authenticated, user: user)),
    );
  }

  Future<void> signOut() async {
    emit(state.copyWith(status: AuthSessionStatus.loading));
    final either = await _authRepository.signOut();
    await either.fold(
      (_) async => emit(state.copyWith(status: AuthSessionStatus.error)),
      (_) async => emit(const AuthSessionState(status: AuthSessionStatus.unauthenticated)),
    );
  }
}
