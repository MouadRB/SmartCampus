
---

## Table of Contents

1. [Structural Architecture](#2-structural-architecture)
2. [The Arbitration Logic (The "Brain")](#3-the-arbitration-logic-the-brain)
3. [State Management & Offline Monitoring](#4-state-management--offline-monitoring)
4. [Safety & Correctness Measures](#5-safety--correctness-measures)


---

## 1. Structural Architecture

### 1.1 The Persistence Layer

#### Why Drift

`drift` was selected as the mandated local database solution for three specific reasons aligned with the project's architectural constraints:

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

`AppDatabase` is the single owner of the SQLite file on disk. It is constructed once via `registerLazySingleton` in the DI container . The `LazyDatabase` wrapper defers the async path resolution until the first query, satisfying Dart's synchronous constructor requirement while still supporting `async` platform calls.

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

### 1.2 The Dependency Invariant   Keeping Domain Pure

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

## 2. The Arbitration Logic (The "Brain")

The `RepositoryImpl` is the single point in the codebase that simultaneously holds references to both a `RemoteDataSource` and a `LocalDataSource`. Its responsibility is to act as the **single source of truth**: always try the network first, use the local cache as a fallback, and translate every possible failure mode into a typed `Failure` object before returning.

### 2.1 The Three-Path Cache-Fallback Strategy

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

### 2.2 The Exception → Failure → BLoC State Translation Table

The 1:1 mapping established in Sprint 2 is extended to cover the local persistence layer. Every exception type maps to exactly one `Failure` type, which maps to exactly one BLoC state, which maps to exactly one UI behaviour.

| Exception thrown by | Exception type | Repository returns | BLoC emits | UI behaviour |
|---|---|---|---|---|
| `RemoteDataSource` | `ServerException` | `Left(ServerFailure)` | `AnnouncementsError(message)` | Error prompt + Retry button |
| `RemoteDataSource` | `NetworkException` + non-empty cache | `Right(cachedData)` | `AnnouncementsLoaded(data)` | Cached content (silent) |
| `RemoteDataSource` | `NetworkException` + empty cache | `Left(NetworkFailure)` | `AnnouncementsOffline(message)` | Amber offline banner |
| `LocalDataSource` (fallback read) | `CacheException` | `Left(CacheFailure)` | `AnnouncementsError(message)` | Error prompt + Retry button |

This mapping is mechanically verifiable: if a `SocketException` occurs anywhere in the system, it becomes a `NetworkException` in the data source, a `NetworkFailure` in the repository, an `AnnouncementsOffline` state in the BLoC, and the amber banner in the UI. There is no code path through which it can reach the widget tree as a crash or as a silent empty list.

### 2.3 Explicit Design Decisions

Two design decisions were made deliberately during Phase 2 after explicit discussion. Both are documented here so reviewers understand the intent, not just the implementation.

#### Decision A   Best-Effort Cache Writes

**Decision:** If the remote fetch succeeds but the subsequent `cacheAnnouncements()` call throws a `CacheException` (e.g., disk full, database locked), the `CacheException` is swallowed and `Right(remoteData)` is returned.

**Rationale:** The local cache is an optimisation, not a hard requirement. The user already has the correct, fresh data in memory. Surfacing a `Left(CacheFailure)` in this case would show an error screen to a user who just successfully received a valid API response   a confusing and incorrect user experience. The consequence of swallowing is limited: the offline fallback will not have fresh data on the next launch. That is an acceptable trade-off.

#### Decision B   `Left(NetworkFailure)` on Empty Cache

**Decision:** If a `NetworkException` is caught and the local cache is empty (returns `[]`), the repository returns `Left(NetworkFailure(message))` rather than `Right([])`.

**Rationale:** An empty list is a valid, meaningful state that communicates "the server returned no records." Returning `Right([])` when the device is offline would cause the UI to render an empty-state widget with no error context   a user staring at "No announcements yet" with no indication that the app is offline. Returning `Left(NetworkFailure)` instead surfaces the amber offline banner and a retry prompt, which correctly communicates the situation and gives the user an action to take.

---

## 3. State Management & Offline Monitoring

### 3.1 `ConnectivityBloc`   Global Singleton

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

### 3.2 Feature BLoCs   `AnnouncementsBloc` and `TimetableBloc`

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

## 4. Safety & Correctness Measures

### 4.1 `StreamSubscription` Lifecycle Management

The `ConnectivityBloc`'s `StreamSubscription<List<ConnectivityResult>>` is stored as a `late final` field and explicitly cancelled in the `close()` override. This is not optional hygiene   it is a correctness requirement.

Without cancellation, the Dart runtime holds a reference from the OS stream to the `add()` method of the closed BLoC. Since `ConnectivityBloc` is a singleton registered in `GetIt`, this reference effectively lasts for the process lifetime on most platforms, preventing garbage collection of the BLoC and accumulating orphaned event dispatches if the BLoC is ever re-registered (e.g., in hot restart scenarios during development).

### 4.2 Atomic Cache Writes

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

### 4.3 `Equatable` on States   `BlocBuilder` Rebuild Optimisation

All BLoC states extend `Equatable` and declare their payload fields in `props`. Without `Equatable`, Dart's default reference equality (`identical(a, b)`) means that two `AnnouncementsLoaded` emissions containing semantically identical lists would be treated as different objects, triggering a `BlocBuilder` rebuild even though the UI content would not change. With `Equatable`, the `BlocBuilder` performs value equality on `props`, suppressing redundant rebuilds and preventing unnecessary widget subtree invalidations.

### 4.4 `abstract String get message` on the `Failure` Base Class

During Phase 3 implementation, `dart analyze` surfaced that `failure.message` was inaccessible from the abstract `Failure` type inside BLoC `fold()` handlers   `message` was defined on each concrete subclass but not on the base. The fix was a single-line addition to `failures.dart`:

```dart
abstract class Failure extends Equatable {
  const Failure();
  String get message;  // satisfied by final String message on every subclass
}
```

In Dart, a `final String message` field on a concrete class implicitly satisfies an abstract `String get message` getter on its superclass. Zero changes were required to the three concrete `Failure` classes. This addition makes the `fold()` routing in BLoCs clean and type-safe at the abstract `Failure` level, without requiring downcast checks.

---

