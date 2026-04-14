import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.department,
  });

  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;

  /// Mapped from the API's nested `company.name` field.
  final String department;

  @override
  List<Object?> get props => [id, name, username, email, phone, department];
}
