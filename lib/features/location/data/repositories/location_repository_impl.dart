import 'package:dartz/dartz.dart';

import 'package:smart_campus/core/error/exceptions.dart';
import 'package:smart_campus/core/error/failures.dart';
import 'package:smart_campus/features/location/data/datasources/location_data_source.dart';
import 'package:smart_campus/features/location/domain/entities/coordinates.dart';
import 'package:smart_campus/features/location/domain/repositories/location_repository.dart';
import 'package:smart_campus/features/permissions/domain/entities/permission_status.dart';
import 'package:smart_campus/features/permissions/domain/entities/permission_type.dart';
import 'package:smart_campus/features/permissions/domain/repositories/permissions_repository.dart';

/// Concrete [LocationRepository]. Composes the [PermissionsRepository] so
/// every read of the GPS sensor is gated on a granted permission. The
/// Presentation layer never needs to chain a permission call before asking
/// for coordinates — the repository is the single arbitration point.
class LocationRepositoryImpl implements LocationRepository {
  const LocationRepositoryImpl({
    required this.permissionsRepository,
    required this.dataSource,
  });

  final PermissionsRepository permissionsRepository;
  final LocationDataSource dataSource;

  @override
  Future<Either<Failure, Coordinates>> getCurrentPosition() async {
    // 1. Resolve permission state. May trigger a request if currently denied.
    final permission = await _resolveLocationPermission();
    if (permission.isLeft()) {
      return permission.fold(
        (failure) => Left(failure),
        (_) => throw StateError('unreachable'),
      );
    }

    // 2. Permission granted — read the sensor.
    try {
      final coords = await dataSource.getCurrentPosition();
      return Right(coords);
    } on PermissionDeniedException catch (e) {
      return Left(PermissionFailure(message: e.message, permanent: e.permanent));
    } on LocationServiceDisabledException catch (e) {
      // OS-level location services are off — not a permission issue.
      // Treated as a server-class failure so the BLoC routes it to the
      // generic error state with a retry prompt.
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Returns `Right(granted)` only when the user has actively granted the
  /// Location permission (after a request if necessary). Every other
  /// outcome — denied, permanently denied, package error — is surfaced as
  /// `Left(PermissionFailure)` with the `permanent` flag set appropriately.
  Future<Either<Failure, PermissionStatus>> _resolveLocationPermission() async {
    final check = await permissionsRepository.check(PermissionType.location);

    return check.fold<Future<Either<Failure, PermissionStatus>>>(
      (failure) async => Left(failure),
      (status) async {
        if (status == PermissionStatus.granted) {
          return Right(status);
        }
        if (status == PermissionStatus.permanentlyDenied) {
          return const Left(
            PermissionFailure(
              message: 'Location permission permanently denied',
              permanent: true,
            ),
          );
        }
        // status == denied — prompt the user.
        final requested =
            await permissionsRepository.request(PermissionType.location);
        return requested.fold<Either<Failure, PermissionStatus>>(
          (failure) => Left(failure),
          (newStatus) {
            switch (newStatus) {
              case PermissionStatus.granted:
                return Right(newStatus);
              case PermissionStatus.permanentlyDenied:
                return const Left(
                  PermissionFailure(
                    message: 'Location permission permanently denied',
                    permanent: true,
                  ),
                );
              case PermissionStatus.denied:
                return const Left(
                  PermissionFailure(message: 'Location permission denied'),
                );
            }
          },
        );
      },
    );
  }
}
