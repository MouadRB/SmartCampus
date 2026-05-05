import 'package:dartz/dartz.dart';

import 'package:smart_campus/core/error/failures.dart';
import 'package:smart_campus/features/auth/domain/entities/user_profile.dart';
import 'package:smart_campus/features/auth/domain/repositories/auth_repository.dart';

class SignUp {
  const SignUp(this.repository);

  final AuthRepository repository;

  Future<Either<Failure, UserProfile>> call({
    required String name,
    required String email,
    required String password,
  }) =>
      repository.signUp(name: name, email: email, password: password);
}
