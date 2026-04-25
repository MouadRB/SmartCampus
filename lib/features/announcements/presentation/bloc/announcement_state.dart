import 'package:equatable/equatable.dart';

import 'package:smart_campus/features/announcements/domain/entities/announcement.dart';

abstract class AnnouncementsState extends Equatable {
  const AnnouncementsState();
}

/// The BLoC's initial state before any event has been dispatched.
class AnnouncementsInitial extends AnnouncementsState {
  const AnnouncementsInitial();

  @override
  List<Object?> get props => [];
}

/// Emitted while the repository call is in flight. The UI renders shimmer
/// placeholders during this state (FR-NET-05).
class AnnouncementsLoading extends AnnouncementsState {
  const AnnouncementsLoading();

  @override
  List<Object?> get props => [];
}

/// Emitted when the repository returns a [Right] — either fresh data from the
/// remote source or a non-empty list from the local cache fallback.
class AnnouncementsLoaded extends AnnouncementsState {
  const AnnouncementsLoaded(this.announcements);

  final List<Announcement> announcements;

  @override
  List<Object?> get props => [announcements];
}

/// Emitted when the repository returns a [Left(ServerFailure)] or
/// [Left(CacheFailure)]. The UI renders an error prompt with [message]
/// and a retry button.
class AnnouncementsError extends AnnouncementsState {
  const AnnouncementsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Emitted when the repository returns a [Left(NetworkFailure)] — the device
/// is offline or the request timed out AND the local cache is empty.
/// The UI renders the persistent amber offline banner (FR-NET-05).
class AnnouncementsOffline extends AnnouncementsState {
  const AnnouncementsOffline(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
