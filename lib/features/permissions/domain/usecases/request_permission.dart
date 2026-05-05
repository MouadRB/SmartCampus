import 'package:dartz/dartz.dart';

import 'package:smart_campus/core/error/failures.dart';
import 'package:smart_campus/features/permissions/domain/entities/permission_status.dart';
import 'package:smart_campus/features/permissions/domain/entities/permission_type.dart';
import 'package:smart_campus/features/permissions/domain/repositories/permissions_repository.dart';

/// Use case: trigger the OS permission dialog and resolve the user's choice.
class RequestPermission {
  const RequestPermission(this.repository);

  final PermissionsRepository repository;

  Future<Either<Failure, PermissionStatus>> call(PermissionType type) =>
      repository.request(type);
}
