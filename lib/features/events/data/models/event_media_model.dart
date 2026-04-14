import 'package:json_annotation/json_annotation.dart';
import 'package:smart_campus/features/events/domain/entities/event_media.dart';

part 'event_media_model.g.dart';

@JsonSerializable()
class EventMediaModel extends EventMedia {
  const EventMediaModel({
    required super.id,
    @JsonKey(name: 'albumId') required super.eventId,
    required super.title,
    @JsonKey(name: 'url') required super.imageUrl,
    required super.thumbnailUrl,
  });

  factory EventMediaModel.fromJson(Map<String, dynamic> json) =>
      _$EventMediaModelFromJson(json);

  Map<String, dynamic> toJson() => _$EventMediaModelToJson(this);
}
