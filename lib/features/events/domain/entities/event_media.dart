import 'package:equatable/equatable.dart';

class EventMedia extends Equatable {
  const EventMedia({
    required this.id,
    required this.eventId,
    required this.title,
    required this.imageUrl,
    required this.thumbnailUrl,
  });

  final int id;

  /// Groups this media item under an event. Mapped from the API's `albumId` field.
  final int eventId;

  final String title;
  final String imageUrl;
  final String thumbnailUrl;

  @override
  List<Object?> get props => [id, eventId, title, imageUrl, thumbnailUrl];
}
