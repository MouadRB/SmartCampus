import 'package:dartz/dartz.dart';
import 'package:smart_campus/core/datasources/remote_data_source.dart';
import 'package:smart_campus/core/error/exceptions.dart';
import 'package:smart_campus/core/error/failures.dart';
import 'package:smart_campus/features/timetable/domain/entities/campus_task.dart';
import 'package:smart_campus/features/timetable/domain/repositories/tasks_repository.dart';

class TasksRepositoryImpl implements TasksRepository {
  TasksRepositoryImpl({required this.remoteDataSource});

  final SmartCampusRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<CampusTask>>> getTasks() async {
    try {
      final result = await remoteDataSource.getTasks();
      return Right(List<CampusTask>.from(result));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    }
  }
}
