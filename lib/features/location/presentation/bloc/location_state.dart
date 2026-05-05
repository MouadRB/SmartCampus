import 'package:equatable/equatable.dart';

import 'package:smart_campus/features/location/domain/entities/coordinates.dart';

/// Mirrors the 5-state pattern used by [PermissionsBloc] (WEEK4 §1) and
/// [AnnouncementsBloc] (WEEK2 §3.2): one Initial, one Loading, and three
/// terminal outcomes that drive distinct UI behaviour. Tracking emits a
/// dedicated [LocationTracking] state on every fix so the map can animate
/// the camera without ambiguity over whether a one-shot fix arrived.
abstract class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {
  const LocationInitial();
}

class LocationLoading extends LocationState {
  const LocationLoading();
}

/// Terminal outcome of a one-shot [RequestLocation]. Holds the most recent
/// fix until a new event is dispatched.
class LocationGranted extends LocationState {
  const LocationGranted(this.coordinates);

  final Coordinates coordinates;

  @override
  List<Object?> get props => [coordinates];
}

/// Continuous outcome of [TrackPosition]. A new instance is emitted on
/// every upstream fix so `BlocBuilder` rebuilds and the map animates.
class LocationTracking extends LocationState {
  const LocationTracking(this.coordinates);

  final Coordinates coordinates;

  @override
  List<Object?> get props => [coordinates];
}

/// Permission was denied. `permanent: true` means the OS will not prompt
/// again — the gate widget routes the user to system settings rather than
/// re-requesting.
class LocationDenied extends LocationState {
  const LocationDenied(this.message, {this.permanent = false});

  final String message;
  final bool permanent;

  @override
  List<Object?> get props => [message, permanent];
}

/// Catch-all for non-permission failures (services disabled, package error,
/// platform-channel error). UI shows a retry prompt.
class LocationError extends LocationState {
  const LocationError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
