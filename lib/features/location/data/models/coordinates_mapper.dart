import 'package:geolocator/geolocator.dart' as geo;

import 'package:smart_campus/features/location/domain/entities/coordinates.dart';

/// Translates the `geolocator` package's [geo.Position] into the pure
/// Domain [Coordinates] entity. Same Mechanism-2 pattern used for Drift
/// row → Entity translation in WEEK2 §1.2: defined entirely in the data
/// layer so the Domain entity has zero knowledge of the package type.
extension CoordinatesMapper on geo.Position {
  Coordinates toDomain() => Coordinates(
        latitude: latitude,
        longitude: longitude,
        accuracy: accuracy,
        timestamp: timestamp,
      );
}
