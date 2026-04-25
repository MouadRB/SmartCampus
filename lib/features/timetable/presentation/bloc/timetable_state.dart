import 'package:equatable/equatable.dart';

import 'package:smart_campus/features/timetable/domain/entities/campus_task.dart';

abstract class TimetableState extends Equatable {
  const TimetableState();
}

/// The BLoC's initial state before any event has been dispatched.
class TimetableInitial extends TimetableState {
  const TimetableInitial();

  @override
  List<Object?> get props => [];
}

/// Emitted while the repository call is in flight. The UI renders shimmer
/// placeholders during this state (FR-NET-05).
class TimetableLoading extends TimetableState {
  const TimetableLoading();

  @override
  List<Object?> get props => [];
}

/// Emitted when the repository returns a [Right] — either fresh data from the
/// remote source or a non-empty list from the local cache fallback.
class TimetableLoaded extends TimetableState {
  const TimetableLoaded(this.tasks);

  final List<CampusTask> tasks;

  @override
  List<Object?> get props => [tasks];
}

/// Emitted when the repository returns a [Left(ServerFailure)] or
/// [Left(CacheFailure)]. The UI renders an error prompt with [message]
/// and a retry button.
class TimetableError extends TimetableState {
  const TimetableError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Emitted when the repository returns a [Left(NetworkFailure)] — the device
/// is offline or the request timed out AND the local cache is empty.
/// The UI renders the persistent amber offline banner (FR-NET-05).
class TimetableOffline extends TimetableState {
  const TimetableOffline(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
