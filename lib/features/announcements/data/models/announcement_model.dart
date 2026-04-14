import 'package:json_annotation/json_annotation.dart';
import 'package:smart_campus/features/announcements/domain/entities/announcement.dart';

part 'announcement_model.g.dart';

@JsonSerializable()
class AnnouncementModel extends Announcement {
  const AnnouncementModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.body,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementModelFromJson(json);

  Map<String, dynamic> toJson() => _$AnnouncementModelToJson(this);
}
