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

  /// Continuous fix stream, gated on permission state in exactly the same
  /// way as [getCurrentPosition]. Each emission is an [Either] so subscribers
  /// can handle a denied permission or a service-disabled error mid-stream
  /// without try/catch. The underlying OS subscription is owned by the
  /// caller's `StreamSubscription` and must be cancelled to stop sampling.
  Stream<Either<Failure, Coordinates>> watchPosition();
}
