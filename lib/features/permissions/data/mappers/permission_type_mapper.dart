import 'package:permission_handler/permission_handler.dart' as ph;

import 'package:smart_campus/features/permissions/domain/entities/permission_type.dart';

/// Translates the Domain [PermissionType] into the `permission_handler`
/// package's [ph.Permission] constant. Lives in the data layer so the
/// domain enum stays decoupled from the package.
///
/// [PermissionType.location] maps to [ph.Permission.location], which
/// requests `ACCESS_FINE_LOCATION` on Android and "When In Use" on iOS —
/// matching FR-PERM-02.
extension PermissionTypeMapper on PermissionType {
  ph.Permission toPackage() {
    switch (this) {
      case PermissionType.location:
        return ph.Permission.location;
      case PermissionType.camera:
        return ph.Permission.camera;
    }
  }
}
