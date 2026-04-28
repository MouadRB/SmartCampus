
---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Structural Architecture](#2-structural-architecture)
3. [The Arbitration Logic (The "Brain")](#3-the-arbitration-logic-the-brain)
4. [State Management & Offline Monitoring](#4-state-management--offline-monitoring)
5. [Safety & Correctness Measures](#5-safety--correctness-measures)


---

## 1. Executive Summary

Sprint 3 transformed SmartCampus Companion from a purely remote-dependent application into a production-grade **offline-first system**. The sprint was executed in four sequential phases, each building strictly upon the last, in accordance with the Clean Architecture-lite invariant established in Sprint 2.

### Sprint Goal

Establish a local SQLite persistence layer and a global network monitoring system so that the application continues to serve meaningful data when device connectivity is unavailable, without exposing any persistence or networking implementation details to the Domain layer.

### Phases Completed

| Phase | Deliverable | Scope |
|---|---|---|
| **Phase 1 · Local Persistence Foundation** | Drift table definitions, `AppDatabase`, `CacheException`, mappers, `LocalDataSource` interfaces + implementations | Announcements · Timetable |
| **Phase 2 · Repository Arbitration** | `RepositoryImpl` classes updated to orchestrate remote + local data sources using a strict cache-fallback strategy | Announcements · Timetable |
| **Phase 3 · BLoC Wiring & State Management** | `AnnouncementsBloc` and `TimetableBloc` with typed 5-state machines consuming `Either<Failure, T>` from repositories | Announcements · Timetable |
| **Phase 4 · Global Offline Tracking** | `ConnectivityBloc` global singleton listening to the OS network hardware stream | App-wide |

### Files Produced

| Category | New Files | Modified Files |
|---|---|---|
| Drift tables + database | 3 (+ 1 generated `.g.dart`) |   |
| Exception taxonomy |   | 1 (`exceptions.dart`) |
| Failure base class |   | 1 (`failures.dart`) |
| Mappers | 2 |   |
| Local data sources | 2 |   |
| Repository implementations |   | 2 |
| Feature BLoCs (event + state + bloc) | 6 |   |
| Connectivity BLoC (event + state + bloc) | 3 |   |
| Dependency injection |   | 1 |
| `pubspec.yaml` |   | 1 |
| **Total** | **16 hand-authored** | **6** |

### Verification Verdict

`dart analyze lib/`   **zero issues** across the entire `lib/` directory.
Domain boundary check   **CLEAN**: no `drift`, `datasources/local`, or cache-related symbols appear in any `domain/` directory.

---

## 2. Structural Architecture

### 2.1 The Persistence Layer

#### Why Drift

`drift` (formerly `moor`) was selected as the mandated local database solution for three specific reasons aligned with the project's architectural constraints:

1. **Type safety at compile time.** Drift generates fully typed Dart classes for every table row and query result. There are no untyped `Map<String, dynamic>` returns from the database   the same category of runtime `type cast` errors eliminated in Sprint 2 by `json_serializable` is eliminated here by `build_runner`-generated Drift code.

2. **Relational model.** Unlike key-value stores (`SharedPreferences`, `flutter_secure_storage`), Drift provides a full SQL engine. This enables primary-key-based upserts, atomic multi-table transactions, and structured queries   all required for the cache invalidation and export features planned in later sprints.

3. **Testability.** `AppDatabase([QueryExecutor? executor])` accepts an optional executor parameter, allowing test suites to inject `NativeDatabase.memory()` without modifying any production code.

#### Directory Structure

```
lib/
└── core/
    └── datasources/
        └── local/
            ├── app_database.dart       ← @DriftDatabase   the single shared DB instance
            ├── app_database.g.dart     ← build_runner generated (do not edit)
            └── tables/
                ├── announcements_table.dart   ← AnnouncementsTable definition
                └── timetable_table.dart       ← TimetableTable definition
```

Per-feature local data sources follow the same physical structure as their remote counterparts:

```
lib/features/announcements/data/
├── datasources/
│   └── announcement_local_data_source.dart   ← abstract + Impl
└── models/
    └── announcement_mapper.dart               ← extension mappers

lib/features/timetable/data/
├── datasources/
│   └── timetable_local_data_source.dart      ← abstract + Impl
└── models/
    └── campus_task_mapper.dart                ← extension mappers
```

#### Table Definitions

Both Drift tables are defined with explicit primary keys. The `@DataClassName` annotation on each table is the primary mechanism that enforces the Drift-Domain boundary (see Section 2.2).

```dart
// lib/core/datasources/local/tables/announcements_table.dart
@DataClassName('AnnouncementTableData')
class AnnouncementsTable extends Table {
  IntColumn get id     => integer()();
  IntColumn get userId => integer()();
  TextColumn get title => text()();
  TextColumn get body  => text()();

  @override
  Set<Column> get primaryKey => {id};
}

// lib/core/datasources/local/tables/timetable_table.dart
@DataClassName('TimetableTableData')
class TimetableTable extends Table {
  IntColumn get id       => integer()();
  IntColumn get userId   => integer()();
  TextColumn get title   => text()();
  BoolColumn get completed => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}
```

#### `AppDatabase`   Shared Lazy Singleton

`AppDatabase` is the single owner of the SQLite file on disk. It is constructed once via `registerLazySingleton` in the DI container (see Section 6). The `LazyDatabase` wrapper defers the async path resolution until the first query, satisfying Dart's synchronous constructor requirement while still supporting `async` platform calls.

```dart
@DriftDatabase(tables: [AnnouncementsTable, TimetableTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'smart_campus.db'));
    return NativeDatabase.createInBackground(file);
  });
}
```

---

### 2.2 The Dependency Invariant   Keeping Domain Pure

The non-negotiable Sprint 2 invariant   **dependencies point inward only**   was preserved throughout Sprint 3 despite introducing a third-party persistence framework. Two mechanisms enforce this physically, not by convention.

#### Mechanism 1: `@DataClassName`   The Naming Firewall

Drift's default code generation derives the `DataClass` name from the table class name. Without intervention, `AnnouncementsTable` would generate a class named `Announcement`   identical to the pure Domain entity   creating a naming collision and, worse, a temptation to use the Drift type in domain-layer code.

`@DataClassName('AnnouncementTableData')` overrides this. The generated type is `AnnouncementTableData`, which is structurally unrelated to `Announcement`. There is no pathway through which a developer could accidentally use the Drift type in domain code without an explicit import that `dart analyze` would immediately flag.

#### Mechanism 2: Bidirectional Extension Mappers

The translation between Drift's generated types and Domain entities is handled by extension methods defined entirely within the data layer.

```dart
// lib/features/announcements/data/models/announcement_mapper.dart

// Drift row → Domain Entity (used by LocalDataSource reads)
extension AnnouncementDataMapper on AnnouncementTableData {
  Announcement toDomain() => Announcement(
        id: id,
        userId: userId,
        title: title,
        body: body,
      );
}

// Domain Entity → Drift Companion (used by LocalDataSource writes)
extension AnnouncementEntityMapper on Announcement {
  AnnouncementsTableCompanion toCompanion() =>
      AnnouncementsTableCompanion.insert(
        id: Value(id),   // explicit   API-supplied IDs, not auto-increment
        userId: userId,
        title: title,
        body: body,
      );
}
```

The key property of Dart extension methods: they are defined in the data layer, but the type being extended (`Announcement`) has zero knowledge of their existence. The Domain entity remains a pure, framework-agnostic Dart class. The data layer reaches out to the entity; the entity never reaches back.

#### Verification Proof

```bash
$ grep -r "drift" lib/features/*/domain/
# (no output)
$ grep -r "app_database" lib/features/*/domain/
# (no output)
$ grep -r "CacheException\|CacheFailure" lib/features/*/domain/
# (no output)
```

All three checks return zero results. The Domain layer is provably uncontaminated.

---

## 3. The Arbitration Logic (The "Brain")

The `RepositoryImpl` is the single point in the codebase that simultaneously holds references to both a `RemoteDataSource` and a `LocalDataSource`. Its responsibility is to act as the **single source of truth**: always try the network first, use the local cache as a fallback, and translate every possible failure mode into a typed `Failure` object before returning.

### 3.1 The Three-Path Cache-Fallback Strategy

The arbitration logic implements a strict decision tree with three mutually exclusive branches. There is no ambiguity between paths, and every path terminates with a typed `Either<Failure, T>`   the widget tree can never receive an unhandled exception.

```
Remote fetch attempted
        │
        ├─── HTTP 200 ──────────────────────────────────────────────────┐
        │    ↓                                                           │
        │    Try cache write                                             │
        │        ├── success ──────────────────────────────────────────►│ Right(remoteData)
        │        └── CacheException ─── swallow (best-effort) ─────────►│ Right(remoteData)
        │                                                                │
        ├─── ServerException (4xx / 5xx) ───────────────────────────────► Left(ServerFailure)
        │    [cache NOT touched]
        │
        └─── NetworkException (timeout / SocketException)
                 ↓
                 Try cache read
                     ├── non-empty list ────────────────────────────────► Right(cachedData)
                     ├── empty list ────────────────────────────────────► Left(NetworkFailure)
                     └── CacheException ─────────────────────────────────► Left(CacheFailure)
```

The following is the complete, unabridged implementation for the Announcements feature. The Timetable implementation is structurally identical.

```dart
// lib/features/announcements/data/repositories/announcements_repository_impl.dart

class AnnouncementsRepositoryImpl implements AnnouncementsRepository {
  AnnouncementsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final SmartCampusRemoteDataSource remoteDataSource;
  final AnnouncementLocalDataSource localDataSource;

  @override
  Future<Either<Failure, List<Announcement>>> getAnnouncements() async {
    try {
      final remote = await remoteDataSource.getAnnouncements();

      // Cache is best-effort: a write failure must not hide fresh data.
      try {
        await localDataSource.cacheAnnouncements(
          List<Announcement>.from(remote),
        );
      } on CacheException catch (_) {
        // Swallow   the user still receives the freshly-fetched data.
      }

      return Right(List<Announcement>.from(remote));
    } on ServerException catch (e) {
      // Server is reachable but returned an error   do not touch the cache.
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      // Device is offline or the request timed out   attempt cache fallback.
      try {
        final cached = await localDataSource.getCachedAnnouncements();
        if (cached.isEmpty) {
          // Nothing in the cache   surface the original network error so the
          // UI shows the offline banner with a retry prompt instead of an
          // empty screen with no explanation.
          return Left(NetworkFailure(message: e.message));
        }
        return Right(cached);
      } on CacheException catch (ce) {
        return Left(CacheFailure(message: ce.message));
      }
    }
  }
}
```

### 3.2 The Exception → Failure → BLoC State Translation Table

The 1:1 mapping established in Sprint 2 is extended to cover the local persistence layer. Every exception type maps to exactly one `Failure` type, which maps to exactly one BLoC state, which maps to exactly one UI behaviour.

| Exception thrown by | Exception type | Repository returns | BLoC emits | UI behaviour |
|---|---|---|---|---|
| `RemoteDataSource` | `ServerException` | `Left(ServerFailure)` | `AnnouncementsError(message)` | Error prompt + Retry button |
| `RemoteDataSource` | `NetworkException` + non-empty cache | `Right(cachedData)` | `AnnouncementsLoaded(data)` | Cached content (silent) |
| `RemoteDataSource` | `NetworkException` + empty cache | `Left(NetworkFailure)` | `AnnouncementsOffline(message)` | Amber offline banner |
| `LocalDataSource` (fallback read) | `CacheException` | `Left(CacheFailure)` | `AnnouncementsError(message)` | Error prompt + Retry button |

This mapping is mechanically verifiable: if a `SocketException` occurs anywhere in the system, it becomes a `NetworkException` in the data source, a `NetworkFailure` in the repository, an `AnnouncementsOffline` state in the BLoC, and the amber banner in the UI. There is no code path through which it can reach the widget tree as a crash or as a silent empty list.

### 3.3 Explicit Design Decisions

Two design decisions were made deliberately during Phase 2 after explicit discussion. Both are documented here so reviewers understand the intent, not just the implementation.

#### Decision A   Best-Effort Cache Writes

**Decision:** If the remote fetch succeeds but the subsequent `cacheAnnouncements()` call throws a `CacheException` (e.g., disk full, database locked), the `CacheException` is swallowed and `Right(remoteData)` is returned.

**Rationale:** The local cache is an optimisation, not a hard requirement. The user already has the correct, fresh data in memory. Surfacing a `Left(CacheFailure)` in this case would show an error screen to a user who just successfully received a valid API response   a confusing and incorrect user experience. The consequence of swallowing is limited: the offline fallback will not have fresh data on the next launch. That is an acceptable trade-off.

#### Decision B   `Left(NetworkFailure)` on Empty Cache

**Decision:** If a `NetworkException` is caught and the local cache is empty (returns `[]`), the repository returns `Left(NetworkFailure(message))` rather than `Right([])`.

**Rationale:** An empty list is a valid, meaningful state that communicates "the server returned no records." Returning `Right([])` when the device is offline would cause the UI to render an empty-state widget with no error context   a user staring at "No announcements yet" with no indication that the app is offline. Returning `Left(NetworkFailure)` instead surfaces the amber offline banner and a retry prompt, which correctly communicates the situation and gives the user an action to take.

---

## 4. State Management & Offline Monitoring

### 4.1 `ConnectivityBloc`   Global Singleton

#### Architecture

`ConnectivityBloc` is a **self-managing** BLoC: it creates and owns its OS stream subscription internally, requiring no external event dispatches from the UI to function. All state transitions are still routed through the event system (as required by `bloc` 9.x's `emit()` constraint)   the stream listener dispatches `ConnectivityStatusChanged` events rather than calling `emit()` directly.

```dart
class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  ConnectivityBloc() : super(const ConnectivityInitial()) {
    on<ConnectivityStatusChanged>(_onStatusChanged);

    // 1. Subscribe to OS stream for the lifetime of this BLoC.
    _subscription = Connectivity().onConnectivityChanged.listen(
      (results) => add(ConnectivityStatusChanged(results)),
    );

    // 2. Eagerly resolve the current state without waiting for a change event.
    Connectivity().checkConnectivity().then(
      (results) => add(ConnectivityStatusChanged(results)),
    );
  }

  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  void _onStatusChanged(
    ConnectivityStatusChanged event,
    Emitter<ConnectivityState> emit,
  ) {
    final isConnected = event.results.any(
      (result) => result != ConnectivityResult.none,
    );
    emit(isConnected ? const ConnectedState() : const DisconnectedState());
  }

  @override
  Future<void> close() {
    _subscription.cancel();   // release OS resource before BLoC disposal
    return super.close();
  }
}
```

#### `connectivity_plus` v5+ API Handling

`connectivity_plus` v5 changed `onConnectivityChanged` from `Stream<ConnectivityResult>` to `Stream<List<ConnectivityResult>>`. This reflects real-world device behaviour: a device can be simultaneously connected via WiFi, Ethernet, and a VPN tunnel, each reported as a separate `ConnectivityResult`. The BLoC's evaluation logic accounts for this correctly:

```dart
final isConnected = event.results.any(
  (result) => result != ConnectivityResult.none,
);
```

The device is considered online if **any** active interface reports a non-none result. This is correct for both the single-result and multi-result cases.

#### The Cold-Start Blindspot Fix

`onConnectivityChanged` is a **change** stream   it only emits when the network state transitions. It does not emit an initial value when a listener subscribes. On a device with a stable connection that never changes, the BLoC would remain in `ConnectivityInitial` indefinitely without the `checkConnectivity()` call.

The eager `checkConnectivity().then(...)` call in the constructor fires a `ConnectivityStatusChanged` event immediately, ensuring `ConnectivityInitial` is a millisecond-transient state resolved before the widget tree's first frame. The UI only ever needs to handle `ConnectedState` and `DisconnectedState` in practice.

#### Singleton Rationale

`ConnectivityBloc` is registered as `registerLazySingleton`, not `registerFactory`. If it were a factory, each `BlocProvider` or `sl<ConnectivityBloc>()` call would create a new instance   each with its own `StreamSubscription`. The app would have multiple competing OS stream listeners, each independently emitting state changes to different parts of the widget tree. One singleton guarantees exactly one subscription and one authoritative source of truth for the entire app.

---

### 4.2 Feature BLoCs   `AnnouncementsBloc` and `TimetableBloc`

#### The 5-State Machine

Both feature BLoCs implement an identical state machine with five states, each mapping to a distinct UI behaviour:

| State | Trigger | UI Behaviour |
|---|---|---|
| `AnnouncementsInitial` | BLoC construction (before first event) | No content rendered |
| `AnnouncementsLoading` | `FetchAnnouncements` dispatched | Shimmer placeholder animations (FR-NET-05) |
| `AnnouncementsLoaded(data)` | Repository returns `Right(data)` | Content list rendered |
| `AnnouncementsError(message)` | Repository returns `Left(ServerFailure)` or `Left(CacheFailure)` | Error prompt + Retry button with human-readable `message` |
| `AnnouncementsOffline(message)` | Repository returns `Left(NetworkFailure)` | Persistent amber offline banner (FR-NET-05) |

#### `FetchAnnouncements` vs `RefreshAnnouncements`

Both events call the same repository method and share a common private `_fetchAndEmit()` helper. Their only difference is whether a `Loading` state is emitted beforehand:

- **`FetchAnnouncements`** → emits `AnnouncementsLoading` first. Used on initial screen entry. The `Loading` state triggers shimmer placeholders, giving the user a visual indication that data is being fetched from scratch.
- **`RefreshAnnouncements`** → does **not** emit `AnnouncementsLoading`. Used by `RefreshIndicator` on pull-to-refresh. The `RefreshIndicator` widget provides its own spinner, so emitting `Loading` would replace existing content with shimmer   a disruptive and unnecessary visual transition.

#### The No-Try-Catch Invariant

Feature BLoC handlers contain zero `try-catch` blocks. This is enforced by design, not by testing:

```dart
Future<void> _fetchAndEmit(Emitter<AnnouncementsState> emit) async {
  final result = await repository.getAnnouncements();
  result.fold(
    (failure) => failure is NetworkFailure
        ? emit(AnnouncementsOffline(failure.message))
        : emit(AnnouncementsError(failure.message)),
    (announcements) => emit(AnnouncementsLoaded(announcements)),
  );
}
```

The `Either.fold()` call is the entire error-handling logic. The repository guarantees that every possible exception has been caught and wrapped in a `Failure` before this line is reached. The BLoC routes; it does not guard.

---

## 5. Safety & Correctness Measures

### 5.1 `StreamSubscription` Lifecycle Management

The `ConnectivityBloc`'s `StreamSubscription<List<ConnectivityResult>>` is stored as a `late final` field and explicitly cancelled in the `close()` override. This is not optional hygiene   it is a correctness requirement.

Without cancellation, the Dart runtime holds a reference from the OS stream to the `add()` method of the closed BLoC. Since `ConnectivityBloc` is a singleton registered in `GetIt`, this reference effectively lasts for the process lifetime on most platforms, preventing garbage collection of the BLoC and accumulating orphaned event dispatches if the BLoC is ever re-registered (e.g., in hot restart scenarios during development).

### 5.2 Atomic Cache Writes

The `LocalDataSource` implementations use a Drift `transaction()` wrapping a delete-all followed by a `batch.insertAll()`. This guarantees that the cache is never in a partial-write state:

```dart
await database.transaction(() async {
  await database.delete(database.announcementsTable).go();   // remove stale rows
  await database.batch((batch) {
    batch.insertAll(
      database.announcementsTable,
      announcements.map((a) => a.toCompanion()).toList(),
    );
  });
});
```

If the app is killed between the `delete` and the `insertAll`, the transaction is rolled back by SQLite's write-ahead log. The next app launch finds the cache exactly as it was before the interrupted write   not empty, not partially written.

### 5.3 `Equatable` on States   `BlocBuilder` Rebuild Optimisation

All BLoC states extend `Equatable` and declare their payload fields in `props`. Without `Equatable`, Dart's default reference equality (`identical(a, b)`) means that two `AnnouncementsLoaded` emissions containing semantically identical lists would be treated as different objects, triggering a `BlocBuilder` rebuild even though the UI content would not change. With `Equatable`, the `BlocBuilder` performs value equality on `props`, suppressing redundant rebuilds and preventing unnecessary widget subtree invalidations.

### 5.4 `abstract String get message` on the `Failure` Base Class

During Phase 3 implementation, `dart analyze` surfaced that `failure.message` was inaccessible from the abstract `Failure` type inside BLoC `fold()` handlers   `message` was defined on each concrete subclass but not on the base. The fix was a single-line addition to `failures.dart`:

```dart
abstract class Failure extends Equatable {
  const Failure();
  String get message;  // satisfied by final String message on every subclass
}
```

In Dart, a `final String message` field on a concrete class implicitly satisfies an abstract `String get message` getter on its superclass. Zero changes were required to the three concrete `Failure` classes. This addition makes the `fold()` routing in BLoCs clean and type-safe at the abstract `Failure` level, without requiring downcast checks.

---

## 6. Dependency Injection Graph   Final Tier Structure

The `injection_container.dart` `init()` function registers all dependencies in strict **bottom-up order**: each tier's registrations may only call `sl<T>()` for types registered in a lower tier. Violating this order causes a runtime `GetIt: Object not registered` exception.

| Tier | Registered Type | Concrete Implementation | Registration Mode | Rationale |
|---|---|---|---|---|
| **1 · External** | `http.Client` | `http.Client()` via `_buildHttpClient()` | `registerLazySingleton` | Single HTTP connection pool; swap hook for `dio` migration |
| **1 · External** | `AppDatabase` | `AppDatabase()` | `registerLazySingleton` | One SQLite file owner for the app's lifetime |
| **2 · Data Sources** | `SmartCampusRemoteDataSource` | `SmartCampusRemoteDataSourceImpl` | `registerLazySingleton` | Stateless; safe to share |
| **2 · Data Sources** | `AnnouncementLocalDataSource` | `AnnouncementLocalDataSourceImpl` | `registerLazySingleton` | Stateless; shares `AppDatabase` singleton |
| **2 · Data Sources** | `TimetableLocalDataSource` | `TimetableLocalDataSourceImpl` | `registerLazySingleton` | Stateless; shares `AppDatabase` singleton |
| **3 · Repositories** | `AnnouncementsRepository` | `AnnouncementsRepositoryImpl` | `registerLazySingleton` | Stateless arbitrator; safe to share |
| **3 · Repositories** | `TasksRepository` | `TasksRepositoryImpl` | `registerLazySingleton` | Stateless arbitrator; safe to share |
| **3 · Repositories** | `UserRepository` | `UserRepositoryImpl` | `registerLazySingleton` | Remote-only; stateless |
| **3 · Repositories** | `MapRepository` | `MapRepositoryImpl` | `registerLazySingleton` | Remote-only; stateless |
| **3 · Repositories** | `EventsRepository` | `EventsRepositoryImpl` | `registerLazySingleton` | Remote-only; stateless |
| **4 · BLoCs** | `ConnectivityBloc` | `ConnectivityBloc()` | **`registerLazySingleton`** | **One OS stream listener must be shared app-wide. A factory would spawn duplicate subscriptions.** |
| **4 · BLoCs** | `AnnouncementsBloc` | `AnnouncementsBloc(repository: sl())` | **`registerFactory`** | **Stateful. Each screen navigation must receive a fresh instance. A singleton would carry stale state into newly opened screens.** |
| **4 · BLoCs** | `TimetableBloc` | `TimetableBloc(repository: sl())` | **`registerFactory`** | **Stateful. Same rationale as `AnnouncementsBloc`.** |

> **Critical Distinction:** `ConnectivityBloc` is the **only BLoC registered as a singleton**. This is not a convention   it is a correctness requirement. The BLoC's value is precisely its single, shared `StreamSubscription`. Feature BLoCs are **always** `registerFactory` because they are stateful event processors whose state must be fresh on every screen entry.

---

## 7. Verification Results

### Static Analysis

```bash
$ dart analyze lib/
Analyzing lib...
No issues found!
```

Result: **Zero issues** across the entire `lib/` directory, including all 16 new files and all 6 modified files produced during Sprint 3.

### Domain Boundary Check

```bash
$ grep -r "drift" lib/features/*/domain/
# (no output   CLEAN)

$ grep -r "app_database" lib/features/*/domain/
# (no output   CLEAN)

$ grep -r "CacheException\|CacheFailure" lib/features/*/domain/
# (no output   CLEAN)
```

Result: **CLEAN**. No domain directory imports or references any data-layer symbol, Drift type, or cache concept. The Dependency Inversion Principle is physically enforced.

### No-Try-Catch Verification in BLoC Files

```bash
$ grep -n "try\|catch" lib/features/announcements/presentation/bloc/announcement_bloc.dart
# (no output   CLEAN)

$ grep -n "try\|catch" lib/features/timetable/presentation/bloc/timetable_bloc.dart
# (no output   CLEAN)

$ grep -n "try\|catch" lib/core/connectivity/connectivity_bloc.dart
# (no output   CLEAN)
```

Result: **CLEAN**. No BLoC file contains a `try-catch` block. All exception handling is confined to the Repository and LocalDataSource layers where it belongs.

### `build_runner` Generation

```bash
$ dart run build_runner build --delete-conflicting-outputs
# Built with build_runner/jit in 23s; wrote 64 outputs.
```

Result: **Successful**. `app_database.g.dart` generated with correct `AnnouncementTableData`, `AnnouncementsTableCompanion`, `TimetableTableData`, and `TimetableTableCompanion` types. No analyzer warnings in generated code.

---

## Sprint 3 Readiness Checklist   Week 4 Entry Criteria

The following must remain true before beginning Sprint 4 (UI & Presentation layer implementation):

- [x] `dart analyze lib/` reports zero issues with all Sprint 3 files included
- [x] Domain boundary grep returns no results for `drift`, `app_database`, or cache symbols
- [x] No BLoC file contains a `try-catch` block
- [x] `ConnectivityBloc` is registered as `registerLazySingleton`; feature BLoCs as `registerFactory`
- [x] `AppDatabase` accepts an optional `QueryExecutor` for test-time injection
- [x] `StreamSubscription` cancelled in `ConnectivityBloc.close()`
- [ ] `BlocProvider<ConnectivityBloc>` mounted above `MaterialApp` in `main.dart` *(Sprint 4)*
- [ ] Shimmer loading states wired to `AnnouncementsLoading` / `TimetableLoading` *(Sprint 4)*
- [ ] Amber offline banner wired to `DisconnectedState` *(Sprint 4)*
- [ ] Unit tests for Repository arbitration logic with mock data sources *(Sprint 4)*

---

*End of Sprint 3 Technical Architecture Report*
