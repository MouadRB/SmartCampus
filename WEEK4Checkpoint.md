# Week 4 Checkpoint: Hardware Integration & Permissions

## What Shipped
Analyzer is clean across all new files. No issues found.

### Step 1 — Foundations
* **pubspec.yaml:** Added `permission_handler: ^11.3.1` and `geolocator: ^13.0.1`
* **core/error/exceptions.dart:** Added `PermissionDeniedException(message, permanent)` and `LocationServiceDisabledException(message)`
* **core/error/failures.dart:** Added `PermissionFailure(message, permanent)`

### Step 2 — Domain Layer (Pure)
* **features/permissions/domain/entities/:** `permission_status.dart` (granted / denied / permanentlyDenied), `permission_type.dart` (location, camera reserved)
* **features/permissions/domain/repositories/:** `permissions_repository.dart`
* **features/permissions/domain/usecases/:** `check_permission.dart`, `request_permission.dart`, `open_app_settings.dart`
* **features/location/domain/entities/:** `coordinates.dart` (lat/lng/accuracy/timestamp, Equatable)
* **features/location/domain/repositories/:** `location_repository.dart`
* **features/location/domain/usecases/:** `get_current_location.dart`

### Step 3 — Data Layer
* **features/permissions/data/mappers/:** `permission_status_mapper.dart` (package enum → domain enum, folds limited/provisional into granted), `permission_type_mapper.dart`
* **features/permissions/data/datasources/:** `permissions_data_source.dart` (abstract + Impl)
* **features/permissions/data/repositories/:** `permissions_repository_impl.dart`
* **features/location/data/models/:** `coordinates_mapper.dart` (Position → Coordinates)
* **features/location/data/datasources/:** `location_data_source.dart` (abstract + Impl; checks `isLocationServiceEnabled()` first; translates package exceptions to app types)
* **features/location/data/repositories/:** `location_repository_impl.dart` (Composes `PermissionsRepository`: checks status, requests if denied, only reads sensor on Granted; never returns `Right(denied)`)

### Step 4 — DI + PermissionsBloc
* **core/injection/injection_container.dart:** Registered data sources (Tier 2), repositories (Tier 3), use cases (Tier 3.5), `PermissionsBloc` factory (Tier 4). `LocationBloc` deferred.
* **features/permissions/presentation/bloc/:** `permissions_event.dart`, `permissions_state.dart` (5 states matching FR-PERM-03 directly), `permissions_bloc.dart` (No-Try-Catch invariant honoured — `.fold()` only)

### Step 5 — Provider Tree + Gate
* **core/presentation/widgets/location_permission_gate.dart:** Reusable `LocationPermissionGate({required child, rationaleMessage})`. Dispatches `CheckPermissionRequested` in `initState` via `addPostFrameCallback`. Renders rationale → "Grant access" (Denied), settings redirect → "Open Settings" (PermanentlyDenied), child (Granted), spinner (Initial/Loading). Built with existing `AppTheme` tokens; UI never touches `permission_handler`.
* **main.dart:** `BlocProvider<PermissionsBloc>` added inside the existing `MultiBlocProvider` (session-scoped).

---

## Native Patch 
*(Applied after running `flutter create . --platforms=android,ios`)*

### Android
**android/app/src/main/AndroidManifest.xml**
Added inside `<manifest ...>`, above `<application ...>`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-feature android:name="android.hardware.location.gps" android:required="false" />
