import 'package:smart_campus/features/auth/domain/entities/user_profile.dart';
import 'package:smart_campus/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUser {
  const GetCurrentUser(this.repository);

  final AuthRepository repository;

  UserProfile? call() => repository.currentUser;
}
