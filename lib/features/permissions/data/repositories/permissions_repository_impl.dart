import 'package:dartz/dartz.dart';

import 'package:smart_campus/core/error/failures.dart';
import 'package:smart_campus/features/permissions/data/datasources/permissions_data_source.dart';
import 'package:smart_campus/features/permissions/domain/entities/permission_status.dart';
import 'package:smart_campus/features/permissions/domain/entities/permission_type.dart';
import 'package:smart_campus/features/permissions/domain/repositories/permissions_repository.dart';

/// Concrete implementation of [PermissionsRepository]. Pass-through over the
/// data source under normal operation; catches every exception so the
/// Presentation layer never has to.
class PermissionsRepositoryImpl implements PermissionsRepository {
  const PermissionsRepositoryImpl({required this.dataSource});

  final PermissionsDataSource dataSource;

  @override
  Future<Either<Failure, PermissionStatus>> check(PermissionType type) async {
    try {
      final status = await dataSource.check(type);
      return Right(status);
    } catch (e) {
      return Left(PermissionFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PermissionStatus>> request(
    PermissionType type,
  ) async {
    try {
      final status = await dataSource.request(type);
      return Right(status);
    } catch (e) {
      return Left(PermissionFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> openSettings() async {
    try {
      final opened = await dataSource.openSettings();
      return Right(opened);
    } catch (e) {
      return Left(PermissionFailure(message: e.toString()));
    }
  }
}
