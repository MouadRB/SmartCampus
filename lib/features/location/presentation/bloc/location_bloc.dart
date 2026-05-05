import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smart_campus/core/error/failures.dart';
import 'package:smart_campus/features/location/domain/entities/coordinates.dart';
import 'package:smart_campus/features/location/domain/usecases/get_current_location.dart';
import 'package:smart_campus/features/location/domain/usecases/watch_position.dart';
import 'package:smart_campus/features/location/presentation/bloc/location_event.dart';
import 'package:smart_campus/features/location/presentation/bloc/location_state.dart';

/// Routes [LocationEvent]s through the location use cases and emits exactly
/// one terminal [LocationState] per event. Two concurrency guarantees:
///
///   1. **Stream lifetime is bound to the bloc.** [TrackPosition] stores a
///      [StreamSubscription] that is cancelled on [StopTracking] and again
///      in [close]. No orphaned listeners survive the bloc disposal — same
///      correctness pattern as `ConnectivityBloc` (WEEK2 §4.1).
///
///   2. **Honours the No-Try-Catch invariant** (WEEK2 §3.2). Every failure
///      arrives as a typed [Failure] inside an [Either]; this class only
///      `.fold()`s — never `try`s.
class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc({
    required this.getCurrentLocation,
    required this.watchPosition,
  }) : super(const LocationInitial()) {
    on<RequestLocation>(_onRequest);
    on<TrackPosition>(_onTrack);
    on<StopTracking>(_onStop);
    on<PositionUpdated>(_onPositionUpdated);
  }

  final GetCurrentLocation getCurrentLocation;
  final WatchPosition watchPosition;

  StreamSubscription<Either<Failure, Coordinates>>? _subscription;

  Future<void> _onRequest(
    RequestLocation event,
    Emitter<LocationState> emit,
  ) async {
    emit(const LocationLoading());
    final result = await getCurrentLocation();
    _emitFromResult(result, emit, tracking: false);
  }

  Future<void> _onTrack(
    TrackPosition event,
    Emitter<LocationState> emit,
  ) async {
    // Re-dispatch is idempotent: cancel the previous subscription before
    // opening a new one so we never hold two OS listeners at once.
    await _subscription?.cancel();
    emit(const LocationLoading());
    _subscription = watchPosition().listen(
      (result) => add(PositionUpdated(result)),
    );
  }

  Future<void> _onStop(
    StopTracking event,
    Emitter<LocationState> emit,
  ) async {
    await _subscription?.cancel();
    _subscription = null;
    emit(const LocationInitial());
  }

  void _onPositionUpdated(
    PositionUpdated event,
    Emitter<LocationState> emit,
  ) {
    _emitFromResult(event.result, emit, tracking: true);
  }

  void _emitFromResult(
    Either<Failure, Coordinates> result,
    Emitter<LocationState> emit, {
    required bool tracking,
  }) {
    result.fold(
      (failure) {
        if (failure is PermissionFailure) {
          emit(LocationDenied(failure.message, permanent: failure.permanent));
        } else {
          emit(LocationError(failure.message));
        }
      },
      (coords) => emit(
        tracking ? LocationTracking(coords) : LocationGranted(coords),
      ),
    );
  }

  @override
  Future<void> close() async {
    // Mandatory: orphaning the subscription would keep an OS GPS listener
    // alive past the bloc's lifetime, draining battery and leaking memory.
    await _subscription?.cancel();
    _subscription = null;
    return super.close();
  }
}
