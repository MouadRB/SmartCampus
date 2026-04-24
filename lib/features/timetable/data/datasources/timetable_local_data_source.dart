import 'package:smart_campus/core/datasources/local/app_database.dart';
import 'package:smart_campus/core/error/exceptions.dart';
import 'package:smart_campus/features/timetable/data/models/campus_task_mapper.dart';
import 'package:smart_campus/features/timetable/domain/entities/campus_task.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Contract
// ─────────────────────────────────────────────────────────────────────────────

/// Defines the local cache operations available for [CampusTask] data.
///
/// Callers depend on this abstraction so the underlying Drift implementation
/// can be replaced (e.g., swapped for an in-memory mock in tests) without
/// touching any caller site.
abstract class TimetableLocalDataSource {
  /// Returns all [CampusTask]s currently stored in the local cache.
  ///
  /// Throws [CacheException] if the read fails.
  Future<List<CampusTask>> getCachedTasks();

  /// Replaces every row in the local cache with [tasks].
  ///
  /// The operation is atomic: either all rows are replaced or none are,
  /// preventing a partial-write state if the app is killed mid-operation.
  ///
  /// Throws [CacheException] if the write fails.
  Future<void> cacheTasks(List<CampusTask> tasks);
}

// ─────────────────────────────────────────────────────────────────────────────
// Implementation
// ─────────────────────────────────────────────────────────────────────────────

class TimetableLocalDataSourceImpl implements TimetableLocalDataSource {
  TimetableLocalDataSourceImpl({required this.database});

  final AppDatabase database;

  @override
  Future<List<CampusTask>> getCachedTasks() async {
    try {
      final rows = await database.select(database.timetableTable).get();
      return rows.map((row) => row.toDomain()).toList();
    } catch (e) {
      throw CacheException(
        message: 'Failed to read tasks from cache: $e',
      );
    }
  }

  @override
  Future<void> cacheTasks(List<CampusTask> tasks) async {
    try {
      await database.transaction(() async {
        await database.delete(database.timetableTable).go();
        await database.batch((batch) {
          batch.insertAll(
            database.timetableTable,
            tasks.map((t) => t.toCompanion()).toList(),
          );
        });
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to cache tasks: $e',
      );
    }
  }
}
