import 'package:dartz/dartz.dart';
import 'package:smart_campus/core/datasources/remote_data_source.dart';
import 'package:smart_campus/core/error/exceptions.dart';
import 'package:smart_campus/core/error/failures.dart';
import 'package:smart_campus/features/map/domain/entities/campus_location.dart';
import 'package:smart_campus/features/map/domain/repositories/map_repository.dart';

class MapRepositoryImpl implements MapRepository {
  MapRepositoryImpl({required this.remoteDataSource});

  final SmartCampusRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<CampusLocation>>> getMapLocations() async {
    try {
      final result = await remoteDataSource.getMapLocations();
      return Right(List<CampusLocation>.from(result));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    }
  }
}
