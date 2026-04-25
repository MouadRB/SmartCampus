import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/announcements_table.dart';
import 'tables/timetable_table.dart';

part 'app_database.g.dart';

/// The single, shared Drift database for the entire app.
///
/// All Drift table classes are declared here. The @DriftDatabase annotation
/// drives code generation — run `dart run build_runner build` after any change
/// to a Table class to regenerate [app_database.g.dart].
///
/// The optional [QueryExecutor] parameter enables test-time injection of an
/// in-memory database: `AppDatabase(NativeDatabase.memory())`.
@DriftDatabase(tables: [AnnouncementsTable, TimetableTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;
}

/// Opens the on-device SQLite file inside the app's documents directory.
///
/// [LazyDatabase] defers the async path resolution until the first query,
/// satisfying Drift's synchronous constructor requirement.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'smart_campus.db'));
    return NativeDatabase.createInBackground(file);
  });
}
