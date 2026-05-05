import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure();

  /// Human-readable description of the failure, propagated to the UI as the
  /// error message string displayed alongside the retry prompt (FR-NET-05).
  /// Concrete subclasses satisfy this via their [final String message] field.
  String get message;
}

class ServerFailure extends Failure {
  const ServerFailure({this.message = ''});

  final String message;

  @override
  List<Object?> get props => [message];
}

class CacheFailure extends Failure {
  const CacheFailure({this.message = ''});

  final String message;

  @override
  List<Object?> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure({this.message = ''});

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Surfaces a denied / permanently-denied runtime permission to the
/// Presentation layer. `permanent` lets the BLoC distinguish FR-PERM-03
/// State B (rationale dialog + retry) from State C (settings redirect).
class PermissionFailure extends Failure {
  const PermissionFailure({this.message = '', this.permanent = false});

  final String message;
  final bool permanent;

  @override
  List<Object?> get props => [message, permanent];
}

// ── Auth failures (mock-backed for now; same shape will fit a real backend).

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure(
      {this.message = 'Invalid email or password'});

  final String message;

  @override
  List<Object?> get props => [message];
}

class EmailAlreadyRegisteredFailure extends Failure {
  const EmailAlreadyRegisteredFailure(
      {this.message = 'An account with this email already exists'});

  final String message;

  @override
  List<Object?> get props => [message];
}

class WeakPasswordFailure extends Failure {
  const WeakPasswordFailure(
      {this.message = 'Password must be at least 6 characters'});

  final String message;

  @override
  List<Object?> get props => [message];
}

class InvalidEmailFailure extends Failure {
  const InvalidEmailFailure({this.message = 'Enter a valid email address'});

  final String message;

  @override
  List<Object?> get props => [message];
}
