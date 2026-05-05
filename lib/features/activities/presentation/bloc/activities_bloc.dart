import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smart_campus/features/activities/domain/repositories/activities_repository.dart';
import 'activities_event.dart';
import 'activities_state.dart';

/// State machine for the Activities feature. Holds the loaded list, the
/// calendar's selected day, and routes RSVP toggles through the repo.
///
/// Pure `.fold()` discipline — no `try`/`catch` here. All exception
/// translation already happened in the repository.
class ActivitiesBloc extends Bloc<ActivitiesEvent, ActivitiesState> {
  ActivitiesBloc({required this.repository})
      : super(const ActivitiesInitial()) {
    on<FetchActivities>(_onFetch);
    on<RefreshActivities>(_onRefresh);
    on<ToggleRsvp>(_onToggleRsvp);
    on<SelectCalendarDay>(_onSelectDay);
  }

  final ActivitiesRepository repository;

  Future<void> _onFetch(
    FetchActivities event,
    Emitter<ActivitiesState> emit,
  ) async {
    emit(const ActivitiesLoading());
    await _fetchAndEmit(emit);
  }

  Future<void> _onRefresh(
    RefreshActivities event,
    Emitter<ActivitiesState> emit,
  ) async {
    // No loading state — RefreshIndicator owns its own spinner.
    await _fetchAndEmit(emit);
  }

  Future<void> _fetchAndEmit(Emitter<ActivitiesState> emit) async {
    final result = await repository.getUpcomingActivities();
    result.fold(
      (failure) => emit(ActivitiesError(
        failure.message.isEmpty ? 'Could not load activities' : failure.message,
      )),
      (activities) => emit(ActivitiesLoaded(
        activities: activities,
        selectedDay: _initialSelectedDay(activities),
      )),
    );
  }

  Future<void> _onToggleRsvp(
    ToggleRsvp event,
    Emitter<ActivitiesState> emit,
  ) async {
    final current = state;
    if (current is! ActivitiesLoaded) return;

    final result = await repository.toggleRsvp(event.activityId);
    result.fold(
      (failure) => emit(ActivitiesError(
        failure.message.isEmpty ? 'RSVP failed' : failure.message,
      )),
      (updated) {
        final next = current.activities
            .map((a) => a.id == updated.id ? updated : a)
            .toList(growable: false);
        emit(current.copyWith(activities: next));
      },
    );
  }

  void _onSelectDay(
    SelectCalendarDay event,
    Emitter<ActivitiesState> emit,
  ) {
    final current = state;
    if (current is! ActivitiesLoaded) return;
    emit(current.copyWith(selectedDay: _dateOnly(event.day)));
  }

  /// Default selected day = the date of the soonest upcoming activity, or
  /// today's date if the list is empty.
  DateTime _initialSelectedDay(List activities) {
    if (activities.isEmpty) return _dateOnly(DateTime.now());
    return _dateOnly(activities.first.startsAt as DateTime);
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
