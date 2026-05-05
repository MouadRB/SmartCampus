import 'package:dartz/dartz.dart';

import 'package:smart_campus/core/error/failures.dart';
import 'package:smart_campus/features/location/domain/entities/coordinates.dart';

/// Abstract contract for the device location source.
///
/// The implementation **composes** the [PermissionsRepository] internally:
/// every call gates on permission state and returns `Left(PermissionFailure)`
/// when the user has not granted Location. Presentation never has to chain
/// a permission check before requesting coordinates.
///
/// Streaming (`watchPosition`) is intentionally deferred to the Campus Map
/// task in Week 4-mid; until then this interface only exposes a one-shot
/// `getCurrentPosition` method.
abstract class LocationRepository {
  /// Returns the user's current position as a single fix.
  ///
  /// Possible left branches:
  ///   * `PermissionFailure(permanent: false)`  → user denied; UI should
  ///     show a rationale and offer to retry.
  ///   * `PermissionFailure(permanent: true)`   → user permanently denied;
  ///     UI should redirect to system settings.
  ///   * `ServerFailure`                        → location services are
  ///     disabled at the OS level (treated as a server-class failure since
  ///     it is not a network problem and not a permission problem).
  Future<Either<Failure, Coordinates>> getCurrentPosition();
}
