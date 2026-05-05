import 'package:equatable/equatable.dart';

/// Pure Domain entity representing a single GPS fix. Has zero knowledge of
/// the `geolocator` package — the Data layer's `CoordinatesMapper` extension
/// translates the package's `Position` type to this entity.
class Coordinates extends Equatable {
  const Coordinates({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
  });

  /// Decimal degrees, WGS-84.
  final double latitude;
  final double longitude;

  /// Estimated horizontal accuracy in metres. Smaller is better.
  final double accuracy;

  /// When the fix was recorded by the OS.
  final DateTime timestamp;

  @override
  List<Object?> get props => [latitude, longitude, accuracy, timestamp];
}
