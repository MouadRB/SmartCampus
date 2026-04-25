import 'package:equatable/equatable.dart';

abstract class AnnouncementsEvent extends Equatable {
  const AnnouncementsEvent();
}

/// Fired on initial screen load. Emits [AnnouncementsLoading] before fetching.
class FetchAnnouncements extends AnnouncementsEvent {
  const FetchAnnouncements();

  @override
  List<Object?> get props => [];
}

/// Fired by the [RefreshIndicator] on pull-to-refresh. Does NOT emit
/// [AnnouncementsLoading] — the widget provides its own spinner, so existing
/// content stays visible during the refresh.
class RefreshAnnouncements extends AnnouncementsEvent {
  const RefreshAnnouncements();

  @override
  List<Object?> get props => [];
}
