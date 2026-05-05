import 'package:dartz/dartz.dart';

import 'package:smart_campus/core/error/failures.dart';
import 'package:smart_campus/features/permissions/domain/repositories/permissions_repository.dart';

/// Use case: open the OS app-settings screen so the user can manually grant
/// a permission they previously denied permanently (FR-PERM-03 State C).
class OpenAppSettings {
  const OpenAppSettings(this.repository);

  final PermissionsRepository repository;

  Future<Either<Failure, bool>> call() => repository.openSettings();
}
