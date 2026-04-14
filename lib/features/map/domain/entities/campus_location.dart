import 'package:equatable/equatable.dart';

class CampusLocation extends Equatable {
  const CampusLocation({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
  });

  final int id;
  final String name;

  /// Mapped from the API's nested `address.geo.lat` field.
  final double lat;

  /// Mapped from the API's nested `address.geo.lng` field.
  final double lng;

  @override
  List<Object?> get props => [id, name, lat, lng];
}
