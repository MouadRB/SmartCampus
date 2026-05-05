import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smart_campus/core/error/failures.dart';
import 'package:smart_campus/features/auth/domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Single source of truth for the active session. Lives as an
/// app-wide singleton (registered via lazySingleton) because the AuthGate
/// listens at the root of the widget tree.
///
/// Pure `.fold()` discipline — exception translation happens in the repo.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required this.repository}) : super(const AuthInitial()) {
    on<AuthSessionRestored>(_onSessionRestored);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthLoginRequested>(_onLogin);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthErrorCleared>(_onErrorCleared);
  }

  final AuthRepository repository;

  void _onSessionRestored(
    AuthSessionRestored event,
    Emitter<AuthState> emit,
  ) {
    final user = repository.currentUser;
    if (user == null) {
      emit(const Unauthenticated());
    } else {
      emit(Authenticated(user: user, isFirstSession: false));
    }
  }

  Future<void> _onSignUp(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await repository.signUp(
      name: event.name,
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) => emit(AuthError(_message(failure))),
      (user) => emit(Authenticated(user: user, isFirstSession: true)),
    );
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await repository.login(
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) => emit(AuthError(_message(failure))),
      (user) => emit(Authenticated(user: user, isFirstSession: false)),
    );
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await repository.logout();
    result.fold(
      (failure) => emit(AuthError(_message(failure))),
      (_) => emit(const Unauthenticated()),
    );
  }

  void _onErrorCleared(AuthErrorCleared event, Emitter<AuthState> emit) {
    if (state is AuthError) emit(const Unauthenticated());
  }

  String _message(Failure failure) {
    if (failure is InvalidCredentialsFailure) return failure.message;
    if (failure is EmailAlreadyRegisteredFailure) return failure.message;
    if (failure is WeakPasswordFailure) return failure.message;
    if (failure is InvalidEmailFailure) return failure.message;
    return failure.message.isEmpty ? 'Authentication failed' : failure.message;
  }
}
