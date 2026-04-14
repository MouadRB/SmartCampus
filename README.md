# SmartCampus Companion
### Week 1 Deliverable : Technical & Functional Requirements, UI Mockup Definitions, and Navigation Skeleton

**Platform:** Flutter & Dart (null-safe, stable channel)
**Course:** Mobile Operating Systems : Semester Project
**Document Version:** 1.0 · **Date:** April 2026

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Functional Requirements](#2-functional-requirements)
3. [Technical Requirements](#3-technical-requirements)
4. [UI Mockup Definitions](#4-ui-mockup-definitions)
5. [Navigation Skeleton](#5-navigation-skeleton)
6. [Feature-to-OS Concept Traceability Matrix](#6-feature-to-os-concept-traceability-matrix)
7. [Glossary](#8-glossary)

---
---

## 1 · Introduction

### 1.1 : Document Purpose

This document constitutes the **Week 1 deliverable** for the SmartCampus Companion semester project. It formally defines the technical and functional requirements, specifies UI mockup structures for all primary screens, and outlines the navigation skeleton that will govern routing throughout the application.

> Every feature is explicitly mapped to the Mobile OS concept it demonstrates, ensuring full traceability from user-facing functionality to underlying operating system principles.

---

### 1.2 : Project Overview

**SmartCampus Companion** is a production-style mobile application built with Flutter and Dart. It assists university students in navigating daily campus life through four core verticals:

- **Schedule management** : view and manage your weekly timetable
- **Campus announcements** : receive and browse institution-wide posts
- **Event discovery** : explore and bookmark upcoming campus events
- **Campus navigation** : locate buildings and points of interest on a live map

The application must operate reliably in both online and offline modes, integrate with device hardware services, and adhere to documented security and performance practices.

---

### 1.3 : Target Users

**Students** · View timetable, announcements, campus map, class reminders, and event details.

**Staff**  · Publish announcements and manage campus events via an admin mode.

---

### 1.4 : Architectural Decisions

| Decision | Selection | Rationale |
|---|---|---|
| **Architecture Pattern** | Clean Architecture-lite (Data / Domain / Presentation) | Enforces separation of concerns; maps directly to grading criteria for code quality. |
| **State Management** | BLoC (`bloc` + `flutter_bloc`) | Event-driven paradigm with clear state transitions; facilitates unit testing of business logic. |
| **Backend / REST API** | JSONPlaceholder (mock REST API) | Provides deterministic endpoints without infrastructure overhead. |
| **Primary Device Features** | Camera/Gallery + Location (GPS) | Two distinct runtime permission flows satisfying the 2+ device feature requirement. |
| **Local Database** | Drift (formerly Moor) or `sqflite` | Typed, relational persistence for structured offline caching. |
| **Secure Storage** | `flutter_secure_storage` | Platform-native encrypted storage (Keychain on iOS, EncryptedSharedPreferences on Android). |

 **Architecture Note:** Dependencies flow strictly inward : Presentation depends on Domain; Domain has no external dependencies; Data implements Domain interfaces.

---
---

## 2 · Functional Requirements

> Each requirement group is mapped to the Mobile OS concepts it demonstrates, satisfying Section 4 of the project specification.

---

### 2.1 : Authentication & Security


**FR-AUTH-01 · Login Screen** : The system shall provide an email/password login screen. Since JSONPlaceholder has no authentication endpoint, credentials are validated locally against a predefined set or accepted with basic format validation.

**FR-AUTH-02 · Token Persistence** : Upon successful login, the system shall generate a session token and persist it in `flutter_secure_storage` (AES-256 encrypted on Android, Keychain on iOS).

**FR-AUTH-03 · Biometric Unlock** : On subsequent app launches, the system shall offer biometric authentication (fingerprint or face unlock) via the `local_auth` package to unlock the session without re-entering credentials.

**FR-AUTH-04 · Logout** : The system shall implement explicit logout functionality that clears the stored session token and returns the user to the login screen.

**FR-AUTH-05 · Biometric Fallback** : The system shall handle biometric denial gracefully by falling back to email/password entry.

**FR-AUTH-06 · Token Expiry** : Session tokens shall have a configurable expiry; expired tokens shall force re-authentication.

---

### 2.2 : Networking & Offline-First Data


**FR-NET-01 · Endpoints** : The system shall fetch Announcements from `/posts`, Events from `/posts` (filtered subset), and Timetable items from `/todos` : all via JSONPlaceholder.

**FR-NET-02 · Timeout & Retry** : The networking layer shall use the `dio` package with configurable timeouts (connect: 10s, receive: 15s) and retry logic (max 2 retries with exponential backoff).

**FR-NET-03 · Connectivity Monitoring** : The system shall monitor connectivity state in real-time using `connectivity_plus` and expose it as a BLoC stream.

**FR-NET-04 · Online/Offline Modes** : In Online Mode, the system shall fetch fresh data and update the local cache. In Offline Mode, the system shall serve content exclusively from the local database.

**FR-NET-05 · UI States** : Every data-feed screen shall implement three distinct UI states:

> **Loading** : Shimmer placeholder animations.
> **Error** : Retry prompt with a human-readable error description.
> **Offline Banner** : Persistent indicator at the top of the screen when connectivity is lost.

---

### 2.3 : Local Persistence

 **OS Concepts:** Storage & Sandboxing (file system locations, database isolation) · File I/O

**FR-PER-01 · Preferences** : User preferences (theme mode, notification toggles, language selection) shall be stored using `SharedPreferences`.

**FR-PER-02 · Structured Data** : Announcements, events, and timetable entries shall be persisted in a local SQL database (Drift or `sqflite`) within the app sandbox.

**FR-PER-03 · Export Schedule** : The system shall provide an "Export Schedule" function that serializes the current timetable to a JSON file and saves it to the device's documents directory using `path_provider`.

**FR-PER-04 · Cache Invalidation** : Cached data older than 24 hours shall be flagged as stale and refreshed on next connectivity.

---

### 2.4 : Permissions & Device Feature Integration


**FR-PERM-01 · Camera/Gallery** : The system shall request camera and photo library permissions at runtime using `permission_handler`. Users can attach photos to event notes via `image_picker`. If permission is denied, the system shall display a rationale dialog and offer a link to app settings.

**FR-PERM-02 · Location** : The system shall request `ACCESS_FINE_LOCATION` (Android) / *When In Use* (iOS). Upon grant, `geolocator` shall provide the user's coordinates, plotted on the campus map relative to predefined Points of Interest (POIs).

**FR-PERM-03 · Denial Handling** : For each permission, the system shall implement a three-state flow:

> **State A** : Initial permission request.
> **State B** : Rationale display on first denial.
> **State C** : Redirect to system settings on permanent denial.

**FR-PERM-04 · Accelerometer (Conceptual)** : The system shall use the accelerometer via `sensors_plus` to trigger a "shake to refresh" interaction on feed screens, demonstrating sensor integration.

---

### 2.5 : Notifications & Background Execution


**FR-NOT-01 · Scheduling** : The system shall schedule local notifications via `flutter_local_notifications`. Example: a reminder 10 minutes before a timetable class entry.

**FR-NOT-02 · Deep-Link Payload** : Notification payloads shall include a route identifier. Tapping the notification shall deep-link the user to the relevant screen (e.g., tapping a class reminder opens the Timetable detail view).

**FR-NOT-03 · Background Fetch** : The system shall register a periodic background task using `workmanager` that fetches new announcements every 6 hours and updates the local cache, even when the app is not in the foreground.

**FR-NOT-04 · User Controls** : Users shall be able to enable or disable notification categories (class reminders, announcement alerts) from the Settings screen.

---

### 2.6 : App Lifecycle Management


**FR-LIF-01 · Resume Refresh** : The system shall observe `AppLifecycleState` via `WidgetsBindingObserver`. On transition to `resumed`, the system shall trigger a silent data refresh if connectivity is available.

**FR-LIF-02 · Draft Persistence** : On transition to `paused`, the system shall persist any unsaved draft data (e.g., partially composed event notes) to local storage to prevent data loss.

**FR-LIF-03 · Debug Logging** : Lifecycle transitions shall be logged in debug mode to demonstrate awareness of state changes during the demo.

---
---

## 3 · Technical Requirements

### 3.1 : Architecture Overview

The application follows **Clean Architecture-lite**, organized into three inward-dependent layers:

| Layer | Responsibility | Key Components |
|---|---|---|
| **Presentation** | UI widgets, BLoC consumers, route definitions, UI state rendering (Loading / Error / Offline) | Screens, Widgets, BLoCs, Route configuration |
| **Domain** | Business logic, use cases, and entity definitions. Framework-agnostic. | Entities, Use Cases, Repository interfaces (abstract) |
| **Data** | API communication, local database operations, and mapper functions | Remote Data Sources, Local Data Sources, Repository implementations, DTOs and mappers |

---

### 3.2 : State Management Architecture

All screens use BLoC (Business Logic Component). Each feature area has a dedicated BLoC that emits typed states:

| BLoC | Events (Inputs) | States (Outputs) |
|---|---|---|
| **AuthBloc** | `LoginRequested`, `BiometricRequested`, `LogoutRequested` | `AuthInitial`, `AuthLoading`, `Authenticated`, `AuthError` |
| **AnnouncementsBloc** | `FetchAnnouncements`, `RefreshAnnouncements` | `AnnouncementsLoading`, `AnnouncementsLoaded`, `AnnouncementsError`, `AnnouncementsOffline` |
| **EventsBloc** | `FetchEvents`, `AttachPhoto` | `EventsLoading`, `EventsLoaded`, `EventsError` |
| **TimetableBloc** | `FetchTimetable`, `ExportSchedule` | `TimetableLoading`, `TimetableLoaded`, `TimetableError` |
| **SettingsBloc** | `ToggleTheme`, `ToggleNotifications`, `ChangeLanguage` | `SettingsState` (single state with properties) |
| **ConnectivityBloc** | `ConnectivityChanged` | `ConnectedState`, `DisconnectedState` |
| **LocationBloc** | `RequestLocation`, `TrackPosition` | `LocationInitial`, `LocationGranted`, `LocationDenied`, `LocationTracking` |

---

### 3.3 : Folder Structure

The project follows a **feature-first** organization within Clean Architecture layers:

```
lib/
├── core/
│   └── error/ · network/ · theme/ · constants/ · utils/
├── features/
│   ├── auth/           → data/ | domain/ | presentation/
│   ├── announcements/  → data/ | domain/ | presentation/
│   ├── events/         → data/ | domain/ | presentation/
│   ├── timetable/      → data/ | domain/ | presentation/
│   ├── map/            → data/ | domain/ | presentation/
│   └── settings/       → data/ | domain/ | presentation/
├── config/
│   └── routes.dart · injection_container.dart
└── main.dart
```

---

### 3.4 : Package Dependencies

| Category | Package | Purpose |
|---|---|---|
| **Networking** | `dio` | HTTP client with interceptors, timeouts, and retry support |
| **Connectivity** | `connectivity_plus` | Real-time network state monitoring |
| **Secure Storage** | `flutter_secure_storage` | AES-encrypted key-value storage for tokens |
| **Preferences** | `shared_preferences` | Lightweight storage for user settings |
| **Database** | `drift` (or `sqflite`) | Typed SQL database for structured offline caching |
| **Auth** | `local_auth` | Biometric authentication (fingerprint/face) |
| **Camera** | `image_picker` | Camera and gallery access for photo attachments |
| **Permissions** | `permission_handler` | Unified runtime permission request API |
| **Location** | `geolocator` | GPS coordinate retrieval |
| **Map** | `google_maps_flutter` | Campus map rendering with POI markers |
| **Notifications** | `flutter_local_notifications` | Local notification scheduling and payloads |
| **Background** | `workmanager` | Periodic background fetch tasks |
| **Sensors** | `sensors_plus` | Accelerometer data for shake-to-refresh |
| **File I/O** | `path_provider` | Access to app-sandboxed document directories |
| **State Mgmt** | `flutter_bloc` | BLoC pattern implementation and widgets |

---
---

## 4 · UI Mockup Definitions

> These definitions serve as blueprints for the Presentation layer implementation in Weeks 2–4. Each mockup specifies the widget hierarchy, data bindings, UI states, and accessibility requirements. No Dart code is included at this stage.

---

### 4.1 : Login Screen

**Route:** `/login` · **BLoC:** `AuthBloc`


**App Logo + Title** `Image + Text` : Centered at top; static branding.

**Email Field** `TextFormField` : Validates email format; shows inline error on invalid input.

**Password Field** `TextFormField (obscured)` : Toggle visibility icon; minimum 6 characters.

**Login Button** `ElevatedButton` : Dispatches `LoginRequested` to AuthBloc. Disabled during `AuthLoading` state. Shows `CircularProgressIndicator` when loading.

**Biometric Button** `IconButton (fingerprint)` : Visible only if biometric is enrolled. Dispatches `BiometricRequested`. Falls back to password on failure.

**Error Banner** `SnackBar / Inline Text` : Displays `AuthError` message (e.g., "Invalid credentials"). Dismissible.

>  **Accessibility:** All fields carry semantic labels. Error messages are announced via screen reader. Minimum tap target size: 48×48 dp.

---

### 4.2 : Home Screen (Dashboard)

**Route:** `/home` · **BLoCs:** `AnnouncementsBloc`, `TimetableBloc`, `ConnectivityBloc`

**Offline Banner** `Container (amber background)` : Visible when `ConnectivityBloc` emits `DisconnectedState`. Persistent, non-dismissible. Text: *"You are offline : showing cached data."*

**Greeting Header** `Text` : Displays "Good [morning/afternoon], [User]" based on system clock.

**Next Class Card** `Card widget` : Shows the next upcoming timetable entry (title, time, room). Tappable → navigates to `/timetable/:id`.

**Recent Announcements** `ListView (horizontal, max 5)` : Horizontal scrollable cards showing the 5 most recent announcements. Each card: title (2 lines), timestamp. Tappable → `/announcements/:id`.

**Quick Actions Row** `Row of IconButtons` : Icons: Calendar (Timetable), Megaphone (Announcements), Map Pin (Campus Map), Gear (Settings). Each navigates to the respective route.

**Upcoming Events** `ListView (vertical, max 3)` : Vertical cards with event title, date, and location. Tappable → `/events/:id`.

> **UI States** : **Loading:** Shimmer placeholders for all cards and lists. **Error:** "Failed to load dashboard" with Retry button. **Offline:** Banner shown; all data sourced from local database.

---

### 4.3 : Announcements Screen

**Route:** `/announcements` · **BLoCs:** `AnnouncementsBloc`, `ConnectivityBloc`


**Offline Banner** `Container` : Same as Home screen.

**Search Bar** `TextField with debounce` : Filters announcements locally by title. 300ms debounce.

**Announcements List** `ListView.builder` : Paginated, lazy-loaded. Each item: title, excerpt (2 lines), timestamp, read/unread indicator.

**Pull-to-Refresh** `RefreshIndicator` : Dispatches `RefreshAnnouncements`; disabled in offline mode.

**Empty State** `Column (icon + text)` : "No announcements yet" with illustration.

**Item Tap** `Navigation` : Navigates to `/announcements/:id` (detail view with full body text).

> **UI States** : **Loading:** Shimmer list of 6 placeholder items. **Error:** Centered error message with Retry. **Offline:** Banner + cached list.

---

### 4.4 : Events Screen

**Route:** `/events` · **BLoCs:** `EventsBloc`, `ConnectivityBloc`


**Offline Banner** `Container` : Same pattern as above.

**Events List** `ListView.builder` : Each item: event title, date/time, location name, optional thumbnail.

**Event Detail View** `Scaffold` : Route: `/events/:id`. Full description, date, location, and an "Attach Photo" button.

**Attach Photo Button** `ElevatedButton` : Requests camera/gallery permission via `permission_handler`. Opens `image_picker` bottom sheet (Camera / Gallery). Stores selected image path with the event note locally.

**Permission Denied State** `AlertDialog` : If permission denied: explains rationale. If permanently denied: button to open app settings.

---

### 4.5 : Timetable Screen

**Route:** `/timetable` · **BLoC:** `TimetableBloc`


**Day Selector** `TabBar (Mon–Fri)` : Filters displayed entries by selected day.

**Class List** `ListView` : Each entry: course name, time range, room number, instructor.

**Reminder Toggle** `Switch per entry` : Enables/disables a local notification 10 minutes before the class.

**Export Button** `FloatingActionButton` : Dispatches `ExportSchedule`. Serializes timetable to JSON, saves via `path_provider`, shows a SnackBar confirmation with file path.

---

### 4.6 : Campus Map Screen

**Route:** `/map` · **BLoC:** `LocationBloc`


**Google Map Widget** `GoogleMap` : Centered on campus coordinates. Displays predefined POI markers (library, cafeteria, lecture halls).

**User Location Marker** `Marker (blue dot)` : Visible only after location permission granted. Updates in real-time via `geolocator` stream.

**POI Info Card** `BottomSheet` : Appears on marker tap. Shows POI name, description, and distance from user.

**Permission Prompt** `AlertDialog` : First launch: requests location. On denial: rationale dialog. On permanent denial: settings redirect.

---

### 4.7 : Settings Screen

**Route:** `/settings` · **BLoCs:** `SettingsBloc`, `AuthBloc`


**Theme Toggle** `SwitchListTile` : Toggles between light and dark mode. Persisted in `SharedPreferences`. Applied globally via `ThemeData`.

**Notification Preferences** `SwitchListTile (×2)` : Class Reminders toggle, Announcement Alerts toggle. Changes dispatched to `SettingsBloc` and persisted.

**Language Selector** `DropdownButton` : Options: English, French, Arabic *(optional extension)*. Persisted in `SharedPreferences`.

**Export Schedule** `ListTile with trailing icon` : Navigates to the timetable export flow.

**About / Version** `ListTile` : Displays app version, build number, and link to project repository.

**Logout Button** `ElevatedButton (red)` : Dispatches `LogoutRequested` to `AuthBloc`. Clears secure storage. Navigates to `/login` and clears the navigation stack.

---
---

## 5 · Navigation Skeleton

### 5.1 : Route Architecture

The application uses **named routes** managed through `onGenerateRoute` for centralized control, deep-link support, and argument passing. A route guard checks `AuthBloc` state before granting access to authenticated routes.

| Route Path | Screen | Auth Required | Arguments |
|---|---|---|---|
| `/login` | `LoginScreen` | No | : |
| `/home` | `HomeScreen` (Dashboard) | **Yes** | : |
| `/announcements` | `AnnouncementsListScreen` | **Yes** | : |
| `/announcements/:id` | `AnnouncementDetailScreen` | **Yes** | `announcementId (int)` |
| `/events` | `EventsListScreen` | **Yes** | : |
| `/events/:id` | `EventDetailScreen` | **Yes** | `eventId (int)` |
| `/timetable` | `TimetableScreen` | **Yes** | : |
| `/map` | `CampusMapScreen` | **Yes** | : |
| `/settings` | `SettingsScreen` | **Yes** | : |

---

### 5.2 : Navigation Flow

The navigation follows a hierarchical structure with a `BottomNavigationBar` as the primary mechanism for authenticated screens:

**Entry Point** → `main.dart` → `MaterialApp` with `onGenerateRoute`

**Unauthenticated Flow** → `/login` → *[successful auth]* → `/home`

**Authenticated Shell** *(BottomNavigationBar : 4 tabs)*

> **Tab 0 · Home** `/home` → can push `/announcements/:id`, `/events/:id`, `/timetable`
> **Tab 1 · Announcements** `/announcements` → can push `/announcements/:id`
> **Tab 2 · Events** `/events` → can push `/events/:id`
> **Tab 3 · Settings** `/settings` → can push `/map`

**Deep-Link Entry** → Notification payload contains route string → `onGenerateRoute` resolves to target screen with arguments.

---

### 5.3 : Route Guard Logic

The `onGenerateRoute` callback implements the following decision logic:

1. Extract the route name and arguments from `RouteSettings`.
2. If the route is `/login`, return `LoginScreen` regardless of auth state.
3. For all other routes, check if `AuthBloc.state` is `Authenticated`.
4. If authenticated, resolve the route to the corresponding screen widget, injecting required arguments.
5. If not authenticated, redirect to `/login` and clear the navigation stack.
6. If the route is unrecognized, return a `404 NotFoundScreen`.

---

### 5.4 : Deep-Linking via Notifications

When a local notification is tapped, `flutter_local_notifications` delivers a payload string (e.g., `"/timetable/42"`). The app's `onSelectNotification` handler calls `Navigator.pushNamed` with this payload. The `onGenerateRoute` function parses the path, extracts the ID parameter, and renders the correct detail screen.

**Architecture Note:** This satisfies the project requirement for at least one tap action with deep-linking.

---
---

## 6 · Feature-to-OS Concept Traceability Matrix

> The following matrix provides a complete, auditable mapping from every project feature to the Mobile OS concept it demonstrates, the screen(s) where it appears, and the routes involved.

| Feature Area | OS Concept | Screen(s) | Route(s) |
|---|---|---|---|
| Email/Password Login | Security (Secure Storage) | Login | `/login` |
| Biometric Unlock | Security (Biometrics), Permissions | Login | `/login` |
| Session Token Management | Security (Sandboxing) | All (via AuthBloc) | All |
| REST API Fetch | Networking (HTTP, Timeouts) | Home, Announcements, Events, Timetable | `/home`, `/announcements`, `/events`, `/timetable` |
| Offline Data Serving | Storage & Sandboxing (DB) | All data screens | All |
| Connectivity Monitoring | Networking (Awareness) | All data screens (Offline Banner) | All |
| SharedPreferences | Storage (Key-Value) | Settings | `/settings` |
| SQL Database Cache | Storage & Sandboxing | Announcements, Events, Timetable | Multiple |
| JSON File Export | File I/O | Timetable | `/timetable` |
| Camera/Gallery Access | Permissions (Runtime) | Event Detail | `/events/:id` |
| GPS Location | Permissions (Runtime), Sensors | Campus Map | `/map` |
| Accelerometer (Shake) | Sensors | Home, Announcements | `/home`, `/announcements` |
| Local Notifications | Notifications (Scheduling) | Timetable | `/timetable` |
| Notification Deep-Link | Notifications (Payload) | Any detail screen | Dynamic |
| Background Fetch | Background Execution | Announcements (silent) | N/A (background) |
| AppLifecycleState | App Lifecycle | Home (resume refresh) | `/home` |
| Draft Persistence | App Lifecycle + Storage | Event notes | `/events/:id` |

---
---

## 7 · Glossary

**BLoC** : Business Logic Component. A reactive state management pattern that separates business logic from the UI layer using events and states.

**Clean Architecture-lite** : A simplified variant of Uncle Bob's Clean Architecture with three layers (Data, Domain, Presentation) and unidirectional dependency flow.

**Deep-Link** : A mechanism that allows a notification or external URI to navigate directly to a specific screen within the app.

**DTO** : Data Transfer Object. A plain object used to transfer data between the API response and the Domain entity.

**`flutter_secure_storage`** : A Flutter plugin that stores data in platform-native encrypted storage (Keychain on iOS, EncryptedSharedPreferences on Android).

**JSONPlaceholder** : A free, public REST API (`jsonplaceholder.typicode.com`) that returns mock JSON data for prototyping.

**Offline-First** : An architectural approach where the app is designed to function fully from local data, using network connectivity as an enhancement rather than a requirement.

**`onGenerateRoute`** : A Flutter `MaterialApp` callback that centralizes route resolution, enabling argument parsing, route guards, and deep-link handling.

**POI** : Point of Interest. A predefined location on the campus map (e.g., library, cafeteria).

**Shimmer** : A placeholder animation that mimics content layout while data is loading, providing better UX than a spinner.

---

