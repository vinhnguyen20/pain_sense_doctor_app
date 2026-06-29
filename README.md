# Back Belt App — Doctor Portal

Flutter mobile application for doctors to monitor patients via a BLE-connected back belt device. Provides real-time sensor tracking, patient communication, diary management, goal setting, and exercise education.

**Version:** 0.1.0 | **Dart SDK:** ^3.8.1 | **Flutter:** Stable

---

## Table of Contents

1. [Environment Setup](#environment-setup)
2. [Commands](#commands)
3. [Features](#features)
4. [Architecture](#architecture)
5. [Project Structure](#project-structure)
6. [Key Patterns](#key-patterns)
7. [Dependencies](#dependencies)
8. [Routing](#routing)
9. [Data Models](#data-models)

---

## Environment Setup

1. Copy `.env.example` to `.env` in the project root:

```bash
cp .env.example .env
```

2. Fill in values:

```
BASE_URL=http://<server-ip>:<port>
```

The config derives:

- **API base:** `{BASE_URL}/api/v1`

The `.env` file is declared under `flutter.assets` in `pubspec.yaml` and loaded at startup via `flutter_dotenv`.

---

## Commands

```bash
# Install dependencies
flutter pub get

# Run app
flutter run

# Code generation (run after modifying @riverpod classes or JSON models)
flutter pub run build_runner build

# Clean generated files
flutter pub run build_runner clean

# Clean build artifacts
flutter clean

# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Build release APK
flutter build apk --release

# Build iOS IPA
flutter build ipa
```

---

## Features

| Feature                   | Description                                                             |
| ------------------------- | ----------------------------------------------------------------------- |
| **Authentication**        | Email/password login, automatic token refresh, secure storage           |
| **Patient Dashboard**     | LBP score tracking, 7-day trends, adherence metrics, AI recommendations |
| **Real-time Messaging**   | WebSocket chat with auto-reconnect, image sharing                       |
| **BLE Sensor Monitoring** | Temperature, pressure, humidity, steps, cadence from back belt device   |
| **Patient Diary**         | Daily entries, activity logging, goal progress                          |
| **Exercise Education**    | Exercise library, sessions, reviews                                     |
| **Patient Management**    | Doctor-side patient list, profiles, emergency contacts                  |
| **Goal Management**       | Create/edit/delete patient goals with consent tracking                  |

---

## Architecture

Clean Architecture per feature, MVVM presentation layer:

```
lib/
├── core/               # Shared infrastructure
│   ├── config/         # App config, router, theme
│   ├── network/        # Dio client, interceptors, error handling
│   ├── services/       # Token service, local storage
│   ├── providers/      # Core Riverpod providers
│   ├── constants/      # App-wide constants
│   └── utils/          # Date helpers, utilities
│
├── common/widgets/     # Reusable UI components
│
├── features/           # Feature modules
│   ├── auth/
│   ├── chats/
│   ├── diary/
│   ├── education/
│   ├── tracking/
│   ├── user/
│   └── settings/
│
└── presentations/      # Top-level pages
    └── pages/
        ├── home/
        ├── dashboard/
        ├── patient_monitor_detail/
        └── settings/
```

Each feature follows the same layer structure:

```
<feature>/
├── data/
│   ├── datasources/    # Remote API / WebSocket / BLE
│   ├── models/         # JSON-serializable models
│   └── repository/     # Repository implementations
├── domain/
│   ├── entities/       # Pure Dart business objects
│   ├── repository/     # Abstract interfaces
│   └── usecases/       # Single-responsibility use cases
└── presentation/
    ├── pages/          # Screen widgets
    ├── provider/       # Riverpod notifiers & providers
    └── widgets/        # Feature-specific widgets
```

---

## Project Structure

<details>
<summary>Full directory tree</summary>

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── config/
│   │   ├── app_config.dart
│   │   ├── routers/
│   │   │   ├── router.dart
│   │   │   └── bottom_navigation.dart
│   │   └── theme/
│   │       ├── app_theme.dart
│   │       ├── color_system.dart
│   │       ├── design_tokens.dart
│   │       └── responsive_extension.dart
│   ├── network/
│   │   ├── dio/
│   │   │   ├── dio_client.dart
│   │   │   ├── auth_interceptor.dart
│   │   │   ├── api_response.dart
│   │   │   └── paginated_response.dart
│   │   ├── socket/
│   │   │   └── socket_client.dart
│   │   └── errors/
│   │       ├── exception_handler.dart
│   │       ├── error_logger.dart
│   │       └── app_exception.dart
│   ├── services/
│   │   ├── auth/token_service.dart
│   │   └── storage/local_storage_service.dart
│   ├── providers/
│   │   ├── dio_provider.dart
│   │   ├── storage_provider.dart
│   │   └── theme_notifier.dart
│   ├── constants/app_constants.dart
│   └── utils/
│       ├── date_utils_helper.dart
│       ├── entity_convertible.dart
│       └── utils.dart
│
├── common/widgets/
│   ├── app_button.dart
│   ├── app_snackbar.dart
│   ├── custom_app_bar.dart
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   ├── error_retry_view.dart
│   ├── section.dart
│   └── tab_bar_widget.dart
│
├── features/
│   ├── auth/
│   │   ├── data/datasources/auth_remote_datasource.dart
│   │   ├── data/models/user_model.dart
│   │   ├── data/repository/auth_repository_impl.dart
│   │   ├── domain/entities/             # AuthToken, User
│   │   ├── domain/repository/auth_repository.dart
│   │   ├── domain/usecases/sign_in_with_email_password_usecase.dart
│   │   └── presentation/
│   │       ├── pages/login_page.dart
│   │       └── provider/auth_notifier.dart
│   │
│   ├── chats/
│   │   ├── data/datasources/
│   │   │   ├── chat_ws_datasource.dart        # WebSocket + auto-reconnect
│   │   │   ├── chat_remote_datasource.dart
│   │   │   └── appointment_remote_datasource.dart
│   │   ├── data/models/                        # ChatWsEvent (union), Message, Conversation
│   │   ├── domain/entities/                    # Message, Conversation
│   │   ├── domain/usecases/                    # send, upload, paginate
│   │   └── presentation/
│   │       ├── pages/chat_room_page.dart
│   │       └── provider/
│   │           ├── chat_room_notifier.dart     # WS lifecycle manager
│   │           ├── conversation_notifier.dart
│   │           └── appointment_notifier.dart
│   │
│   ├── diary/
│   │   ├── data/                               # Diary + Goal models & datasource
│   │   ├── domain/entities/                    # Diary, GoalType (enum)
│   │   ├── domain/usecases/                    # get/update/delete diary & goals
│   │   └── presentation/provider/patient_diary_notifier.dart
│   │
│   ├── education/
│   │   ├── data/                               # Exercise models
│   │   ├── domain/entities/                    # Exercise, ExerciseSession, Review
│   │   └── presentation/provider/
│   │       ├── education_provider.dart
│   │       └── exercise_picker_notifier.dart
│   │
│   ├── tracking/
│   │   ├── data/                               # SensorSnapshot, TrackingLog models
│   │   ├── domain/entities/                    # SensorSnapshot, TrackingSummary
│   │   ├── domain/usecases/get_patient_tracking_summary_7days_use_case.dart
│   │   └── presentation/provider/tracking_providers.dart
│   │
│   ├── user/
│   │   ├── data/                               # User, Patient models
│   │   ├── domain/entities/                    # User, Patient (extends User)
│   │   ├── domain/usecases/                    # get/update user & patients
│   │   └── presentation/provider/
│   │       ├── patients_notifier.dart
│   │       └── user_notifier.dart
│   │
│   └── settings/
│       └── presentation/provider/settings_notifier.dart
│
└── presentations/pages/
    ├── home/
    │   ├── page/home_page.dart
    │   └── widgets/patient_card.dart
    ├── dashboard/
    │   ├── page/patient_dashboard_page.dart
    │   └── widgets/                            # LBP score, trends, goals
    ├── patient_monitor_detail/
    │   ├── page/
    │   │   ├── patient_monitor_detail_page.dart  # 5-tab monitoring interface
    │   │   └── goal_form_page.dart
    │   └── widgets/                            # Tabs: overview, alerts, chat, diary, goals
    └── settings/
        └── page/settings_page.dart
```

</details>

---

## Key Patterns

### State Management — Riverpod 3.x

Providers are code-generated with `@riverpod`. After modifying any annotated class, run:

```bash
flutter pub run build_runner build
```

Files ending in `.g.dart` are generated — **never edit them manually**.

```dart
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() => const AuthState.initial();
  // ...
}
```

### HTTP Client — DioClient

`DioClient` wraps Dio with typed methods (`get/post/put/patch/delete/uploadFile`). Two interceptors run in order:

1. `_MainApiGuardInterceptor` — ensures `baseUrl` is set from env
2. `AuthInterceptor` — injects `Bearer` token; on 401 it refreshes via a separate Dio instance (no interceptor recursion), retries the request, and calls `forceLogout()` if refresh fails. Uses a `Completer` to deduplicate concurrent refresh attempts.

### Error Handling

All errors flow through `ApiResponse.failure`. The factory calls `ExceptionHandler.handle` and `ErrorLogger.log` internally.

```dart
// Correct
} catch (e, stackTrace) {
  return ApiResponse.failure(e, stackTrace);
}

// Wrong — causes double-invocation
} catch (e, stackTrace) {
  ExceptionHandler.handle(e);          // do NOT call manually
  return ApiResponse.failure(e, stackTrace);
}
```

### Token Storage — TokenService

`keepAlive` Riverpod `AsyncNotifier` backed by `FlutterSecureStorage`:

- Stores: `accessToken`, `refreshToken`, `customToken`
- Token refresh endpoint: `POST /users/refresh-token`

### Real-time Chat — WebSocket

`ChatWsDataSource` manages the WebSocket lifecycle:

- Manual connect/disconnect (no auto-connect)
- Exponential backoff reconnection — max 6 attempts, capped at 20 s delay
- Ping/pong keep-alive every 25 s
- Connection stability reset after 12 s of uptime
- `ChatWsEvent` union type: `connected`, `message.created`, `message.read`, `conversation.updated`, `error`, `disconnected`, `reconnecting`

### Routing — Go Router

Bottom nav with `StatefulShellRoute` (two branches: `/home`, `/setting`). Complex objects passed type-safely via `state.extra`:

```dart
context.push('/patient-monitor-detail', extra: patient);
// In route builder:
final patient = state.extra as Patient;
```

---

## Dependencies

### Runtime

| Package                     | Version          | Purpose                       |
| --------------------------- | ---------------- | ----------------------------- |
| flutter_riverpod            | ^3.0.3           | State management              |
| riverpod_annotation         | ^3.0.3           | Code generation annotations   |
| go_router                   | ^17.0.1          | Declarative routing           |
| dio                         | ^5.9.0           | HTTP client with interceptors |
| flutter_secure_storage      | ^9.2.4           | Encrypted token storage       |
| flutter_dotenv              | ^6.0.0           | `.env` config loading         |
| web_socket_channel          | ^3.0.3           | WebSocket client              |
| rxdart                      | ^0.28.0          | Reactive streams              |
| fl_chart                    | ^1.1.1           | Charts (LBP trends, 7-day)    |
| cached_network_image        | ^3.4.1           | Image caching                 |
| image_picker                | ^1.2.1           | Photo selection               |
| equatable                   | ^2.0.7           | Value equality                |
| intl                        | ^0.20.2          | Date/number formatting        |
| shared_preferences          | ^2.2.2           | Light local storage           |
| url_launcher                | ^6.3.2           | Open URLs / email             |
| timezone / flutter_timezone | ^0.10.1 / ^5.0.2 | Timezone handling             |
| json_annotation             | ^4.9.0           | JSON serialization            |
| pretty_dio_logger           | ^1.4.0           | HTTP logging (debug)          |
| flutter_native_splash       | ^2.4.4           | Splash screen                 |

### Dev / Build

| Package                | Version | Purpose                 |
| ---------------------- | ------- | ----------------------- |
| build_runner           | ^2.10.5 | Code generation runner  |
| riverpod_generator     | ^3.0.3  | Riverpod codegen plugin |
| json_serializable      | ^6.11.2 | JSON codegen plugin     |
| riverpod_lint          | ^3.0.3  | Riverpod lint rules     |
| flutter_lints          | ^4.0.0  | Flutter lint rules      |
| flutter_launcher_icons | ^0.14.4 | App icon generation     |

---

## Routing

```
/login                       LoginPage
/home                        HomePage          (bottom nav branch 1)
/setting                     SettingsPage      (bottom nav branch 2)
/patient-dashboard           PatientDashboardPage
/patient-monitor-detail      PatientMonitorDetailPage
  ├─ Tab: Overview           (LBP score, sensor summary, trends)
  ├─ Tab: Alerts             (device alerts)
  ├─ Tab: Chat               (real-time messaging)
  ├─ Tab: Diary              (diary entries)
  └─ Tab: Goals              (goal list & progress)
/goal-form                   GoalFormPage
/image-viewer                ImageViewerPage
```

All routes are declared in `lib/core/config/routers/router.dart`.

---

## Data Models

### User & Patient

```dart
// User (doctor)
User { id, email, phone, firstName, lastName, gender, birthdate,
       address, emergencyContact, status, authInfo }
// computed: fullName, age

// Patient extends User
Patient { ...User, trackingLogs: [{ lbpScore, status, color }] }
// computed: lbpScoreValue (int), scoreColor (Color from hex)
```

### Auth

```dart
AuthToken { accessToken, refreshToken, customToken? }
```

### Chat

```dart
Conversation { id, participants, lastMessage, unreadCount }
Message      { id, content, senderId, sentAt, type }
Appointment  { id, doctorId, patientId, scheduledAt, status }

ChatWsEvent  // union:
  ChatWsConnected | ChatWsDisconnected | ChatWsReconnecting
  | ChatWsMessageReceived | ChatWsMessageRead | ChatWsConversationUpdated
  | ChatWsError
```

### Tracking

```dart
SensorSnapshot { time, timeAlive, prevDay, status,
                 temp, pressure, humidity, steps, cadence, label, prevStep }
TrackingSummary { date, items: [TrackingSummaryItem] }
```

### Diary & Goals

```dart
Diary              { id, patientId, date, entries }
PatientDiaryEntry  { id, title, activities, createdAt }
UserGoal           { id, type: GoalType, items, consent, progress }
GoalType           // enum: exercise, posture, lifestyle, ...
```

---

## Implementation Notes

**Riverpod generation:** Always re-run `build_runner build` after changing `@riverpod`-annotated files. Never edit `.g.dart` files directly.

**WebSocket robustness:** `ChatWsDataSource` handles flaky mobile networks via exponential backoff (up to 6 retries, max 20 s), a 25 s ping/pong loop, and a 12 s stability timer that resets the retry counter after a stable connection.

**Token refresh deduplication:** `AuthInterceptor` uses a single `Completer<String>` shared across all in-flight requests that receive a 401, so only one `/users/refresh-token` call is made regardless of concurrency.

**Route extras:** Pass any object via `state.extra` and cast it directly in the route builder. No need for query params or JSON encoding for in-app navigation.