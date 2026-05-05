import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:smart_campus/core/error/failures.dart';
import 'package:smart_campus/features/location/domain/entities/coordinates.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object?> get props => [];
}

/// Resolves a single GPS fix via [GetCurrentLocation]. Use for one-shot
/// reads (check-ins, attendance markers); the result lives in
/// [LocationGranted] until a new event arrives.
class RequestLocation extends LocationEvent {
  const RequestLocation();
}

/// Subscribes to the continuous fix stream via [WatchPosition]. Each
/// upstream fix becomes a [LocationTracking] state; a denied permission or
/// disabled service mid-stream becomes [LocationDenied] / generic
/// [LocationError]. Re-dispatching cancels the previous subscription before
/// starting a new one.
class TrackPosition extends LocationEvent {
  const TrackPosition();
}

/// Cancels the active stream subscription (if any) and parks the bloc in
/// [LocationInitial]. Dispatched when the consumer no longer needs live
/// updates — for the Campus Map, this fires implicitly when the bloc is
/// closed by the route popping.
class StopTracking extends LocationEvent {
  const StopTracking();
}

/// Internal event: each upstream emission from `watchPosition()` is funnelled
/// through `add()` so all state transitions flow through the bloc's event
/// handler — keeps the No-Try-Catch invariant intact (.fold() only).
class PositionUpdated extends LocationEvent {
  const PositionUpdated(this.result);

  final Either<Failure, Coordinates> result;

  @override
  List<Object?> get props => [result];
}
