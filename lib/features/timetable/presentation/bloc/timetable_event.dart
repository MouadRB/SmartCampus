import 'package:equatable/equatable.dart';

abstract class TimetableEvent extends Equatable {
  const TimetableEvent();
}

/// Fired on initial screen load. Emits [TimetableLoading] before fetching.
class FetchTimetable extends TimetableEvent {
  const FetchTimetable();

  @override
  List<Object?> get props => [];
}

/// Fired by the [RefreshIndicator] on pull-to-refresh. Does NOT emit
/// [TimetableLoading] — the widget provides its own spinner, so existing
/// content stays visible during the refresh.
class RefreshTimetable extends TimetableEvent {
  const RefreshTimetable();

  @override
  List<Object?> get props => [];
}

// ExportSchedule is deferred to the export sprint (requires path_provider
// + JSON serialization logic not yet implemented end-to-end).
