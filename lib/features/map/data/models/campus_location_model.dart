// json_annotation is imported to document that this model is part of the
// json_serializable ecosystem. The doubly-nested `address.geo.lat/lng` mapping
// requires manual extraction; json_serializable cannot resolve two fields from
// the same parent JSON key via @JsonKey alone.
// ignore: unused_import
import 'package:json_annotation/json_annotation.dart';
import 'package:smart_campus/features/map/domain/entities/campus_location.dart';

/// Deserializes a `/users` JSON object into a [CampusLocation].
///
/// Custom [fromJson] is required because `lat` and `lng` are doubly nested
/// inside `address.geo`, and both fields originate from the same parent JSON
/// key — a case json_serializable cannot resolve with @JsonKey alone.
class CampusLocationModel extends CampusLocation {
  const CampusLocationModel({
    required super.id,
    required super.name,
    required super.lat,
    required super.lng,
  });

  factory CampusLocationModel.fromJson(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>;
    final geo = address['geo'] as Map<String, dynamic>;
    return CampusLocationModel(
      id: json['id'] as int,
      name: json['name'] as String,
      lat: double.parse(geo['lat'] as String),
      lng: double.parse(geo['lng'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'lat': lat,
        'lng': lng,
      };
}
