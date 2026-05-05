import 'package:equatable/equatable.dart';

class Announcement extends Equatable {
  const Announcement({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.publishedAt,
  });

  final int id;
  final int userId;
  final String title;
  final String body;

  /// Wall-clock timestamp the announcement was published. Used to sort
  /// newest-first in the list and to render "X hours ago" labels.
  final DateTime publishedAt;

  @override
  List<Object?> get props => [id, userId, title, body, publishedAt];
}
