---
name: Week 4 Checkpoint — Permissions Gateway shipped, Campus Map + streaming LocationBloc next
description: Resume point for Week 4 hardware integration. What shipped, packages added, native files modified vs pending, and the precise next step (Campus Map + streaming LocationBloc).
type: project
---

Pause point: end of Week 4 kickoff. Permissions Gateway and Location read-path are complete and `flutter analyze` clean. **Platform folders `android/` and `ios/` do not exist yet** — scaffolding them is the first action on resume.

## 1 · What shipped

**Permissions Gateway — full Clean Architecture stack** (reusable across Location, Camera FR-PERM-01, and future hardware features):
- `features/permissions/domain/`: `PermissionStatus` enum (granted / denied / permanentlyDenied), `PermissionType` enum (location, camera reserved), abstract `PermissionsRepository`, use cases `CheckPermission` / `RequestPermission` / `OpenAppSettings`.
- `features/permissions/data/`: `PermissionStatusMapper` + `PermissionTypeMapper` extensions (Mechanism-2 pattern from WEEK2 §1.2), `PermissionsDataSource` (+Impl wrapping `permission_handler`), `PermissionsRepositoryImpl`.
- `features/permissions/presentation/bloc/`: `PermissionsBloc` with 6 states — Initial / Loading / Granted / Denied / PermanentlyDenied / Error. Pure `.fold()`, zero try/catch (No-Try-Catch invariant from WEEK2 §3.2). Maps FR-PERM-03 directly.

**Location read-path — domain + data only, no bloc yet** (deferred to next session):
- `features/location/domain/`: `Coordinates` entity (lat/lng/accuracy/timestamp, Equatable), abstract `LocationRepository`, `GetCurrentLocation` use case.
- `features/location/data/`: `CoordinatesMapper` (Position → Coordinates), `LocationDataSource` (+Impl wrapping `Geolocator.getCurrentPosition()`; checks `isLocationServiceEnabled()` first; translates package exceptions to app-level), `LocationRepositoryImpl` that **composes** `PermissionsRepository` — gates every sensor read on a granted permission. Presentation never chains permission + location calls.

**Reusable UI gate**:
- `core/presentation/widgets/location_permission_gate.dart` — `LocationPermissionGate({child, rationaleMessage})`. Dispatches `CheckPermissionRequested` in `initState` via `addPostFrameCallback`. Renders: spinner (Initial/Loading) → rationale + "Grant access" CTA (Denied) → settings redirect + "Open Settings" CTA (PermanentlyDenied) → child (Granted). UI never imports `permission_handler`.

**Cross-cutting wiring**:
- `core/error/exceptions.dart`: `+PermissionDeniedException(message, permanent)`, `+LocationServiceDisabledException(message)`.
- `core/error/failures.dart`: `+PermissionFailure(message, permanent)`.
- `core/injection/injection_container.dart`: data sources (Tier 2), repositories (Tier 3), use cases (Tier 3.5), `PermissionsBloc` factory (Tier 4). Bottom-up order preserved.
- `main.dart`: `BlocProvider<PermissionsBloc>` added inside the existing `MultiBlocProvider`, session-scoped (inside `MaterialApp.home`, above `AuthenticatedShell`) per the earlier provider-boundary fix.

## 2 · Packages added + native files

**Packages added to `pubspec.yaml`** (`flutter pub get` succeeded):
- `permission_handler: ^11.3.1`
- `geolocator: ^13.0.1`

**Native files — documented only, NOT yet applied.** Project has no `android/` or `ios/` folders. Run `flutter create . --platforms=android,ios` first, then apply:

- `android/app/src/main/AndroidManifest.xml` — inside `<manifest>` above `<application>`:
  ```xml
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
  <uses-feature android:name="android.hardware.location.gps" android:required="false" />
  ```
- `android/app/build.gradle` (or `.kts`) — verify `defaultConfig.minSdk >= 21`.
- `ios/Runner/Info.plist`:
  ```xml
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>SmartCampus uses your location to show your position relative to campus points of interest.</string>
  ```
- `ios/Podfile` — inside `post_install do |installer|`, add to each target's `GCC_PREPROCESSOR_DEFINITIONS`: `'$(inherited)'`, `'PERMISSION_LOCATION=1'`. Without this the iOS request silently no-ops. Add `PERMISSION_CAMERA=1` later when wiring FR-PERM-01.

## 3 · Next step on resume — Campus Map UI + streaming LocationBloc

Concrete sequence:

1. **Apply the native patch above** (after `flutter create . --platforms=android,ios`).
2. **Add `google_maps_flutter`** to `pubspec.yaml`. Configure Google Maps API keys: Android `<meta-data>` in `AndroidManifest.xml`, iOS `GMSServices.provideAPIKey(...)` in `AppDelegate.swift`. **Separate scope from permissions** — flag this to the user before starting.
3. **Extend `LocationDataSource`** with `Stream<Coordinates> watchPosition()` wrapping `Geolocator.getPositionStream(...)` + the existing `CoordinatesMapper`. Extend `LocationRepository` with the same method (still gated through `PermissionsRepository`).
4. **Build `LocationBloc`** per README §3.2 spec:
   - Events: `RequestLocation` (one-shot, wraps existing `GetCurrentLocation`), `TrackPosition` (subscribes to `watchPosition`).
   - States: `LocationInitial`, `LocationLoading`, `LocationGranted(Coordinates)`, `LocationDenied(message, permanent)`, `LocationTracking(Coordinates)` (or emit successive `LocationGranted`).
   - **Stream lifecycle is non-optional**: store `late final StreamSubscription<Coordinates> _subscription`, cancel in `close()` override. Same correctness pattern as `ConnectivityBloc` (WEEK2 §4.1).
5. **Build `CampusMapScreen`** (Tab 0 → `/map` push target per README §5.2). Wrap a `GoogleMap` widget in `LocationPermissionGate`. Plot the user blue-dot from `LocationBloc` state. Plot static POI markers from the existing `MapRepository` / `CampusLocation` entity (already shipped Week 2).
6. **DI**: register `LocationBloc` as `registerFactory`. Wrap the map route in `BlocProvider<LocationBloc>` **scoped to the route only**, not global — the stream subscription must terminate when the map closes. Don't add it to the root `MultiBlocProvider`.

Watch-outs:
- Google Maps on iOS requires `cd ios && pod install` after adding the package; the Podfile `post_install` block from the permission patch must already be in place.
- FR-LIF-01: consider whether the map should pause/resume position streaming on app background to save battery. Defer unless the user asks.
- `permission_handler` v11 bundles iOS preprocessor flags via `PERMISSION_*=1` opt-ins — confirm `PERMISSION_LOCATION=1` is in the Podfile before testing on a real iOS device (simulator silently no-ops requests without it).

## Anchor commits / files to re-read first on resume

- `lib/features/permissions/` — full stack, reference for Camera/Notifications later.
- `lib/features/location/data/repositories/location_repository_impl.dart` — the gating composition pattern; copy the structure for any future "permission-gated sensor" repository.
- `lib/core/presentation/widgets/location_permission_gate.dart` — reusable; just pass a different `PermissionType` later for Camera by parameterizing it.
- `lib/main.dart` — `MultiBlocProvider` shape; add `LocationBloc` per-route, NOT here.
