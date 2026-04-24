import 'package:smart_campus/core/datasources/local/app_database.dart';
import 'package:smart_campus/core/error/exceptions.dart';
import 'package:smart_campus/features/announcements/data/models/announcement_mapper.dart';
import 'package:smart_campus/features/announcements/domain/entities/announcement.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Contract
// ─────────────────────────────────────────────────────────────────────────────

/// Defines the local cache operations available for [Announcement] data.
///
/// Callers depend on this abstraction so the underlying Drift implementation
/// can be replaced (e.g., swapped for an in-memory mock in tests) without
/// touching any caller site.
abstract class AnnouncementLocalDataSource {
  /// Returns all [Announcement]s currently stored in the local cache.
  ///
  /// Throws [CacheException] if the read fails.
  Future<List<Announcement>> getCachedAnnouncements();

  /// Replaces every row in the local cache with [announcements].
  ///
  /// The operation is atomic: either all rows are replaced or none are,
  /// preventing a partial-write state if the app is killed mid-operation.
  ///
  /// Throws [CacheException] if the write fails.
  Future<void> cacheAnnouncements(List<Announcement> announcements);
}

// ─────────────────────────────────────────────────────────────────────────────
// Implementation
// ─────────────────────────────────────────────────────────────────────────────

class AnnouncementLocalDataSourceImpl implements AnnouncementLocalDataSource {
  AnnouncementLocalDataSourceImpl({required this.database});

  final AppDatabase database;

  @override
  Future<List<Announcement>> getCachedAnnouncements() async {
    try {
      final rows = await database.select(database.announcementsTable).get();
      return rows.map((row) => row.toDomain()).toList();
    } catch (e) {
      throw CacheException(
        message: 'Failed to read announcements from cache: $e',
      );
    }
  }

  @override
  Future<void> cacheAnnouncements(List<Announcement> announcements) async {
    try {
      await database.transaction(() async {
        await database.delete(database.announcementsTable).go();
        await database.batch((batch) {
          batch.insertAll(
            database.announcementsTable,
            announcements.map((a) => a.toCompanion()).toList(),
          );
        });
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to cache announcements: $e',
      );
    }
  }
}
