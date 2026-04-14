import 'package:dartz/dartz.dart';
import 'package:smart_campus/core/datasources/remote_data_source.dart';
import 'package:smart_campus/core/error/exceptions.dart';
import 'package:smart_campus/core/error/failures.dart';
import 'package:smart_campus/features/auth/domain/entities/user_profile.dart';
import 'package:smart_campus/features/auth/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({required this.remoteDataSource});

  final SmartCampusRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, UserProfile>> getProfile() async {
    try {
      final result = await remoteDataSource.getProfile();
      return Right<Failure, UserProfile>(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    }
  }
}
