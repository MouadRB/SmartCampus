import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dartz/dartz.dart';

import 'package:smart_campus/core/error/failures.dart';
import 'package:smart_campus/features/auth/data/models/mock_account.dart';
import 'package:smart_campus/features/auth/domain/entities/user_profile.dart';
import 'package:smart_campus/features/auth/domain/repositories/auth_repository.dart';

/// In-memory authentication store. Accounts live for the lifetime of the
/// app process — a cold restart wipes the registry, so Login fails for any
/// previously-signed-up user until they Sign Up again.
///
/// Password storage uses SHA-256 (not bcrypt/argon2) because this is a
/// mock — sufficient to demonstrate that plaintext is never persisted.
class MockAuthRepositoryImpl implements AuthRepository {
  MockAuthRepositoryImpl();

  final Map<String, MockAccount> _accounts = {};
  final StreamController<UserProfile?> _changes =
      StreamController<UserProfile?>.broadcast();

  UserProfile? _current;
  int _nextId = 1;

  static const Duration _latency = Duration(milliseconds: 350);
  static const int _minPasswordLen = 6;
  static final RegExp _emailRe =
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  @override
  UserProfile? get currentUser => _current;

  @override
  Stream<UserProfile?> get authChanges => _changes.stream;

  @override
  Future<Either<Failure, UserProfile>> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(_latency);

    final normalisedEmail = email.trim().toLowerCase();
    if (!_emailRe.hasMatch(normalisedEmail)) {
      return const Left(InvalidEmailFailure());
    }
    if (password.length < _minPasswordLen) {
      return const Left(WeakPasswordFailure());
    }
    if (_accounts.containsKey(normalisedEmail)) {
      return const Left(EmailAlreadyRegisteredFailure());
    }

    final profile = UserProfile(
      id: _nextId++,
      name: name.trim(),
      username: _usernameFrom(name),
      email: normalisedEmail,
      phone: '',
      department: '',
    );
    _accounts[normalisedEmail] = MockAccount(
      email: normalisedEmail,
      passwordHash: _hash(password),
      profile: profile,
    );

    _current = profile;
    _changes.add(profile);
    return Right<Failure, UserProfile>(profile);
  }

  @override
  Future<Either<Failure, UserProfile>> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(_latency);

    final normalisedEmail = email.trim().toLowerCase();
    if (!_emailRe.hasMatch(normalisedEmail)) {
      return const Left(InvalidEmailFailure());
    }

    final account = _accounts[normalisedEmail];
    if (account == null || account.passwordHash != _hash(password)) {
      return const Left(InvalidCredentialsFailure());
    }

    _current = account.profile;
    _changes.add(account.profile);
    return Right<Failure, UserProfile>(account.profile);
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    await Future<void>.delayed(_latency);
    _current = null;
    _changes.add(null);
    return const Right<Failure, Unit>(unit);
  }

  String _hash(String input) =>
      sha256.convert(utf8.encode(input)).toString();

  String _usernameFrom(String name) {
    final cleaned = name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '.');
    return cleaned.isEmpty ? 'student' : cleaned;
  }
}
