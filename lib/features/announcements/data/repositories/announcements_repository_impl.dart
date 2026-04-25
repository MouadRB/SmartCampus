import 'package:dartz/dartz.dart';

import 'package:smart_campus/core/datasources/remote_data_source.dart';
import 'package:smart_campus/core/error/exceptions.dart';
import 'package:smart_campus/core/error/failures.dart';
import 'package:smart_campus/features/announcements/data/datasources/announcement_local_data_source.dart';
import 'package:smart_campus/features/announcements/domain/entities/announcement.dart';
import 'package:smart_campus/features/announcements/domain/repositories/announcements_repository.dart';

class AnnouncementsRepositoryImpl implements AnnouncementsRepository {
  AnnouncementsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final SmartCampusRemoteDataSource remoteDataSource;
  final AnnouncementLocalDataSource localDataSource;

  @override
  Future<Either<Failure, List<Announcement>>> getAnnouncements() async {
    try {
      final remote = await remoteDataSource.getAnnouncements();

      // Cache is best-effort: a write failure must not hide fresh data.
      try {
        await localDataSource.cacheAnnouncements(
          List<Announcement>.from(remote),
        );
      } on CacheException catch (_) {
        // Swallow — the user still receives the freshly-fetched data.
      }

      return Right(List<Announcement>.from(remote));
    } on ServerException catch (e) {
      // Server is reachable but returned an error — do not touch the cache.
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      // Device is offline or the request timed out — attempt cache fallback.
      try {
        final cached = await localDataSource.getCachedAnnouncements();
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
