import 'package:equatable/equatable.dart';

import 'package:smart_campus/features/permissions/domain/entities/permission_type.dart';

abstract class PermissionsEvent extends Equatable {
  const PermissionsEvent();

  @override
  List<Object?> get props => [];
}

/// Reads the current status of [type] without prompting the user. Used on
/// app resume or by [LocationPermissionGate.initState] before deciding
/// whether to render a rationale.
class CheckPermissionRequested extends PermissionsEvent {
  const CheckPermissionRequested(this.type);

  final PermissionType type;

  @override
  List<Object?> get props => [type];
}

/// Triggers the OS permission dialog for [type]. Called by the
/// rationale-state UI when the user taps "Grant access".
class RequestPermissionRequested extends PermissionsEvent {
  const RequestPermissionRequested(this.type);

  final PermissionType type;

  @override
  List<Object?> get props => [type];
}

/// Opens the OS app-settings screen. Called by the permanent-denial UI so
/// the user can flip the permission manually (FR-PERM-03 State C).
class OpenSettingsRequested extends PermissionsEvent {
  const OpenSettingsRequested();
}
