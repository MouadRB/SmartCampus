import 'package:smart_campus/features/announcements/domain/entities/announcement.dart';

/// Data-layer model for [Announcement]. Hand-written serialisation so the
/// `publishedAt` field can default to `DateTime.now()` when the upstream
/// JSON omits it (the legacy JSONPlaceholder payload has no date column).
class AnnouncementModel extends Announcement {
  const AnnouncementModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.body,
    required super.publishedAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    final raw = json['publishedAt'] as String?;
    return AnnouncementModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      publishedAt: raw == null ? DateTime.now() : DateTime.parse(raw),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'body': body,
        'publishedAt': publishedAt.toIso8601String(),
      };
}
