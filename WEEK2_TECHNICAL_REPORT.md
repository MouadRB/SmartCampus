# SmartCampus Companion — Week 2 Technical Architecture Report
**Milestone:** Core Logic & Networking  
**Course:** Mobile Operating Systems — Semester Project  
**Document Version:** 1.0 · **Date:** April 2026  
**Architecture Pattern:** Clean Architecture-lite (Data / Domain / Presentation)

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [The Clean Boundary Audit](#2-the-clean-boundary-audit)
3. [Data Mapping Matrix](#3-data-mapping-matrix)
4. [Resilience & Networking Strategy](#4-resilience--networking-strategy)
5. [The Service Locator (DI) Graph](#5-the-service-locator-di-graph)
6. [Mobile OS Concepts Integration](#6-mobile-os-concepts-integration)
7. [Week 3 Readiness Checklist](#7-week-3-readiness-checklist)

---

## 1. Executive Summary

Week 2 completed the foundational **Core Logic & Networking** layer of the SmartCampus Companion application. Starting from the scaffolded feature directories established in Week 1, four implementation phases were executed in strict architectural order to ensure each layer was fully operational before the next was built upon it.

### Phases Completed

| Phase | Deliverable | Files Created |
|---|---|---|
| **Phase 1 · Data Model Layer** | Domain Entities + Data Models with serialization | 10 `.dart` + 3 `.g.dart` |
| **Phase 2 · Networking Client** | Remote Data Source + HTTP client + exception taxonomy | 3 `.dart` |
| **Phase 3 · Repository Layer** | Domain interfaces + Data implementations with `Either` | 10 `.dart` |
| **Phase 4 · Dependency Injection** | Service Locator container + application entry point | 2 `.dart` |

**Total files produced:** 27 hand-authored `.dart` files, 3 code-generated `.g.dart` files.  
**Static analysis result:** `dart analyze lib/` reports **zero issues** across the entire `lib/` directory.

### Architecture Invariant

Every phase was governed by a single non-negotiable invariant: **dependencies point inward only**. The Presentation layer will depend on Domain; Domain has zero dependencies on Data; Data implements Domain interfaces. This is verified by the grep boundary check executed at the end of Phase 3, which confirmed that no file inside any `domain/` directory imports anything from `data/`.

---

## 2. The Clean Boundary Audit

### 2.1 Physical Separation

The Clean Architecture boundary is enforced **physically by directory structure**, not merely by convention. The following tree illustrates the separation for the Announcements feature (all five features follow the identical pattern):

```
lib/features/announcements/
├── domain/                         ← INNER LAYER — framework-agnostic
│   ├── entities/
│   │   └── announcement.dart       ← Pure Dart class. Zero external imports.
│   └── repositories/
│       └── announcements_repository.dart  ← Abstract contract. Imports: dartz, Failure, Announcement only.
│
└── data/                           ← OUTER LAYER — serialization & HTTP
    ├── models/
    │   └── announcement_model.dart ← Extends Announcement. Imports: json_annotation, Announcement.
    └── repositories/
        └── announcements_repository_impl.dart  ← Implements interface. Imports: dartz, datasource, exceptions, failures.
```

The key observation is that `domain/entities/announcement.dart` contains **no import statements whatsoever** beyond `package:equatable/equatable.dart`. It cannot be contaminated by a serialization library or an HTTP change because it has no mechanism to receive one. This is the physical enforcement of the Dependency Inversion Principle.

### 2.2 Logical Separation: The Entity-Model Split

The relationship between Entity and Model follows the **Liskov Substitution Principle (LSP)**. Every `*Model` class `extends` its corresponding Entity, meaning every Model IS-A Entity. This has a direct architectural consequence: the Repository layer can declare its return type as `Future<Either<Failure, List<Announcement>>>` while the actual runtime objects are `List<AnnouncementModel>`. The Domain layer is structurally incapable of importing from the Data layer, yet it receives fully functional, type-safe objects.

```
                     ┌─────────────────────┐
                     │  Announcement       │  ← Domain Entity
                     │  (Equatable, pure)  │    No JSON, no HTTP
                     └──────────┬──────────┘
                                │ extends
                     ┌──────────▼──────────┐
                     │  AnnouncementModel  │  ← Data Model
                     │  (@JsonSerializable)│    fromJson / toJson
                     └─────────────────────┘
```

### 2.3 Why `equatable`

`equatable` is applied to **both** Entities and Models. Without it, Dart's default object equality is reference-based (`identical(a, b)`). Two `Announcement` objects constructed from the same JSON payload would be considered unequal, which would cause Flutter's `BlocBuilder` to trigger unnecessary widget rebuilds on every state emission — even when the data is semantically identical. `Equatable` overrides `==` and `hashCode` using the `props` list, enabling **value equality** across the entire Domain layer. This directly supports the efficient `BlocBuilder` diffing that the Presentation layer will rely upon in Week 3.

### 2.4 Why `json_serializable`

`json_serializable` is applied exclusively to **Model** classes and generates the `fromJson` / `toJson` boilerplate at compile time via `build_runner`. Hand-writing JSON parsing is error-prone and does not scale; generated code eliminates an entire category of runtime `type cast` exceptions. The code generator reads constructor parameter annotations and produces type-safe casting logic (e.g., `(json['id'] as num).toInt()`).

For the two models where the API structure could not be resolved by `@JsonKey` alone (`UserProfileModel` and `CampusLocationModel`), `json_serializable` was acknowledged in the file's import but the factory was written manually. This is documented explicitly in the source files to maintain the architectural intent while being honest about the tooling's limitations.

---

## 3. Data Mapping Matrix

This table documents the complete transformation applied at the boundary between the JSONPlaceholder API response and the Domain Entity for each of the five implemented features.

| Feature | JSONPlaceholder Endpoint | Domain Entity | Data Model | Custom Transformation |
|---|---|---|---|---|
| **Announcements** | `GET /posts` | `Announcement` | `AnnouncementModel` | None — 1:1 field mapping. `json_serializable` generates `fromJson` automatically. |
| **User Profile** | `GET /users/1` | `UserProfile` | `UserProfileModel` | **Nested flattening:** `company.name` (String) → `department` (String). Manual `fromJson` required; `json_serializable` cannot perform path-based extraction on nested objects. |
| **Campus Tasks** | `GET /todos` | `CampusTask` | `CampusTaskModel` | None — 1:1 field mapping. `json_serializable` generates `fromJson` automatically. |
| **Campus Map** | `GET /users` | `CampusLocation` | `CampusLocationModel` | **Double nesting + type coercion:** `address.geo.lat` and `address.geo.lng` are API Strings. Extracted via two-step map traversal and converted to Dart `double` via `double.parse()`. Manual `fromJson` required. |
| **Event Gallery** | `GET /photos` | `EventMedia` | `EventMediaModel` | **Key renaming (×2):** `albumId` (int) → `eventId` via `@JsonKey(name: 'albumId')`; `url` (String) → `imageUrl` via `@JsonKey(name: 'url')`. Fully generated by `json_serializable`. |

### Transformation Rationale

The transformations above are not cosmetic — each one encapsulates an **API contract detail** inside the Data layer so that the Domain layer never has to know about it.

- A `UserProfile.department` field communicates a business concept. `company.name` communicates a JSON structure. The model absorbs the structural detail; the entity exposes the concept.
- A `CampusLocation.lat` field is a `double` because geographic coordinates are numbers. The API returns them as strings. The model performs the coercion; the entity declares the semantically correct type.
- An `EventMedia.eventId` communicates ownership. The API's `albumId` communicates album grouping. The model bridges the semantic gap; the entity uses domain language.

---

## 4. Resilience & Networking Strategy

### 4.1 The Reactive Error-Handling Architecture

SmartCampus employs a **reactive error-handling strategy**: the Repository does not proactively check network state before making a call. Instead, it attempts the request and reacts to the outcome. This keeps the Repository implementation dependency-free (no `internet_connection_checker` package required at this stage) and ensures the error path is always exercised from a real failure signal, not a potentially stale connectivity status.

Proactive offline detection — for the persistent UI banner described in `FR-NET-05` — is delegated to the Presentation layer via `connectivity_plus` and a dedicated `ConnectivityBloc` in Week 3.

### 4.2 The Two-Exception Taxonomy

Most networking implementations use a single generic exception for all failure modes. SmartCampus defines **two semantically distinct exception types**, each mapping to a different UI state:

```
lib/core/error/exceptions.dart
├── ServerException(statusCode, message)   ← API is reachable but returned an error
└── NetworkException(message)              ← App cannot reach the API at all
```

**`ServerException`** is thrown when the remote server is reachable and returns an HTTP response, but that response carries a non-200 status code (e.g., 404 Not Found, 500 Internal Server Error). The `statusCode` field is preserved so that the Repository — and subsequently the BLoC — can provide a human-readable error description to the user (e.g., "Resource not found" vs "Server error").

**`NetworkException`** is thrown for two distinct conditions handled in the same catch block:
1. `dart:async.TimeoutException` — the request was dispatched but no response arrived within `kRequestTimeout` (10 seconds). This models a slow or degraded connection.
2. `dart:io.SocketException` — the OS could not establish a TCP connection. This models a completely offline device.

Both conditions are semantically equivalent from the user's perspective ("I cannot reach the server") and both map to the same UI behaviour: the Offline/Slow Connection banner.

### 4.3 The Exception-to-Failure Translation

Exceptions are a Data layer concept. Failures are a Domain layer concept. The Repository is the translation boundary between the two worlds. This translation is implemented identically across all five repository implementations:

```
                DATA LAYER                     DOMAIN LAYER
┌───────────────────────────────┐    ┌────────────────────────────────┐
│  RemoteDataSource             │    │  Repository Interface           │
│  throws:                      │    │  returns:                       │
│  · ServerException       ─────┼────┼─► Left(ServerFailure)          │
│  · NetworkException      ─────┼────┼─► Left(NetworkFailure)         │
│  · [success]             ─────┼────┼─► Right(List<Entity>)          │
└───────────────────────────────┘    └────────────────────────────────┘
```

The `Either<Failure, T>` type from the `dartz` package is the carrier for this translation. `Left` wraps failure states; `Right` wraps success values. The UI layer — via BLoC — will call `.fold()` on the `Either` to branch on success or failure without ever needing a `try-catch`. This is the mechanism that makes the application **crash-proof**: every possible failure mode terminates at a typed `Failure` object, never as an unhandled exception propagating through the widget tree.

### 4.4 The Full Request Lifecycle

The following sequence traces a single `getAnnouncements()` call end-to-end:

```
1. BLoC                sl<AnnouncementsRepository>()
                              │
2. RepositoryImpl      getAnnouncements()
                              │
3. DataSourceImpl      getAnnouncements() → _get('/posts')
                              │
4. http.Client         GET https://jsonplaceholder.typicode.com/posts
                       .timeout(Duration(seconds: 10))
                              │
                    ┌─────────┴──────────┐
              HTTP 200              Failure (timeout / socket / 4xx-5xx)
                    │                     │
5a. Success    json.decode()         5b. Exception thrown
               → List<AnnouncementModel>    (ServerException or NetworkException)
                    │                     │
6. Repository  Right(List<Announcement>)  Left(ServerFailure or NetworkFailure)
                    │                     │
7. BLoC        AnnouncementsLoaded        AnnouncementsError / AnnouncementsOffline
```

---

## 5. The Service Locator (DI) Graph

### 5.1 Registration Order and Rationale

The `init()` function in `lib/core/injection/injection_container.dart` registers dependencies in **strict bottom-up order**. This order is not arbitrary: each registration tier calls `sl()` to resolve a dependency from the tier below it. If the order were reversed, `sl()` would throw an "Object not registered" error at runtime.

```
TIER 1 · External          _buildHttpClient()
                                │
                                ▼
TIER 2 · Data Sources      SmartCampusRemoteDataSourceImpl
                           (registered as SmartCampusRemoteDataSource)
                                │
                    ┌───────────┼───────────┐───────────┐───────────┐
                    ▼           ▼           ▼           ▼           ▼
TIER 3 · Repos  Announcements  User      Tasks        Map        Events
                RepositoryImpl RepositoryImpl ...     (all registered as their interfaces)
```

Every repository in Tier 3 receives `sl<SmartCampusRemoteDataSource>()` — the abstract interface, not the concrete implementation class. If `SmartCampusRemoteDataSourceImpl` is replaced by a mock or a `dio`-backed implementation, every repository continues to function without modification.

### 5.2 `registerLazySingleton` vs Alternatives

GetIt provides three primary registration modes. The choice of `registerLazySingleton` for all tiers is deliberate:

| Registration Mode | Behaviour | Why Not Used Here |
|---|---|---|
| `registerFactory` | New instance on every `sl()` call | Two BLoCs requesting the same repository would receive disconnected objects with separate in-memory state. Unacceptable. |
| `registerSingleton` | Instance created immediately at registration | Instantiates all objects at app startup, including features the user may never visit. Wastes memory and slows cold start. |
| **`registerLazySingleton`** | **Instance created on first `sl()` call, reused thereafter** | **Memory-safe: unused features incur zero cost. Thread-safe: GetIt handles concurrent first-access. Shared state: all callers receive the same instance.** |

### 5.3 The `_buildHttpClient()` Factory Wrapper

Rather than registering `http.Client` with an inline lambda, the client construction is isolated in a dedicated private function:

```dart
sl.registerLazySingleton<http.Client>(_buildHttpClient);

http.Client _buildHttpClient() {
  return http.Client();  // Week 3: replace this body only
}
```

This implements the **Open/Closed Principle** at the configuration level: the container is open for extension (the function body changes) but closed for modification (the `registerLazySingleton` call and all downstream registrations remain unchanged). In Week 3, migrating to `dio` with an `AuthInterceptor` and a logging wrapper requires editing exactly one function body. No repository, data source, entity, or test file is affected.

### 5.4 Application Entry Point Guard

`lib/main.dart` uses a three-step initialization sequence in the precise order required by the Flutter engine:

```dart
WidgetsFlutterBinding.ensureInitialized();  // (1) Platform channels ready
await di.init();                             // (2) Dependency graph complete
runApp(const SmartCampusApp());              // (3) Widget tree starts building
```

`WidgetsFlutterBinding.ensureInitialized()` must precede any `async` platform call because Flutter's engine bindings are not active before this point. `await di.init()` must complete before `runApp()` because any `sl<T>()` call made during widget construction — in `initState`, a BLoC constructor, or a `Provider` — must find a fully populated container.

---

## 6. Mobile OS Concepts Integration

### 6.1 Network Robustness (FR-NET-02, FR-NET-05)

The architecture directly satisfies the university rubric's **Network Robustness** criterion across three implementation points:

**Configurable Timeout (`FR-NET-02`):**  
The constant `kRequestTimeout = Duration(seconds: 10)` in `lib/core/network/network_client.dart` implements the 10-second hard timeout required by `FR-NET-02`. The value is extracted into a named constant (not hardcoded inline) so that it can be adjusted for different network environments without searching through implementation files. Every HTTP call flows through `_get()` in the data source, meaning this single constant governs the timeout behaviour of the entire application.

**Three Distinct UI States (`FR-NET-05`):**  
The `Either<Failure, T>` return type enforces that every repository call produces one of exactly three outcomes:
- `Right(data)` → BLoC emits a **Loaded** state → normal content is displayed.
- `Left(ServerFailure)` → BLoC emits an **Error** state → retry prompt with HTTP status description.
- `Left(NetworkFailure)` → BLoC emits an **Offline** state → persistent amber banner ("You are offline: showing cached data.").

This 1:1 mapping between exception types and UI states was a deliberate design decision. It makes `FR-NET-05` mechanically verifiable: if `NetworkException` is thrown anywhere in the system, `NetworkFailure` is produced, and the offline banner is shown. There is no code path through which a `SocketException` could reach the UI as a crash.

### 6.2 Hardware Readiness

The current architecture establishes the **injection infrastructure** required to integrate device hardware features in Week 3 and Week 4 without architectural refactoring.

**Location Services (`FR-PERM-02`):**  
`CampusLocation` entities carry `lat` (double) and `lng` (double) fields. The `MapRepository.getMapLocations()` method returns the Points of Interest (POI) dataset. When `geolocator` is integrated in Week 3, the `LocationBloc` will call `sl<MapRepository>()` for the POI data and merge it with live GPS coordinates. The repository layer requires no modification; only a new BLoC and a new datasource method for live coordinates are needed.

**Camera & Gallery (`FR-PERM-01`):**  
`EventMedia` entities include `imageUrl` and `thumbnailUrl` fields grouped by `eventId`. When `image_picker` is integrated, the captured photo path will be stored alongside the `eventId` reference. The `EventsRepository` interface is already the correct injection point for this; a local datasource can be added to `EventsRepositoryImpl` in Week 3 without changing the domain interface.

**Sensors (`FR-PERM-04`):**  
The shake-to-refresh interaction (`sensors_plus`) will dispatch a `RefreshAnnouncements` event to `AnnouncementsBloc`, which will call `sl<AnnouncementsRepository>().getAnnouncements()`. The repository layer is already wired and ready to receive this call.

---

## 7. Week 3 Readiness Checklist

The following checklist itemises the exact integration points each Week 3 BLoC must implement to connect to the architecture built in Week 2.

### 7.1 BLoC Wiring (State Management)

Every BLoC must receive its Repository via constructor injection, resolved from the service locator. The `Either.fold()` method is the canonical bridge between the Repository's `Either<Failure, T>` and the BLoC's typed states.

```dart
// Canonical BLoC pattern for all 5 features
final result = await sl<AnnouncementsRepository>().getAnnouncements();
result.fold(
  (failure) => emit(failure is NetworkFailure
      ? const AnnouncementsOffline()
      : AnnouncementsError(failure.message)),
  (data)    => emit(AnnouncementsLoaded(data)),
);
```

- [ ] **AnnouncementsBloc** — inject `AnnouncementsRepository`; handle `AnnouncementsLoading`, `AnnouncementsLoaded`, `AnnouncementsError`, `AnnouncementsOffline` states; register `AnnouncementsBloc` in `injection_container.dart` as `registerFactory` (not singleton — each screen needs a fresh BLoC instance).
- [ ] **UserBloc** (AuthBloc) — inject `UserRepository`; handle profile fetch on login success.
- [ ] **TimetableBloc** — inject `TasksRepository`; handle `TimetableLoading`, `TimetableLoaded`, `TimetableError`.
- [ ] **LocationBloc** — inject `MapRepository` for POI data; integrate `geolocator` for live GPS; handle `LocationInitial`, `LocationGranted`, `LocationDenied`, `LocationTracking`.
- [ ] **EventsBloc** — inject `EventsRepository`; handle `EventsLoading`, `EventsLoaded`, `EventsError`; wire `image_picker` to `AttachPhoto` event.

### 7.2 Connectivity BLoC

- [ ] Add `connectivity_plus` to `pubspec.yaml`.
- [ ] Implement `ConnectivityBloc` that listens to `Connectivity().onConnectivityChanged` stream.
- [ ] Emit `ConnectedState` / `DisconnectedState`.
- [ ] Register in `injection_container.dart`.
- [ ] Mount `BlocProvider<ConnectivityBloc>` above the `MaterialApp` widget in `main.dart` so the offline banner is accessible from all screens.

### 7.3 Networking Upgrade (Client Factory Hook)

- [ ] Evaluate migrating from `http` to `dio` for retry support (`FR-NET-02` max 2 retries with exponential backoff).
- [ ] If migrating: update only `_buildHttpClient()` in `injection_container.dart`. No other file changes required.
- [ ] If staying with `http`: subclass `http.BaseClient` to add logging and auth header injection inside `_buildHttpClient()`.

### 7.4 Registration Additions for Week 3

The following registrations must be added to `injection_container.dart` `init()` function. Preserve the bottom-up order: new external dependencies → new data sources → new BLoCs.

```dart
// Add after repositories, Week 3:
sl.registerFactory<AnnouncementsBloc>(
  () => AnnouncementsBloc(repository: sl()),
);
sl.registerFactory<TimetableBloc>(
  () => TimetableBloc(repository: sl()),
);
// ... repeat for each BLoC
sl.registerLazySingleton<ConnectivityBloc>(
  () => ConnectivityBloc(),  // singleton: one stream, shared across app
);
```

### 7.5 Verification Gate

Before beginning Week 4 (UI implementation), the following must be true:

- [ ] `dart analyze lib/` reports zero issues with all new BLoC files included.
- [ ] Each BLoC has a corresponding unit test that injects a mock repository and verifies the `Either.fold()` branching produces the correct state emissions.
- [ ] The domain boundary check passes: `grep -r "data/" lib/features/*/domain/` returns no results.
- [ ] `flutter run` launches without a `GetIt: Object not registered` exception.

---

*End of Week 2 Technical Architecture Report*
