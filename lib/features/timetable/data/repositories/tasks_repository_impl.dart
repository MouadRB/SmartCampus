import 'package:dartz/dartz.dart';

import 'package:smart_campus/core/datasources/remote_data_source.dart';
import 'package:smart_campus/core/error/exceptions.dart';
import 'package:smart_campus/core/error/failures.dart';
import 'package:smart_campus/features/timetable/data/datasources/timetable_local_data_source.dart';
import 'package:smart_campus/features/timetable/domain/entities/campus_task.dart';
import 'package:smart_campus/features/timetable/domain/repositories/tasks_repository.dart';

class TasksRepositoryImpl implements TasksRepository {
  TasksRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final SmartCampusRemoteDataSource remoteDataSource;
  final TimetableLocalDataSource localDataSource;

  @override
  Future<Either<Failure, List<CampusTask>>> getTasks() async {
    try {
      final remote = await remoteDataSource.getTasks();

      // Cache is best-effort: a write failure must not hide fresh data.
      try {
        await localDataSource.cacheTasks(List<CampusTask>.from(remote));
      } on CacheException catch (_) {
        // Swallow — the user still receives the freshly-fetched data.
      }

      return Right(List<CampusTask>.from(remote));
    } on ServerException catch (e) {
      // Server is reachable but returned an error — do not touch the cache.
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      // Device is offline or the request timed out — attempt cache fallback.
      try {
        final cached = await localDataSource.getCachedTasks();
        if (cached.isEmpty) {
          // Nothing in the cache — surface the original network error so the
          // UI shows the offline banner with a retry prompt instead of an
          // empty screen with no explanation.
          return Left(NetworkFailure(message: e.message));
        }
        return Right(cached);
      } on CacheException catch (ce) {
        return Left(CacheFailure(message: ce.message));
      }
    }
  }
}
