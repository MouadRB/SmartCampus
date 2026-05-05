import 'package:dartz/dartz.dart';

import 'package:smart_campus/core/error/failures.dart';
import 'package:smart_campus/features/location/domain/entities/coordinates.dart';
import 'package:smart_campus/features/location/domain/repositories/location_repository.dart';

/// Use case: subscribe to the user's continuous GPS fix stream. Permission
/// gating is handled inside the repository, so callers only need to
/// `.fold()` each emitted [Either]. The lifecycle of the underlying OS
/// stream is owned by the caller's [StreamSubscription] — cancel it to stop
/// sampling.
class WatchPosition {
  const WatchPosition(this.repository);

  final LocationRepository repository;

  Stream<Either<Failure, Coordinates>> call() => repository.watchPosition();
}
