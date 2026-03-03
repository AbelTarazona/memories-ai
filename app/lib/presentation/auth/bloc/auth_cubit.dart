import 'package:bloc/bloc.dart';
import 'package:memories/data/repositories/interfaces/i_supabase_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required ISupabaseRepository authRepository}) : _authRepository = authRepository, super(const AuthState());

  final ISupabaseRepository _authRepository;

  Future<void> signInWithEmail({required String email, required String password}) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final either = await _authRepository.signInWithEmail(email: email, password: password);
    either.fold(
      (failure) => emit(state.copyWith(status: AuthStatus.error, errorMessage: failure.message)),
      (_) => emit(state.copyWith(status: AuthStatus.success)),
    );
  }
}
