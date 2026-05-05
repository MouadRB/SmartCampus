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
import 'package:smart_campus/features/location/data/datasources/location_data_source.dart';
import 'package:smart_campus/features/location/data/repositories/location_repository_impl.dart';
import 'package:smart_campus/features/location/domain/repositories/location_repository.dart';
import 'package:smart_campus/features/location/domain/usecases/get_current_location.dart';
import 'package:smart_campus/features/map/data/repositories/map_repository_impl.dart';
import 'package:smart_campus/features/map/domain/repositories/map_repository.dart';
import 'package:smart_campus/features/permissions/data/datasources/permissions_data_source.dart';
import 'package:smart_campus/features/permissions/data/repositories/permissions_repository_impl.dart';
import 'package:smart_campus/features/permissions/domain/repositories/permissions_repository.dart';
import 'package:smart_campus/features/permissions/domain/usecases/check_permission.dart';
import 'package:smart_campus/features/permissions/domain/usecases/open_app_settings.dart';
import 'package:smart_campus/features/permissions/domain/usecases/request_permission.dart';
import 'package:smart_campus/features/permissions/presentation/bloc/permissions_bloc.dart';
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

  // Hardware data sources (Week 4) — thin wrappers over permission_handler
  // and geolocator. Both are stateless, so registerLazySingleton is correct.
  sl.registerLazySingleton<PermissionsDataSource>(
    () => const PermissionsDataSourceImpl(),
  );

  sl.registerLazySingleton<LocationDataSource>(
    () => const LocationDataSourceImpl(),
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

  // Hardware repositories (Week 4). LocationRepository composes
  // PermissionsRepository so callers never need to chain a permission check
  // before requesting coordinates.
  sl.registerLazySingleton<PermissionsRepository>(
    () => PermissionsRepositoryImpl(dataSource: sl()),
  );

  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(
      permissionsRepository: sl(),
      dataSource: sl(),
    ),
  );

  // ── 3.5 Use Cases ──────────────────────────────────────────────────────────
  //
  // Lightweight wrappers over single repository methods. Registered as
  // singletons because they hold no state.
  sl.registerLazySingleton<CheckPermission>(() => CheckPermission(sl()));
  sl.registerLazySingleton<RequestPermission>(() => RequestPermission(sl()));
  sl.registerLazySingleton<OpenAppSettings>(() => OpenAppSettings(sl()));
  sl.registerLazySingleton<GetCurrentLocation>(() => GetCurrentLocation(sl()));

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

  // PermissionsBloc is a factory so each gate widget gets a fresh state
  // machine. Multiple concurrent gates (e.g., Map + Camera) operate
  // independently and do not bleed state across each other.
  sl.registerFactory<PermissionsBloc>(
    () => PermissionsBloc(
      checkPermission: sl(),
      requestPermission: sl(),
      openAppSettings: sl(),
    ),
  );
}

// ── Client factory ────────────────────────────────────────────────────────────
//
// Isolated here so the entire client configuration lives in one place.
// To add interceptors or switch to dio in Week 3, edit only this function.
http.Client _buildHttpClient() {
  return http.Client();
}
