import 'package:dartz/dartz.dart';

import 'package:smart_campus/core/error/failures.dart';
import 'package:smart_campus/features/auth/domain/entities/user_profile.dart';

/// Contract for the authentication source. The mock impl keeps state
/// in-memory for the lifetime of the app process; a future real impl will
/// proxy a backend.
///
/// `signUp` registers a new account and signs the caller in atomically.
/// `login` checks credentials against existing accounts.
/// `logout` clears the current session.
/// `currentUser` returns the active session's profile, or `null` if signed
/// out.
abstract class AuthRepository {
  Future<Either<Failure, UserProfile>> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, UserProfile>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, Unit>> logout();

  UserProfile? get currentUser;

  /// Broadcasts auth changes (sign-in / sign-out). Emits the new user, or
  /// `null` when logged out. The gate widget listens here to swap routes.
  Stream<UserProfile?> get authChanges;
}
