import 'package:dartz/dartz.dart';
import 'package:smart_campus/core/error/failures.dart';
import 'package:smart_campus/features/map/domain/entities/campus_location.dart';

abstract class MapRepository {
  Future<Either<Failure, List<CampusLocation>>> getMapLocations();
}
