import 'package:equatable/equatable.dart';

import 'package:smart_campus/features/auth/domain/entities/user_profile.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Pre-restoration state. Never rendered — the gate kicks an
/// [AuthSessionRestored] event immediately on construction.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// In-flight sign-up or login. Buttons render their spinner; fields stay
/// disabled.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated session.
///
/// `isFirstSession` is true when the user just signed up, false when they
/// logged in to an existing account. The home dashboard branches on this
/// to decide whether to auto-fetch announcements / timetable / activities.
class Authenticated extends AuthState {
  const Authenticated({
    required this.user,
    required this.isFirstSession,
  });

  final UserProfile user;
  final bool isFirstSession;

  @override
  List<Object?> get props => [user, isFirstSession];
}

/// Not signed in — the gate renders [LoginPage].
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Sign-up or login failed. Carries a human-readable message for the form
/// to surface inline. Transitions back to [Unauthenticated] on
/// [AuthErrorCleared] so the form can be re-submitted.
class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
