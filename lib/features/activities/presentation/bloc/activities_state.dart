import 'package:equatable/equatable.dart';

import 'package:smart_campus/features/activities/domain/entities/activity.dart';

abstract class ActivitiesState extends Equatable {
  const ActivitiesState();

  @override
  List<Object?> get props => [];
}

/// BLoC's initial state before any event has been dispatched.
class ActivitiesInitial extends ActivitiesState {
  const ActivitiesInitial();
}

/// Emitted while the initial fetch is in flight. UI shows the shimmer
/// skeleton list during this state.
class ActivitiesLoading extends ActivitiesState {
  const ActivitiesLoading();
}

/// Emitted on `Right(activities)`. Carries the full list plus the
/// currently-selected calendar day so the Calendar tab can filter.
class ActivitiesLoaded extends ActivitiesState {
  const ActivitiesLoaded({
    required this.activities,
    required this.selectedDay,
  });

  final List<Activity> activities;
  final DateTime selectedDay;

  ActivitiesLoaded copyWith({
    List<Activity>? activities,
    DateTime? selectedDay,
  }) =>
      ActivitiesLoaded(
        activities: activities ?? this.activities,
        selectedDay: selectedDay ?? this.selectedDay,
      );

  @override
  List<Object?> get props => [activities, selectedDay];
}

/// Emitted on `Left(failure)`. UI renders an error prompt + retry CTA.
class ActivitiesError extends ActivitiesState {
  const ActivitiesError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
