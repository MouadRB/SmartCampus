import 'package:equatable/equatable.dart';

import 'package:smart_campus/features/permissions/domain/entities/permission_type.dart';

/// Mirrors the 5-state pattern used by [AnnouncementsBloc] / [TimetableBloc]
/// (WEEK2 §3.2): one Initial, one Loading, and three terminal outcomes that
/// directly drive distinct UI behaviour. The three terminal outcomes —
/// granted / denied / permanently-denied — match FR-PERM-03's three-state
/// flow exactly.
abstract class PermissionsState extends Equatable {
  const PermissionsState();

  @override
  List<Object?> get props => [];
}

/// Bloc construction default. No content rendered.
class PermissionsInitial extends PermissionsState {
  const PermissionsInitial();
}

/// In-flight: a check or request is awaiting the OS. Gate widgets render a
/// neutral spinner during this state.
class PermissionsLoading extends PermissionsState {
  const PermissionsLoading();
}

/// FR-PERM-03 outcome: permission is held. The gate widget renders its
/// child.
class PermissionGranted extends PermissionsState {
  const PermissionGranted(this.type);

  final PermissionType type;

  @override
  List<Object?> get props => [type];
}

/// FR-PERM-03 State B: user denied the prompt this session. The gate
/// widget renders a rationale and a "Grant access" button that dispatches
/// [RequestPermissionRequested].
class PermissionDenied extends PermissionsState {
  const PermissionDenied(this.type, this.message);

  final PermissionType type;
  final String message;

  @override
  List<Object?> get props => [type, message];
}

/// FR-PERM-03 State C: the OS will no longer show the prompt — the user
/// must change the permission in system settings. The gate widget renders
/// an "Open Settings" button that dispatches [OpenSettingsRequested].
class PermissionPermanentlyDenied extends PermissionsState {
  const PermissionPermanentlyDenied(this.type, this.message);

  final PermissionType type;
  final String message;

  @override
  List<Object?> get props => [type, message];
}

/// Catch-all for non-permission failures (e.g., the package itself errored
/// at the platform-channel level). Gate widgets show a retryable error
/// view rather than the rationale or settings UI.
class PermissionsError extends PermissionsState {
  const PermissionsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
