import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import 'package:smart_campus/core/datasources/remote_data_source.dart';
import 'package:smart_campus/features/announcements/data/repositories/announcements_repository_impl.dart';
import 'package:smart_campus/features/announcements/domain/repositories/announcements_repository.dart';
import 'package:smart_campus/features/auth/data/repositories/user_repository_impl.dart';
import 'package:smart_campus/features/auth/domain/repositories/user_repository.dart';
import 'package:smart_campus/features/events/data/repositories/events_repository_impl.dart';
import 'package:smart_campus/features/events/domain/repositories/events_repository.dart';
import 'package:smart_campus/features/map/data/repositories/map_repository_impl.dart';
import 'package:smart_campus/features/map/domain/repositories/map_repository.dart';
import 'package:smart_campus/features/timetable/data/repositories/tasks_repository_impl.dart';
import 'package:smart_campus/features/timetable/domain/repositories/tasks_repository.dart';

/// Global service locator instance.
/// Use [sl]<T>() anywhere in the app to resolve a registered dependency.
final sl = GetIt.instance;

/// Registers every dependency in strict bottom-up order:
///   External  →  Data Sources  →  Repositories
///
/// Must be awaited in [main] before [runApp] is called.
Future<void> init() async {
  // ── 1. External ────────────────────────────────────────────────────────────
  //
  // http.Client is registered via a dedicated factory function.
  // Week 3 hook: replace [_buildHttpClient] body with a dio-backed client,
  // an AuthInterceptor, or a logging wrapper — no other file needs to change.
  sl.registerLazySingleton<http.Client>(_buildHttpClient);

  // ── 2. Data Sources ────────────────────────────────────────────────────────
  //
  // Registered as the abstract [SmartCampusRemoteDataSource] so that callers
  // and repositories never depend on the concrete implementation class.
  sl.registerLazySingleton<SmartCampusRemoteDataSource>(
    () => SmartCampusRemoteDataSourceImpl(client: sl()),
  );

  // ── 3. Repositories ────────────────────────────────────────────────────────
  //
  // Each implementation is registered under its domain interface.
  // sl() resolves [SmartCampusRemoteDataSource] from step 2 automatically.
  sl.registerLazySingleton<AnnouncementsRepository>(
    () => AnnouncementsRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<TasksRepository>(
    () => TasksRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<MapRepository>(
    () => MapRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<EventsRepository>(
    () => EventsRepositoryImpl(remoteDataSource: sl()),
  );
}

// ── Client factory ────────────────────────────────────────────────────────────
//
// Isolated here so the entire client configuration lives in one place.
// To add interceptors or switch to dio in Week 3, edit only this function.
http.Client _buildHttpClient() {
  return http.Client();
}
