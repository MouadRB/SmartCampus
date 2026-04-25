import 'package:drift/drift.dart' show Value;

import 'package:smart_campus/core/datasources/local/app_database.dart';
import 'package:smart_campus/features/announcements/domain/entities/announcement.dart';

/// Converts a Drift-generated [AnnouncementTableData] row into a pure
/// Domain [Announcement] entity. Lives in the data layer — the domain entity
/// remains completely unaware of Drift.
extension AnnouncementDataMapper on AnnouncementTableData {
  Announcement toDomain() => Announcement(
        id: id,
        userId: userId,
        title: title,
        body: body,
      );
}

/// Converts a pure Domain [Announcement] entity into a Drift
/// [AnnouncementsTableCompanion] suitable for INSERT and UPDATE operations.
///
/// The API-supplied [id] is passed explicitly as [Value(id)] so that Drift
/// inserts the exact primary key rather than delegating to the database.
extension AnnouncementEntityMapper on Announcement {
  AnnouncementsTableCompanion toCompanion() => AnnouncementsTableCompanion.insert(
        id: Value(id),
        userId: userId,
        title: title,
        body: body,
      );
}
