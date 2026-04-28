
---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [The Clean Boundary Audit](#2-the-clean-boundary-audit)
3. [Data Mapping Matrix](#3-data-mapping-matrix)
4. [Resilience & Networking Strategy](#4-resilience--networking-strategy)
5. [The Service Locator (DI) Graph](#5-the-service-locator-di-graph)
---

## 1. Executive Summary

Week 2 completed the foundational **Core Logic & Networking** layer 

### Phases Completed

| Phase | Deliverable | Files Created |
|---|---|---|
| **Phase 1 · Data Model Layer** | Domain Entities + Data Models with serialization | 10 `.dart` + 3 `.g.dart` |
| **Phase 2 · Networking Client** | Remote Data Source + HTTP client + exception taxonomy | 3 `.dart` |
| **Phase 3 · Repository Layer** | Domain interfaces + Data implementations with `Either` | 10 `.dart` |
| **Phase 4 · Dependency Injection** | Service Locator container + application entry point | 2 `.dart` |

### Architecture Invariant

**dependencies point inward only**. The Presentation layer will depend on Domain; Domain has zero dependencies on Data; Data implements Domain interfaces. which confirmed that no file inside any `domain/` directory imports anything from `data/`.

---

## 2. The Clean Boundary Audit

### 2.1 Physical Separation

The Clean Architecture boundary is enforced **physically by directory structure**, not merely by convention. The following tree illustrates the separation for the Announcements feature (all five features follow the identical pattern):

```
lib/features/announcements/
├── domain/                         ← INNER LAYER 
│   ├── entities/
│   │   └── announcement.dart       ← Pure Dart class. Zero external imports.
│   └── repositories/
│       └── announcements_repository.dart  ← Abstract contract. Imports: dartz, Failure, Announcement only.
│
└── data/                           ← OUTER LAYER   serialization & HTTP
    ├── models/
    │   └── announcement_model.dart ← Extends Announcement. Imports: json_annotation, Announcement.
    └── repositories/
        └── announcements_repository_impl.dart  ← Implements interface. Imports: dartz, datasource, exceptions, failures.
```

`domain/entities/announcement.dart` contains **no import statements whatsoever** beyond `package:equatable/equatable.dart`. 
### 2.2 Logical Separation: The Entity-Model Split

The relationship between Entity and Model follows the **(LSP)**. Every `*Model` class `extends` its corresponding Entity,  This has a direct architectural consequence: the Repository layer can declare its return type as `Future<Either<Failure, List<Announcement>>>` while the actual runtime objects are `List<AnnouncementModel>`. The Domain layer is structurally incapable of importing from the Data layer, yet it receives fully functional, type-safe objects.

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

`equatable` is applied to **both** Entities and Models. Without it, Dart's default object equality is reference-based (`identical(a, b)`). Two `Announcement` objects constructed from the same JSON payload would be considered unequal, which would cause Flutter's `BlocBuilder` to trigger unnecessary widget rebuilds on every state emission   even when the data is semantically identical. `Equatable` overrides `==` and `hashCode` using the `props` list, enabling **value equality** across the entire Domain layer. This directly supports the efficient `BlocBuilder` diffing that the Presentation layer will rely upon in Week 3.

---

## 3. Data Mapping Matrix


| Feature | JSONPlaceholder Endpoint | Domain Entity | Data Model | Custom Transformation |
|---|---|---|---|---|
| **Announcements** | `GET /posts` | `Announcement` | `AnnouncementModel` | None   1:1 field mapping. `json_serializable` generates `fromJson` automatically. |
| **User Profile** | `GET /users/1` | `UserProfile` | `UserProfileModel` | **Nested flattening:** `company.name` (String) → `department` (String). Manual `fromJson` required; `json_serializable` cannot perform path-based extraction on nested objects. |
| **Campus Tasks** | `GET /todos` | `CampusTask` | `CampusTaskModel` | None   1:1 field mapping. `json_serializable` generates `fromJson` automatically. |
| **Campus Map** | `GET /users` | `CampusLocation` | `CampusLocationModel` | **Double nesting + type coercion:** `address.geo.lat` and `address.geo.lng` are API Strings. Extracted via two-step map traversal and converted to Dart `double` via `double.parse()`. Manual `fromJson` required. |
| **Event Gallery** | `GET /photos` | `EventMedia` | `EventMediaModel` | **Key renaming (×2):** `albumId` (int) → `eventId` via `@JsonKey(name: 'albumId')`; `url` (String) → `imageUrl` via `@JsonKey(name: 'url')`. Fully generated by `json_serializable`. |

### Transformation Rationale

The transformations  each one encapsulates an **API contract detail** inside the Data layer so that the Domain layer never has to know about it.

- A `UserProfile.department` field communicates a business concept. `company.name` communicates a JSON structure. The model absorbs the structural detail; the entity exposes the concept.
- A `CampusLocation.lat` field is a `double` because geographic coordinates are numbers. The API returns them as strings. The model performs the coercion; the entity declares the semantically correct type.
- An `EventMedia.eventId` communicates ownership. The API's `albumId` communicates album grouping. The model bridges the semantic gap; the entity uses domain language.

---

## 4. Resilience & Networking Strategy

### 4.1 The Reactive Error-Handling Architecture

**reactive error-handling strategy**: the Repository does not proactively check network state before making a call. Instead, it attempts the request and reacts to the outcome. This keeps the Repository implementation dependency-free no `internet_connection_checker` package required and ensures the error path is always exercised from a real failure signal, not a potentially stale connectivity status.

### 4.2 The Two-Exception 

Most networking implementations use a single generic exception for all failure modes. defines **two semantically distinct exception types**, each mapping to a different UI state:
Either API is reachable but returned an error or App cannot reach the API at all


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

The `Either<Failure, T>` type from the `dartz` package is the carrier for this translation. `Left` wraps failure states; `Right` wraps success values. The UI layer  via BLoC will call `.fold()` on the `Either` to branch on success or failure without ever needing a `try-catch`. This is the mechanism that makes the application **crash-proof**: every possible failure mode terminates at a typed `Failure` object, never as an unhandled exception propagating through the widget tree.

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
If you want to run tests without hitting a real server, you simply swap the Tier 2 registration to a MockDataSource. Tier 3 (the Repositories) won't need a single line of code changed because they are still just asking for any SmartCampusRemoteDataSource


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

`WidgetsFlutterBinding.ensureInitialized()` must precede any `async` platform call because Flutter's engine bindings are not active before this point. `await di.init()` must complete before `runApp()` because any `sl<T>()` call made during widget construction   in `initState`, a BLoC constructor, or a `Provider`   must find a fully populated container.

---


---

*End of Week 2 Technical Architecture Report*
