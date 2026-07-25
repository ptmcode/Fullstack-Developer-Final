# School Management System — Flutter Client

Master's final assignment — **Fullstack Developer** course, Build Bright University.

A Flutter front-end for the School Management System REST API
(Spring Boot + JWT, running at `http://localhost:30033`). It covers **every
endpoint** of the API with a modern, responsive Material 3 UI.

| | |
|---|---|
| State management / DI / routing | **GetX** |
| HTTP | **http** package (single `ApiClient`) |
| Token storage | **flutter_secure_storage** (Keychain / Keystore) |
| Preferences & profile cache | **get_storage** |
| Auth | **JWT** access + refresh token with transparent auto-refresh |

## Demo accounts

| Account | Password | Access |
|---|---|---|
| `admin` | `admin@123` | everything, incl. users / roles / audit |
| `teacher1` | `teacher@123` | master data (read) + enrollments & grades |
| `student1` | `student@123` | read-only |

## Getting started

```bash
# 1. Start the backend (see ../springboot-jwt-api)
cd ../springboot-jwt-api && docker compose up -d   # or ./gradlew bootRun

# 2. Run the app
flutter pub get
flutter run            # pick a device: Chrome, iOS simulator, Android emulator…
```

> Android emulator: the app automatically switches the API host to
> `10.0.2.2` so the emulator can reach your machine's `localhost`.

## Tests

```bash
flutter analyze        # static analysis — 0 issues
flutter test           # unit + widget tests (models, ApiClient refresh flow, widgets)
```

## Features

- **Authentication** — login, logout, forgot / reset password, change password,
  remembered username, cached profile for instant cold-start.
- **JWT lifecycle** — access token attached by `ApiClient`; on 401 the client
  refreshes the token once (single-flight) and retries; an irrecoverable
  session redirects to login.
- **Role-based UI** — every button / menu entry is permission-gated with the
  same `resource.action` codes the backend enforces.
- **Dashboard** — live counters, recent enrollments, recent audit activity.
- **Students / Teachers / Subjects / Classes** — paginated + debounced search,
  create / edit dialogs with validation, soft delete with confirmation.
- **Student detail** — profile, enrollments (enroll / remove), grades
  (record / edit / delete with letter-grade display).
- **Class roster** — per-class enrollment list with enroll / remove.
- **Enrollments** — global list with student & class filters, per-enrollment
  grades dialog.
- **Users & Roles** — user CRUD, role assignment, role-permission matrix editor.
- **Audit logs** — filters for username, action, entity type and date range.
- **Theming** — light / dark Material 3 theme, persisted with GetStorage.

## Project structure (Clean Architecture)

```
lib/
├── main.dart                     # bootstrap: services → runApp
└── app/
    ├── bindings/                 # GetX dependency injection per route
    ├── core/                     # framework-agnostic building blocks
    │   ├── base/                 #   PagedListController<T> (shared list logic)
    │   ├── constants/            #   API endpoints, permission codes
    │   ├── network/              #   ApiClient (http + JWT refresh), ApiException
    │   ├── services/             #   TokenStore/TokenStorageService, PreferencesService, SessionService
    │   ├── theme/                #   Material 3 theme
    │   ├── utils/                #   validators, formatters
    │   └── widgets/              #   shared widgets (list scaffold, chips, dialogs…)
    ├── data/
    │   ├── models/               # immutable DTOs (fromJson/toJson)
    │   └── repositories/         # one repository per API resource
    ├── modules/                  # feature modules: view + controller (+ dialogs)
    │   ├── auth/  splash/  shell/  dashboard/
    │   ├── students/  teachers/  subjects/  classes/
    │   └── enrollments/  users/  roles/  audit/  profile/
    └── routes/                   # route names + GetPage table
```

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the full design
write-up and [`docs/API-MAPPING.md`](docs/API-MAPPING.md) for the
screen ↔ endpoint coverage matrix.
