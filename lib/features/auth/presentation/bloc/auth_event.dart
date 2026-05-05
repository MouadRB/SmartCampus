import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Fired by the gate at app start. Restores the existing in-memory session
/// (none on cold start) and emits the right state without showing a spinner.
class AuthSessionRestored extends AuthEvent {
  const AuthSessionRestored();
}

/// Sign-up form submission. The repository validates email + password
/// shape; the bloc just `.fold()`s the result.
class AuthSignUpRequested extends AuthEvent {
  const AuthSignUpRequested({
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;

  @override
  List<Object?> get props => [name, email, password];
}

class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Clears the current error message after a transient prompt has been
/// shown (e.g. SnackBar dismissed, user starts typing again).
class AuthErrorCleared extends AuthEvent {
  const AuthErrorCleared();
}
