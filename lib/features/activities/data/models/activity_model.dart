import 'package:smart_campus/features/activities/domain/entities/activity.dart';

/// Data-layer model for [Activity]. Extends the entity (LSP) so anything that
/// consumes the Domain type — BLoCs, widgets, use cases — receives an
/// [ActivityModel] transparently and never needs to import this file.
class ActivityModel extends Activity {
  const ActivityModel({
    required super.id,
    required super.title,
    required super.description,
    required super.startsAt,
    required super.location,
    required super.category,
    required super.attendance,
    required super.capacity,
    super.endsAt,
    super.imageUrl,
    super.aboutLong,
    super.rsvpStatus,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      startsAt: DateTime.parse(json['startsAt'] as String),
      endsAt: json['endsAt'] == null
          ? null
          : DateTime.parse(json['endsAt'] as String),
      location: json['location'] as String,
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String?,
      aboutLong: json['aboutLong'] as String?,
      attendance: json['attendance'] as int? ?? 0,
      capacity: json['capacity'] as int? ?? 0,
      rsvpStatus: _parseRsvp(json['rsvpStatus'] as String?),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'startsAt': startsAt.toIso8601String(),
        'endsAt': endsAt?.toIso8601String(),
        'location': location,
        'category': category,
        'imageUrl': imageUrl,
        'aboutLong': aboutLong,
        'attendance': attendance,
        'capacity': capacity,
        'rsvpStatus': rsvpStatus.name,
      };

  static RsvpStatus _parseRsvp(String? raw) {
    if (raw == 'going') return RsvpStatus.going;
    return RsvpStatus.none;
  }
}
