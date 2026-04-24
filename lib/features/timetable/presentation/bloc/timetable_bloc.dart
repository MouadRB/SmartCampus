import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smart_campus/core/error/failures.dart';
import 'package:smart_campus/features/timetable/domain/repositories/tasks_repository.dart';
import 'timetable_event.dart';
import 'timetable_state.dart';

class TimetableBloc extends Bloc<TimetableEvent, TimetableState> {
  TimetableBloc({required this.repository}) : super(const TimetableInitial()) {
    on<FetchTimetable>(_onFetch);
    on<RefreshTimetable>(_onRefresh);
  }

  final TasksRepository repository;

  Future<void> _onFetch(
    FetchTimetable event,
    Emitter<TimetableState> emit,
  ) async {
    emit(const TimetableLoading());
    await _fetchAndEmit(emit);
  }

  Future<void> _onRefresh(
    RefreshTimetable event,
    Emitter<TimetableState> emit,
  ) async {
    // No Loading state — the RefreshIndicator widget provides its own spinner
    // so existing content stays visible rather than being replaced by shimmer.
    await _fetchAndEmit(emit);
  }

  /// Calls the repository and routes the Either result to the correct state.
  /// No try-catch: all exception handling was completed in the Repository layer.
  Future<void> _fetchAndEmit(Emitter<TimetableState> emit) async {
    final result = await repository.getTasks();
    result.fold(
      (failure) => failure is NetworkFailure
          ? emit(TimetableOffline(failure.message))
          : emit(TimetableError(failure.message)),
      (tasks) => emit(TimetableLoaded(tasks)),
    );
  }
}
