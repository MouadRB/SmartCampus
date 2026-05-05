import 'package:permission_handler/permission_handler.dart' as ph;

import 'package:smart_campus/features/permissions/domain/entities/permission_status.dart';

/// Translates the `permission_handler` package's [ph.PermissionStatus] enum
/// into the pure Domain [PermissionStatus] enum. Lives in the data layer —
/// the domain entity has zero knowledge of the package.
///
/// `limited` (iOS 14+ photo library) and `provisional` (iOS notifications)
/// are folded into [PermissionStatus.granted] because they grant the user
/// functional access. `restricted` is folded into [PermissionStatus.denied]
/// because the app cannot proceed even though the user did not explicitly
/// deny — same UI handling required.
extension PermissionStatusMapper on ph.PermissionStatus {
  PermissionStatus toDomain() {
    if (isPermanentlyDenied) return PermissionStatus.permanentlyDenied;
    if (isGranted || isLimited || isProvisional) {
      return PermissionStatus.granted;
    }
    return PermissionStatus.denied;
  }
}
