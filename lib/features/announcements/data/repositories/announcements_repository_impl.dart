import 'package:dartz/dartz.dart';
import 'package:smart_campus/core/datasources/remote_data_source.dart';
import 'package:smart_campus/core/error/exceptions.dart';
import 'package:smart_campus/core/error/failures.dart';
import 'package:smart_campus/features/announcements/domain/entities/announcement.dart';
import 'package:smart_campus/features/announcements/domain/repositories/announcements_repository.dart';

class AnnouncementsRepositoryImpl implements AnnouncementsRepository {
  AnnouncementsRepositoryImpl({required this.remoteDataSource});

  final SmartCampusRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<Announcement>>> getAnnouncements() async {
    try {
      final result = await remoteDataSource.getAnnouncements();
      return Right(List<Announcement>.from(result));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    }
  }
}
