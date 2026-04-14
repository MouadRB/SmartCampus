import 'package:equatable/equatable.dart';

class CampusTask extends Equatable {
  const CampusTask({
    required this.id,
    required this.userId,
    required this.title,
    required this.completed,
  });

  final int id;
  final int userId;
  final String title;
  final bool completed;

  @override
  List<Object?> get props => [id, userId, title, completed];
}
