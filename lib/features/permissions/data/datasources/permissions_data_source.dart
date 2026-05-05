import 'package:permission_handler/permission_handler.dart' as ph;

import 'package:smart_campus/features/permissions/data/mappers/permission_status_mapper.dart';
import 'package:smart_campus/features/permissions/data/mappers/permission_type_mapper.dart';
import 'package:smart_campus/features/permissions/domain/entities/permission_status.dart';
import 'package:smart_campus/features/permissions/domain/entities/permission_type.dart';

/// Defines the thin gateway over the `permission_handler` package. Speaks
/// in pure Domain types so the abstract interface is mockable in tests
/// without pulling in the package.
abstract class PermissionsDataSource {
  Future<PermissionStatus> check(PermissionType type);

  Future<PermissionStatus> request(PermissionType type);

  Future<bool> openSettings();
}

class PermissionsDataSourceImpl implements PermissionsDataSource {
  const PermissionsDataSourceImpl();

  @override
  Future<PermissionStatus> check(PermissionType type) async {
    final raw = await type.toPackage().status;
    return raw.toDomain();
  }

  @override
  Future<PermissionStatus> request(PermissionType type) async {
    final raw = await type.toPackage().request();
    return raw.toDomain();
  }

  @override
  Future<bool> openSettings() => ph.openAppSettings();
}
