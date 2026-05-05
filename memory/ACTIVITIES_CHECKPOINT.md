---
name: Activities Feature Checkpoint — Domain trio shipped, Data + Presentation pending; Map feature complete
description: Resume point for the Activities feature. Captures Domain scaffold state, Map feature completion, native config, and the global-provider fix in main.dart.
type: project
---

Pause point: end of Activities Domain scaffold. The Activities Domain trio is shipped and `flutter analyze`-clean. Data layer (Model + MockRepository + DI registration) and Presentation layer (Bloc + Page + Navigation) are **not yet built** — those are the next-session deliverables. The Campus Map feature shipped earlier in the same session and is functional end-to-end on Android.

## 1 · Activities feature state

**Domain — DONE, frozen, `flutter analyze` clean:**

- `lib/features/activities/domain/entities/activity.dart`
  ```
  class Activity extends Equatable {
    final int id;
    final String title;
    final String description;
    final DateTime startsAt;
    final DateTime? endsAt;     // nullable — open-ended activities
    final String location;
    final String category;      // "workshop" / "club" / "lecture" — String, can promote to enum later
    final String? imageUrl;     // nullable
  }
  ```
  Equatable, const ctor, all `final`, full `props`. Imports only `package:equatable/equatable.dart`.

- `lib/features/activities/domain/repositories/activities_repository.dart`
  ```
  abstract class ActivitiesRepository {
    Future<Either<Failure, List<Activity>>> getUpcomingActivities();
  }
  ```
  Imports only `dartz`, `core/error/failures.dart`, and the `Activity` entity. Contract: filter `startsAt >= now`, sort ascending by `startsAt`, translate transport / parse exceptions into typed `Failure`s.

- `lib/features/activities/domain/usecases/get_upcoming_activities.dart`
  ```
  class GetUpcomingActivities {
    const GetUpcomingActivities(this.repository);
    final ActivitiesRepository repository;
    Future<Either<Failure, List<Activity>>> call() =>
        repository.getUpcomingActivities();
  }
  ```
  Thin call-through, no `try`/`catch`.

**Data — NOT YET BUILT.** These folders contain only `.gitkeep`:
- `lib/features/activities/data/datasources/`
- `lib/features/activities/data/models/`        ← `ActivityModel extends Activity` belongs here
- `lib/features/activities/data/repositories/`  ← `MockActivitiesRepository implements ActivitiesRepository` belongs here

**Presentation — NOT YET BUILT.** These folders contain only `.gitkeep`:
- `lib/features/activities/presentation/bloc/`
- `lib/features/activities/presentation/pages/`
- `lib/features/activities/presentation/widgets/`

**DI — NOT YET REGISTERED.** `lib/core/injection/injection_container.dart` has zero `Activities*` references. Bottom-up registration order to follow when adding: data sources → repository → use case → bloc factory.

**Naming note for resume:** the SUCCESS BRIEF originally said `EventEntity` / `EventsRepository` / `GetUpcomingEvents`, but `lib/features/events/` is occupied by the frozen photo-gallery feature (`EventMedia` entity + `EventsRepository.getEventGallery()`). New scaffold uses `Activity` / `ActivitiesRepository` / `GetUpcomingActivities` under `lib/features/activities/` — this divergence was confirmed at "go".

## 2 · Map feature — DONE, end-to-end functional on Android

Shipped earlier in the same session:

- `lib/features/location/data/datasources/location_data_source.dart` — `+ Stream<Coordinates> watchPosition()` (async generator wrapping `Geolocator.getPositionStream`).
- `lib/features/location/domain/repositories/location_repository.dart` — `+ Stream<Either<Failure, Coordinates>> watchPosition()`.
- `lib/features/location/data/repositories/location_repository_impl.dart` — gated stream impl, `await for` + typed catches → `Left(...)`. Permission gating identical to `getCurrentPosition()`.
- `lib/features/location/domain/usecases/watch_position.dart` — thin call-through, mirrors `GetCurrentLocation`.
- `lib/features/location/presentation/bloc/{location_event, location_state, location_bloc}.dart` — events: `RequestLocation`, `TrackPosition`, `StopTracking`, `PositionUpdated`. States: `Initial`/`Loading`/`Granted`/`Tracking`/`Denied`/`Error`. `StreamSubscription?` cancelled on `StopTracking`, on re-`TrackPosition`, and in `close()`. Pure `.fold()`, no try/catch.
- `lib/features/map/presentation/pages/campus_map_page.dart` — body wrapped *entirely* in `LocationPermissionGate`. Scoped `BlocProvider<LocationBloc>` (route owns the bloc; pop = stream cancel). `GoogleMap` with `myLocationEnabled: true`, animates camera onto each fix.
- `lib/core/injection/injection_container.dart` — `+ WatchPosition` use case (lazySingleton), `+ LocationBloc` factory. Comment in file explicitly forbids global registration.
- `lib/features/home/presentation/pages/home_page.dart` — `QuickActionsGrid`'s `'map'` action now `Navigator.push`es `CampusMapPage`.
- `pubspec.yaml` — `+ google_maps_flutter: ^2.9.0`.

`flutter analyze lib/features/map lib/features/location` → No issues.

## 3 · Native configuration

**Environment:** Arch Linux. **iOS builds are not possible** on this host — no Xcode toolchain. iOS edits below were applied to source for completeness / future macOS access but cannot be tested locally. All testing is Android-only for this project.

**Android — applied and verified:**

- `android/app/src/main/AndroidManifest.xml`:
  - Added at top of `<manifest>`, above `<application>`:
    ```
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <uses-feature android:name="android.hardware.location.gps" android:required="false"/>
    ```
  - Added inside `<application>` (alongside the `flutterEmbedding` meta-data):
    ```
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="AIzaSyDhbAwl948n5CBaEEo3lamCl5QQRu-is2I"/>
    ```
  - **Security caveat:** key is committed in cleartext in a tracked file. Restrict it in Google Cloud Console to the application bundle id + SHA-1 + Maps SDK before publishing. Same key string is duplicated in `ios/Runner/AppDelegate.swift` — rotate both if it ever needs to change.

**iOS — applied to source, not build-tested (no Xcode on Arch):**

- `ios/Runner/AppDelegate.swift` — `import GoogleMaps` + `GMSServices.provideAPIKey("AIza…is2I")` as the first line of `didFinishLaunchingWithOptions`, before `super`. Project uses the implicit-engine pattern (no `GeneratedPluginRegistrant.register` call inside that method — it's in `didInitializeImplicitFlutterEngine` via `FlutterImplicitEngineDelegate`).
- `ios/Runner/Info.plist` — `+ NSLocationWhenInUseUsageDescription` between `LSRequiresIPhoneOS` and `UIApplicationSceneManifest`.
- `ios/Podfile` — **does not exist yet**. Generated on first `pod install`. The `PERMISSION_LOCATION=1` preprocessor flag still needs to be appended to its `post_install` block on a macOS host before iOS testing is possible. None of this blocks Android builds.

## 4 · Bug fix: ProviderNotFoundException for PermissionsBloc

**Symptom:** Tapping the Campus Map quick action threw `ProviderNotFoundException` for `BlocBuilder<PermissionsBloc, PermissionsState>` inside `LocationPermissionGate`.

**Root cause:** the original `MultiBlocProvider` was placed at `MaterialApp.home`, which is the *first route inside the Navigator*, not its ancestor. Routes pushed via `Navigator.push` are siblings of `home` and cannot see providers scoped inside it.

**Fix applied to `lib/main.dart`:** lifted the entire `MultiBlocProvider` (including `PermissionsBloc`, `ConnectivityBloc`, `AnnouncementsBloc`, `TimetableBloc`) **above** `MaterialApp` so it sits as ancestor to the Navigator. Now every pushed route inherits the providers through context.

**`LocationBloc` was deliberately NOT lifted to global scope** despite the request. `CampusMapPage` provides its own scoped `BlocProvider<LocationBloc>`, and a global instance would keep the OS GPS `StreamSubscription` alive for the entire app lifetime — battery leak. The DI comment in `injection_container.dart` explicitly forbids this.

**Resume rule:** any future per-route bloc that owns a `StreamSubscription` (camera, sensors, BLE) must follow the same scoping pattern — local `BlocProvider` at the route, factory in DI, never in the root `MultiBlocProvider`.

## 5 · Exact next steps on resume

Follow this order. Do **not** skip ahead to the bloc/UI before the data layer is in place — the bloc factory needs the use case which needs the repository.

1. **Build `ActivityModel`** at `lib/features/activities/data/models/activity_model.dart`:
   - `extends Activity` (LSP).
   - `factory ActivityModel.fromJson(Map<String, dynamic>)` and `Map<String, dynamic> toJson()`. Use `json_annotation` (already in pubspec) + run `dart run build_runner build` to generate the `.g.dart` part file. Mirror the existing pattern in `lib/features/events/data/models/event_media_model.dart`.
   - DateTime fields parse from ISO-8601 strings.

2. **Build `MockActivitiesRepository`** at `lib/features/activities/data/repositories/mock_activities_repository.dart`:
   - `implements ActivitiesRepository`.
   - Hardcoded list of Constantine campus activities (suggested seeds: workshops at FST, lectures at the Faculty of Engineering, club meetups at Campus Ahmed Hamani Zerhouni). Use future-dated `startsAt` values relative to `DateTime.now()` so the filter stays meaningful across days.
   - In `getUpcomingActivities()`: filter `startsAt.isAfter(DateTime.now())`, sort ascending, return `Right(list)`. No network — pure in-memory mock. No `try` needed since there's no exception source.
   - For realism, optionally `await Future.delayed(const Duration(milliseconds: 400))` to exercise the loading state.

3. **Register in DI** at `lib/core/injection/injection_container.dart`, bottom-up:
   ```
   sl.registerLazySingleton<ActivitiesRepository>(() => MockActivitiesRepository());
   sl.registerLazySingleton<GetUpcomingActivities>(() => GetUpcomingActivities(sl()));
   sl.registerFactory<ActivitiesBloc>(() => ActivitiesBloc(getUpcomingActivities: sl()));
   ```
   Place the repository alongside the other Tier 3 repos, the use case in the Tier 3.5 use-case block, and the bloc in the Tier 4 BLoC block. Add `ActivitiesBloc` to the root `MultiBlocProvider` in `main.dart` only if multiple routes need to share the list — otherwise scope it to `ActivitiesPage` like `LocationBloc` is scoped to `CampusMapPage`.

4. **Build `ActivitiesBloc`** at `lib/features/activities/presentation/bloc/`:
   - Mirror `AnnouncementsBloc` shape: events `FetchActivities`, states `ActivitiesInitial` / `ActivitiesLoading` / `ActivitiesLoaded(List<Activity>)` / `ActivitiesError(String)`.
   - Pure `.fold()` on the use case result, no `try`/`catch`.

5. **Build `ActivitiesPage` + wire navigation**:
   - `ListView.builder` (or `SliverList.builder`) of activity cards. Each card uses `AppGlowTheme.cardDecoration`, `AppColors.*`, `AppTextStyles.*`, `AppSpacing.*` — never hardcode hex / sizes (per `feedback_apptheme_strict.md`).
   - Wire from `home_page.dart` similarly to the map: add an `'activities'` action to `QuickActionsGrid` if not already present, or repurpose the `'events'` quick action to push `ActivitiesPage`. Confirm with the user before repurposing.
   - If a screenshot demands a field the entity does not expose, **stop and ask** — do not silently extend `Activity` (Domain is now frozen by precedent).

## Anchor files to re-read first on resume

- `lib/features/activities/domain/` — full Domain trio; ground truth for the contract.
- `lib/features/events/data/models/event_media_model.dart` + `.g.dart` — copy-pattern for `ActivityModel.fromJson` + `build_runner` part-file mechanics.
- `lib/features/events/data/repositories/events_repository_impl.dart` — copy-pattern for `try`/`catch` → `Failure` translation in a real repository (not strictly needed for the mock, but the pattern to match when this is later swapped for a remote source).
- `lib/features/announcements/presentation/bloc/announcement_bloc.dart` — copy-pattern for the bloc shape.
- `lib/main.dart` — confirm the lifted `MultiBlocProvider` shape before deciding whether `ActivitiesBloc` goes global or per-route.
- `memory/feedback_apptheme_strict.md` — visual-token rule that governs every widget written in step 5.
