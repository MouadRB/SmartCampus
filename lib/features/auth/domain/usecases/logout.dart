import 'package:dartz/dartz.dart';

import 'package:smart_campus/core/error/failures.dart';
import 'package:smart_campus/features/auth/domain/repositories/auth_repository.dart';

class Logout {
  const Logout(this.repository);

  final AuthRepository repository;

  Future<Either<Failure, Unit>> call() => repository.logout();
}
