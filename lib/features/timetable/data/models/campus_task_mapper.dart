import 'package:drift/drift.dart' show Value;

import 'package:smart_campus/core/datasources/local/app_database.dart';
import 'package:smart_campus/features/timetable/domain/entities/campus_task.dart';

/// Converts a Drift-generated [TimetableTableData] row into a pure
/// Domain [CampusTask] entity. Lives in the data layer — the domain entity
/// remains completely unaware of Drift.
extension CampusTaskDataMapper on TimetableTableData {
  CampusTask toDomain() => CampusTask(
        id: id,
        userId: userId,
        title: title,
        completed: completed,
      );
}

/// Converts a pure Domain [CampusTask] entity into a Drift
/// [TimetableTableCompanion] suitable for INSERT and UPDATE operations.
///
/// The API-supplied [id] is passed explicitly as [Value(id)] so that Drift
/// inserts the exact primary key rather than delegating to the database.
extension CampusTaskEntityMapper on CampusTask {
  TimetableTableCompanion toCompanion() => TimetableTableCompanion.insert(
        id: Value(id),
        userId: userId,
        title: title,
        completed: completed,
      );
}
