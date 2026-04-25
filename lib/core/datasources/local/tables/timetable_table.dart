import 'package:drift/drift.dart';

/// Drift table definition for cached timetable tasks.
///
/// [TimetableTableData] is the generated DataClass (row type).
/// [TimetableTableCompanion] is the generated companion (insert/update type).
///
/// The @DataClassName annotation keeps the generated name distinct from the
/// pure Domain entity [CampusTask] that lives in the domain layer.
@DataClassName('TimetableTableData')
class TimetableTable extends Table {
  IntColumn get id => integer()();
  IntColumn get userId => integer()();
  TextColumn get title => text()();
  BoolColumn get completed => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}
