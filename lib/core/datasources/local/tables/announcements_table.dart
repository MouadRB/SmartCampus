import 'package:drift/drift.dart';

/// Drift table definition for cached announcements.
///
/// [AnnouncementTableData] is the generated DataClass (row type).
/// [AnnouncementsTableCompanion] is the generated companion (insert/update type).
///
/// The @DataClassName annotation prevents a naming collision with the pure
/// Domain entity [Announcement] that lives in the domain layer.
@DataClassName('AnnouncementTableData')
class AnnouncementsTable extends Table {
  IntColumn get id => integer()();
  IntColumn get userId => integer()();
  TextColumn get title => text()();
  TextColumn get body => text()();

  @override
  Set<Column> get primaryKey => {id};
}
