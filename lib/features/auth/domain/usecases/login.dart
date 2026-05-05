import 'package:dartz/dartz.dart';

import 'package:smart_campus/core/error/failures.dart';
import 'package:smart_campus/features/auth/domain/entities/user_profile.dart';
import 'package:smart_campus/features/auth/domain/repositories/auth_repository.dart';

class Login {
  const Login(this.repository);

  final AuthRepository repository;

  Future<Either<Failure, UserProfile>> call({
    required String email,
    required String password,
  }) =>
      repository.login(email: email, password: password);
}
