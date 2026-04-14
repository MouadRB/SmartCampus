import 'package:dartz/dartz.dart';
import 'package:smart_campus/core/datasources/remote_data_source.dart';
import 'package:smart_campus/core/error/exceptions.dart';
import 'package:smart_campus/core/error/failures.dart';
import 'package:smart_campus/features/events/domain/entities/event_media.dart';
import 'package:smart_campus/features/events/domain/repositories/events_repository.dart';

class EventsRepositoryImpl implements EventsRepository {
  EventsRepositoryImpl({required this.remoteDataSource});

  final SmartCampusRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<EventMedia>>> getEventGallery() async {
    try {
      final result = await remoteDataSource.getEventGallery();
      return Right(List<EventMedia>.from(result));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    }
  }
}
