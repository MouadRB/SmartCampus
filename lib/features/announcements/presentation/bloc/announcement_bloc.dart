import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smart_campus/core/error/failures.dart';
import 'package:smart_campus/features/announcements/domain/repositories/announcements_repository.dart';
import 'announcement_event.dart';
import 'announcement_state.dart';

class AnnouncementsBloc extends Bloc<AnnouncementsEvent, AnnouncementsState> {
  AnnouncementsBloc({required this.repository})
      : super(const AnnouncementsInitial()) {
    on<FetchAnnouncements>(_onFetch);
    on<RefreshAnnouncements>(_onRefresh);
  }

  final AnnouncementsRepository repository;

  Future<void> _onFetch(
    FetchAnnouncements event,
    Emitter<AnnouncementsState> emit,
  ) async {
    emit(const AnnouncementsLoading());
    await _fetchAndEmit(emit);
  }

  Future<void> _onRefresh(
    RefreshAnnouncements event,
    Emitter<AnnouncementsState> emit,
  ) async {
    // No Loading state — the RefreshIndicator widget provides its own spinner
    // so existing content stays visible rather than being replaced by shimmer.
    await _fetchAndEmit(emit);
  }

  /// Calls the repository and routes the Either result to the correct state.
  /// No try-catch: all exception handling was completed in the Repository layer.
  Future<void> _fetchAndEmit(Emitter<AnnouncementsState> emit) async {
    final result = await repository.getAnnouncements();
    result.fold(
      (failure) => failure is NetworkFailure
          ? emit(AnnouncementsOffline(failure.message))
          : emit(AnnouncementsError(failure.message)),
      (announcements) => emit(AnnouncementsLoaded(announcements)),
    );
  }
}
