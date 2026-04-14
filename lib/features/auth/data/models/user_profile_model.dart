// json_annotation is imported to document that this model is part of the
// json_serializable ecosystem. The nested `company.name` → department mapping
// and the absence of any auto-generatable fields make full annotation redundant;
// fromJson and toJson are written manually below.
// ignore: unused_import
import 'package:json_annotation/json_annotation.dart';
import 'package:smart_campus/features/auth/domain/entities/user_profile.dart';

/// Deserializes a `/users` JSON object into a [UserProfile].
///
/// Custom [fromJson] is required because `department` is nested inside
/// the API's `company.name` object, which json_serializable cannot flatten
/// automatically via a single @JsonKey path annotation.
class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.name,
    required super.username,
    required super.email,
    required super.phone,
    required super.department,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      UserProfileModel(
        id: json['id'] as int,
        name: json['name'] as String,
        username: json['username'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String,
        department:
            (json['company'] as Map<String, dynamic>)['name'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'username': username,
        'email': email,
        'phone': phone,
        'department': department,
      };
}
