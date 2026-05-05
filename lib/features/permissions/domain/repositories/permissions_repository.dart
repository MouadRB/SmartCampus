import 'package:dartz/dartz.dart';

import 'package:smart_campus/core/error/failures.dart';
import 'package:smart_campus/features/permissions/domain/entities/permission_status.dart';
import 'package:smart_campus/features/permissions/domain/entities/permission_type.dart';

/// Abstract contract for the Permissions Gateway. The Data layer provides
/// the concrete implementation that wraps the `permission_handler` package.
///
/// Every method returns `Either<Failure, T>` so the Presentation layer never
/// needs a try/catch (matches the No-Try-Catch invariant from
/// WEEK2 §3.2 / WEEK3 §3.2).
abstract class PermissionsRepository {
  /// Reads the current status without prompting the user. Useful on app
  /// resume or before deciding whether to show a rationale dialog.
  Future<Either<Failure, PermissionStatus>> check(PermissionType type);

  /// Triggers the OS permission dialog. If the user has already permanently
  /// denied the permission, the OS will not show a dialog — the
  /// implementation must surface this as [PermissionStatus.permanentlyDenied]
  /// so the BLoC routes to the settings-redirect state (FR-PERM-03 State C).
  Future<Either<Failure, PermissionStatus>> request(PermissionType type);

  /// Opens the OS app-settings screen. Used after a permanent denial so the
  /// user can grant the permission manually. Returns `true` if the settings
  /// screen was successfully opened.
  Future<Either<Failure, bool>> openSettings();
}
