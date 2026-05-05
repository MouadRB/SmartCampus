import 'package:equatable/equatable.dart';

abstract class ActivitiesEvent extends Equatable {
  const ActivitiesEvent();

  @override
  List<Object?> get props => [];
}

/// Initial fetch — emits [ActivitiesLoading] before hitting the repo.
class FetchActivities extends ActivitiesEvent {
  const FetchActivities();
}

/// Pull-to-refresh. Skips the loading state so existing content stays
/// visible during the re-fetch (RefreshIndicator owns its own spinner).
class RefreshActivities extends ActivitiesEvent {
  const RefreshActivities();
}

/// Flips the local user's RSVP state for [activityId]. Optimistic — the
/// updated [Activity] is patched into the loaded list as soon as the
/// repo call returns `Right`.
class ToggleRsvp extends ActivitiesEvent {
  const ToggleRsvp(this.activityId);

  final int activityId;

  @override
  List<Object?> get props => [activityId];
}

/// Calendar-tab day tap. Stored in state so widgets can filter the
/// list to a single day.
class SelectCalendarDay extends ActivitiesEvent {
  const SelectCalendarDay(this.day);

  final DateTime day;

  @override
  List<Object?> get props => [day];
}
