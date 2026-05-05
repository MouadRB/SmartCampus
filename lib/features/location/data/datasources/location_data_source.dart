import 'package:geolocator/geolocator.dart' as geo;

import 'package:smart_campus/core/error/exceptions.dart';
import 'package:smart_campus/features/location/data/models/coordinates_mapper.dart';
import 'package:smart_campus/features/location/domain/entities/coordinates.dart';

/// Defines the thin gateway over the `geolocator` package. Speaks in pure
/// Domain types so the abstract interface is mockable in tests without
/// pulling in the package. Throws typed app-level exceptions; the
/// Repository translates them into [Failure]s.
abstract class LocationDataSource {
  Future<Coordinates> getCurrentPosition();

  /// Continuous fix stream. Surfaces every position update emitted by the OS
  /// after the supplied [distanceFilterMeters] has been travelled. The
  /// Repository wraps this for permission gating and Either translation.
  Stream<Coordinates> watchPosition({int distanceFilterMeters = 5});
}

class LocationDataSourceImpl implements LocationDataSource {
  const LocationDataSourceImpl();

  @override
  Future<Coordinates> getCurrentPosition() async {
    final servicesEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!servicesEnabled) {
      throw const LocationServiceDisabledException();
    }

    try {
      final position = await geo.Geolocator.getCurrentPosition();
      return position.toDomain();
    } on geo.LocationServiceDisabledException {
      throw const LocationServiceDisabledException();
    } on geo.PermissionDeniedException catch (e) {
      // Defensive: the Repository pre-checks permission, but a permission
      // could be revoked between the check and this call. Surface as our
      // app-level exception so the Repository can translate uniformly.
      throw PermissionDeniedException(message: e.message ?? 'Permission denied');
    }
  }

  @override
  Stream<Coordinates> watchPosition({int distanceFilterMeters = 5}) async* {
    final servicesEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!servicesEnabled) {
      throw const LocationServiceDisabledException();
    }

    final settings = geo.LocationSettings(
      accuracy: geo.LocationAccuracy.high,
      distanceFilter: distanceFilterMeters,
    );

    yield* geo.Geolocator.getPositionStream(locationSettings: settings)
        .map((position) => position.toDomain());
  }
}
