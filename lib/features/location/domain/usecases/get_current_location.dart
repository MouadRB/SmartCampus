import 'package:dartz/dartz.dart';

import 'package:smart_campus/core/error/failures.dart';
import 'package:smart_campus/features/location/domain/entities/coordinates.dart';
import 'package:smart_campus/features/location/domain/repositories/location_repository.dart';

/// Use case: resolve the user's current GPS position. The repository handles
/// permission gating internally, so callers only need to interpret the
/// returned `Either`.
class GetCurrentLocation {
  const GetCurrentLocation(this.repository);

  final LocationRepository repository;

  Future<Either<Failure, Coordinates>> call() =>
      repository.getCurrentPosition();
}
