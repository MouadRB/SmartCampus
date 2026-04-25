---
name: SmartCampus Architecture & Week 2 State
description: Core architectural constraints, layer rules, error taxonomy, DI pattern, and Week 2 completion status for SmartCampus Companion Flutter project
type: project
---

SmartCampus Companion is a Flutter/Dart semester project using Clean Architecture-lite (Data / Domain / Presentation) with BLoC state management and JSONPlaceholder as the mock REST backend.

**Architecture invariant:** Dependencies point strictly inward — Presentation → Domain ← Data. Domain has zero imports from Data. Enforced physically by directory structure.

**Entity-Model split:** Data Models `extend` Domain Entities (LSP). Models carry `@JsonSerializable` / manual `fromJson`; Entities are pure Dart with `equatable` only.

**Error taxonomy (two types):**
- `ServerException(statusCode, message)` → caught by Repository → `Left(ServerFailure)` — server reachable but returned non-200
- `NetworkException(message)` → caught by Repository → `Left(NetworkFailure)` — SocketException or TimeoutException (device offline/slow)
- `CacheFailure` also defined in failures.dart (for future local DB errors)

**Either pattern:** Repositories return `Future<Either<Failure, T>>` via `dartz`. BLoCs call `.fold()` — never try-catch in Presentation.

**Offline-First strategy (reactive, not proactive):** Repository attempts the call and reacts to exceptions. Proactive connectivity monitoring is delegated to `ConnectivityBloc` (Week 3) via `connectivity_plus`.

**Mandated offline SQL cache tool:** `drift` (typed, relational SQL — NOT Hive, NOT sqflite directly).

**DI tool:** `get_it` service locator, registered bottom-up: External (http.Client) → Data Sources → Repositories. All use `registerLazySingleton`. BLoCs will use `registerFactory` (Week 3). Client swap hook: only `_buildHttpClient()` in `injection_container.dart` needs editing to migrate to dio.

**Week 2 status (complete):** Domain entities + Data models (5 features), RemoteDataSource, 5 Repository impls, injection_container.dart, main.dart. Zero dart analyze issues.

**Week 3 TODO:** BLoCs for all 5 features + ConnectivityBloc, UI screens, drift local data source, dio migration, biometric auth, permissions, notifications.

**Why:** Mobile OS semester project graded on code quality, separation of concerns, and Mobile OS concept coverage (networking, permissions, sensors, background tasks, lifecycle).
**How to apply:** Always preserve the inward-only dependency rule. Never import from data/ inside domain/. Always translate exceptions to Failures in the Repository layer, never in BLoC or UI.
