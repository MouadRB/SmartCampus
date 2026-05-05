import 'package:smart_campus/features/auth/domain/entities/user_profile.dart';

/// Internal data-layer record for the in-memory auth store. Carries the
/// password hash next to the profile so the repository can verify
/// credentials without exposing them through the Domain contract.
///
/// Stays inside `data/` — never imported from `presentation/` or `domain/`.
class MockAccount {
  const MockAccount({
    required this.email,
    required this.passwordHash,
    required this.profile,
  });

  final String email;
  final String passwordHash;
  final UserProfile profile;
}
