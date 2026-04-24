import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import 'package:smart_campus/core/connectivity/connectivity_bloc.dart';

import 'package:smart_campus/core/datasources/local/app_database.dart';
import 'package:smart_campus/core/datasources/remote_data_source.dart';
import 'package:smart_campus/features/announcements/data/datasources/announcement_local_data_source.dart';
import 'package:smart_campus/features/announcements/data/repositories/announcements_repository_impl.dart';
import 'package:smart_campus/features/announcements/domain/repositories/announcements_repository.dart';
import 'package:smart_campus/features/announcements/presentation/bloc/announcement_bloc.dart';
import 'package:smart_campus/features/auth/data/repositories/user_repository_impl.dart';
import 'package:smart_campus/features/auth/domain/repositories/user_repository.dart';
import 'package:smart_campus/features/events/data/repositories/events_repository_impl.dart';
import 'package:smart_campus/features/events/domain/repositories/events_repository.dart';
import 'package:smart_campus/features/map/data/repositories/map_repository_impl.dart';
import 'package:smart_campus/features/map/domain/repositories/map_repository.dart';
import 'package:smart_campus/features/timetable/data/datasources/timetable_local_data_source.dart';
import 'package:smart_campus/features/timetable/data/repositories/tasks_repository_impl.dart';
import 'package:smart_campus/features/timetable/domain/repositories/tasks_repository.dart';
import 'package:smart_campus/features/timetable/presentation/bloc/timetable_bloc.dart';

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

  // AppDatabase is a shared resource: one instance owns the single SQLite
  // file for the lifetime of the app. Registered here (Tier 1) because every
  // LocalDataSource in Tier 2 depends on it.
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // ── 2. Data Sources ────────────────────────────────────────────────────────
  //
  // Remote — registered as the abstract interface so callers never depend on
  // the concrete implementation class.
  sl.registerLazySingleton<SmartCampusRemoteDataSource>(
    () => SmartCampusRemoteDataSourceImpl(client: sl()),
  );

  // Local — each feature has its own interface; the shared AppDatabase is
  // resolved from Tier 1 via sl().
  sl.registerLazySingleton<AnnouncementLocalDataSource>(
    () => AnnouncementLocalDataSourceImpl(database: sl()),
  );

  sl.registerLazySingleton<TimetableLocalDataSource>(
    () => TimetableLocalDataSourceImpl(database: sl()),
  );

  // ── 3. Repositories ────────────────────────────────────────────────────────
  //
  // Each implementation is registered under its domain interface.
  // Arbitrating repositories receive both a remote and a local data source.
  // Remote-only repositories (User, Map, Events) are unchanged until their
  // Phase 1 local data sources are built in a future sprint.
  sl.registerLazySingleton<AnnouncementsRepository>(
    () => AnnouncementsRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<TasksRepository>(
    () => TasksRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<MapRepository>(
    () => MapRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<EventsRepository>(
    () => EventsRepositoryImpl(remoteDataSource: sl()),
  );

  // ── 4. BLoCs ───────────────────────────────────────────────────────────────
  //
  // ConnectivityBloc is a SINGLETON: the entire app must share one OS stream
  // listener. A factory would spawn a new StreamSubscription on every sl()
  // call, creating duplicate events and wasting OS resources.
  sl.registerLazySingleton<ConnectivityBloc>(() => ConnectivityBloc());

  // Feature BLoCs use registerFactory: a new instance is created on every
  // sl() call so stale state never bleeds into a newly opened screen.
  sl.registerFactory<AnnouncementsBloc>(
    () => AnnouncementsBloc(repository: sl()),
  );

  sl.registerFactory<TimetableBloc>(
    () => TimetableBloc(repository: sl()),
  );
}

// ── Client factory ────────────────────────────────────────────────────────────
//
// Isolated here so the entire client configuration lives in one place.
// To add interceptors or switch to dio in Week 3, edit only this function.
http.Client _buildHttpClient() {
  return http.Client();
}
