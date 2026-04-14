import 'package:dartz/dartz.dart';
import 'package:smart_campus/core/error/failures.dart';
import 'package:smart_campus/features/timetable/domain/entities/campus_task.dart';

abstract class TasksRepository {
  Future<Either<Failure, List<CampusTask>>> getTasks();
}
