import 'package:equatable/equatable.dart';

class Announcement extends Equatable {
  const Announcement({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  final int id;
  final int userId;
  final String title;
  final String body;

  @override
  List<Object?> get props => [id, userId, title, body];
}
