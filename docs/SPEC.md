below should be done in most human way possible. 

Core Requirements
Technology Stack
Flutter (stable channel, 3.19+) / Dart 3+
State management: Provider
dio  for networking, async/await throughout
Local storage:  shared
_preferences
_
_
storage for session/token
persistence
DummyJSON API (no OAuth/API key required)
Three environments — Dev/Staging/Production — via --dart-define (or --dart-define-from-
file )
flutter
_
test + mocktail (+ bloc test if you choose Bloc) for unit testing

Architecture
Repository pattern: Presentation (Bloc/Provider) → Domain (repository interface) → Data
(repository impl + remote/local data sources)
Async/await networking, no business logic in widgets
Backend search with pagination
Sensible error handling with typed failures (not raw exceptions surfacing in the UI)
Unit test coverage for business logic (Bloc/ChangeNotifier + repositories)
Implement responsive layouts for at least phone-size screens

1. Authentication — Login Flow
Login screen using DummyJSON auth, hardcoded credentials:
Username: emilys Password: emilyspass
Username: michaelw Password: michaelwpass
Or any other valid credentials from DummyJSON users
POST https://dummyjson.com/auth/login
Store the returned JWT locally (Hive / secure storage / shared
_preferences — your call, justify it)
Persistent login state across app restarts
Form validation and error handling (wrong credentials, network failure, empty fields)
Register screen is not required — a "Register" link that shows a "coming soon" state or a minimal
mock form is enough if you have time left over.