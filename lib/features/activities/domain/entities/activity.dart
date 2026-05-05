import 'package:equatable/equatable.dart';

/// Local-only RSVP state. The mock repository updates it in-memory; once a
/// remote endpoint exists this enum will be the same shape received over the
/// wire, so widgets won't need to change.
enum RsvpStatus { none, going }

/// Pure Domain entity representing a single campus activity. Has zero
/// knowledge of the Data layer — `ActivityModel` extends this class (LSP) so
/// JSON / DB rows translate into the same shape the Presentation layer
/// already consumes.
class Activity extends Equatable {
  const Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.startsAt,
    required this.location,
    required this.category,
    required this.attendance,
    required this.capacity,
    this.endsAt,
    this.imageUrl,
    this.aboutLong,
    this.rsvpStatus = RsvpStatus.none,
  });

  final int id;
  final String title;

  /// Short blurb shown in list cards. The Details page falls back to this
  /// when [aboutLong] is null.
  final String description;

  /// Activity start time. The repository is contracted to filter on
  /// `startsAt >= now` and sort ascending, so list consumers can render
  /// without further sorting.
  final DateTime startsAt;

  /// Optional. Null when the activity is open-ended or duration-less.
  final DateTime? endsAt;

  final String location;

  /// Free-form classification ("workshop", "club", "lecture", "career",
  /// "academic", "community", "social"). String for now to keep the entity
  /// additive-friendly during scaffolding; can be promoted to an enum once
  /// the taxonomy stabilises.
  final String category;

  /// Optional banner image. Null when the activity has no media attached.
  final String? imageUrl;

  /// Long-form body shown on the Details "ABOUT" section. Falls back to
  /// [description] when null.
  final String? aboutLong;

  /// Current confirmed attendees. Always `0 <= attendance <= capacity`.
  final int attendance;

  /// Maximum allowed attendees. `0` denotes "uncapped".
  final int capacity;

  /// Local user's RSVP state for this activity. Defaults to [RsvpStatus.none].
  final RsvpStatus rsvpStatus;

  /// Returns a copy with selected fields overridden. Only fields the BLoC
  /// mutates locally are exposed — keep the surface narrow.
  Activity copyWith({
    int? attendance,
    RsvpStatus? rsvpStatus,
  }) {
    return Activity(
      id: id,
      title: title,
      description: description,
      startsAt: startsAt,
      endsAt: endsAt,
      location: location,
      category: category,
      imageUrl: imageUrl,
      aboutLong: aboutLong,
      attendance: attendance ?? this.attendance,
      capacity: capacity,
      rsvpStatus: rsvpStatus ?? this.rsvpStatus,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        startsAt,
        endsAt,
        location,
        category,
        imageUrl,
        aboutLong,
        attendance,
        capacity,
        rsvpStatus,
      ];
}
