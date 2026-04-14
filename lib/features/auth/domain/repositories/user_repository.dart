import 'package:dartz/dartz.dart';
import 'package:smart_campus/core/error/failures.dart';
import 'package:smart_campus/features/auth/domain/entities/user_profile.dart';

abstract class UserRepository {
  Future<Either<Failure, UserProfile>> getProfile();
}
