# Flutter Posts App - Technical Assessment

## 🎯 Core Requirements

### Technology Stack
- Flutter (stable channel, 3.19+) / Dart 3+
- State management: **Bloc (flutter_bloc) or Provider** — pick one and justify the choice in your PR
- `dio` or `http` for networking, async/await throughout
- Local storage: `hive`, `shared_preferences`, or `flutter_secure_storage` for session/token persistence
- DummyJSON API (no OAuth/API key required)
- Three environments — Dev/Staging/Production — via `--dart-define` (or `--dart-define-from-file`)
- `flutter_test` + `mocktail` (+ `bloc_test` if you choose Bloc) for unit testing

### Architecture
- Repository pattern: Presentation (Bloc/Provider) → Domain (repository interface) → Data (repository impl + remote/local data sources)
- Async/await networking, no business logic in widgets
- Backend search with pagination
- Sensible error handling with typed failures (not raw exceptions surfacing in the UI)
- Unit test coverage for business logic (Bloc/ChangeNotifier + repositories)

## 🎨 Design Specifications

### Figma Design Reference
- **Design Link:** [Figma](https://www.figma.com/design/V5MihxWGUW5NnKm6m47xkf/iOS-Posts-App---Technical-Assessment?node-id=3009-19782&t=kuVj5MpFQeWaRoGa-1)
- This is the same design used for our iOS/SwiftUI assessment — reused intentionally so the UI/UX bar is identical across platforms. Match colors, typography, spacing, and layout as closely as time allows.
- **Given the one-day timebox, "reasonably faithful" beats "pixel-perfect."** Don't burn your day on sub-pixel alignment — prioritize correct architecture and tests first (see [Evaluation Criteria](#-evaluation-criteria-100-points)).
- Implement responsive layouts for at least phone-size screens; tablet support is not required.

## 📱 Features to Implement

This assessment is intentionally scoped down from a production feature set so it's completable in a single day. Read [What's In / Out of Scope](#-whats-in--out-of-scope-for-one-day) before you start.

### 1. Authentication

#### Login Flow
- **Login screen** using DummyJSON auth, hardcoded credentials:
  - Username: `emilys` Password: `emilyspass`
  - Username: `michaelw` Password: `michaelwpass`
  - Or any other valid credentials from DummyJSON users
- `POST https://dummyjson.com/auth/login`
- Store the returned JWT locally (Hive / secure storage / shared_preferences — your call, justify it)
- Persistent login state across app restarts
- Form validation and error handling (wrong credentials, network failure, empty fields)

Register screen is **not required** — a "Register" link that shows a "coming soon" state or a minimal mock form is enough if you have time left over.

### 2. Dashboard
- Search bar with real-time backend search (debounced), per the design
- Posts list with backend pagination (infinite scroll or "load more")
- Pull-to-refresh
- Tap a post to view its detail screen
- Loading, empty, and error states — not just the happy path

## 🚫 What's In / Out of Scope for One Day

**In scope (required):**
- Login + persisted session + logout
- Posts list, search, pagination, pull-to-refresh, post detail
- Repository pattern with a real remote data source + a real local data source (even if local storage is just "cache last page")
- Unit tests for repositories and Bloc/ChangeNotifier logic
- 3 environment configs (Dev/Staging/Production)

**Out of scope (do not spend time here):**
- Register flow, token refresh, biometric auth
- Offline-first sync, background sync, push notifications
- Tablet/landscape layouts, animations/transitions polish
- Widget tests, golden tests, integration/E2E tests (unit tests only — see [Testing](#-unit-testing-requirements))
- CI/CD pipelines

If you're unsure whether something is in scope, leave a note in your PR under **Known Limitations / Assumptions** instead of guessing and burning time.

## 🧪 Unit Testing Requirements

### Mandatory Test Coverage
- **Authentication logic**: login success/failure, token persistence, logout, session restore on app start
- **Repository layer**: API calls, response → model mapping, error mapping (network failure, 4xx/5xx, malformed response)
- **Bloc / ChangeNotifier (state management)**: state transitions, search debounce behavior, pagination behavior, loading/error states
- **Data models**: (de)serialization and any validation logic
- Network layer: request formation (query params for search/pagination), response parsing

### Testing Best Practices
- Mock external dependencies (HTTP client, local storage) — do not hit the real network in tests
- Aim for 70%+ coverage on business logic (repositories, Bloc/ChangeNotifier, models). UI widgets are excluded from this target.
- Cover both the happy path and failure/edge cases (empty results, network error, malformed JSON, pagination exhausted)
- Use dependency injection (constructor injection is fine — no DI framework required) so collaborators can be mocked

### What NOT to Test
- Widgets/Views themselves (focus on Bloc/ChangeNotifier instead)
- Third-party package internals
- Trivial getters/setters with no logic

### Test Naming Convention
```dart
test('methodName_scenario_expectedResult', () { ... });
// Example:
test('login_withValidCredentials_returnsUserAndStoresToken', () { ... });
test('fetchPosts_onNetworkError_emitsFailureState', () { ... });
```

### Example Test Structure
```dart
group('AuthRepository', () {
  // login success stores token
  // login with invalid credentials returns a Failure
  // logout clears stored session
  // session is restored from local storage on startup
});

group('PostsBloc / PostsController', () {
  // fetching posts emits loading -> success
  // search debounces and requeries with the query param
  // pagination appends the next page instead of replacing
  // network error emits an error state, not an unhandled exception
});
```

## ⚙️ Build Configuration (Dev / Staging / Production)

Use `--dart-define` (a small `AppConfig` class reading `String.fromEnvironment`/`int.fromEnvironment` is sufficient — no need for native Android/iOS flavor splitting unless you want the bonus points below).

```
# Dev
API_BASE_URL=https://dummyjson.com
PAGINATION_LIMIT=10
SEARCH_DEBOUNCE_MS=300

# Staging
API_BASE_URL=https://dummyjson.com
PAGINATION_LIMIT=15
SEARCH_DEBOUNCE_MS=500

# Production
API_BASE_URL=https://dummyjson.com
PAGINATION_LIMIT=20
SEARCH_DEBOUNCE_MS=800
```

**Bonus (not required):** wire these up as real Flutter flavors (`flutter_flavorizr` or manual `main_dev.dart` / `main_staging.dart` / `main_prod.dart` entry points) with distinct app names/icons per environment.

## 🔌 API Integration

```bash
# Login
POST https://dummyjson.com/auth/login
Headers: { "Content-Type": "application/json" }
Body: { "username": "emilys", "password": "emilyspass", "expiresInMins": 30 }
# Returns: { "accessToken": "...", "refreshToken": "...", "id", "username", "email", ... }
# Invalid credentials -> HTTP 400

# Current user
GET https://dummyjson.com/auth/me
Headers: { "Authorization": "Bearer [accessToken]" }

# Paginated posts
GET https://dummyjson.com/posts?limit=10&skip=0
# Returns: { "posts": [...], "total": 251, "skip": 0, "limit": 10 }
# Use total/skip/limit to know when you've reached the last page (posts.length < limit, or skip+limit >= total)

# Search with pagination
GET https://dummyjson.com/posts/search?q=love&limit=10&skip=0
# Same envelope shape as above. No matches -> { "posts": [], "total": 0, "skip": 0, "limit": 0 }, not an error.

# Single post
GET https://dummyjson.com/posts/1
```

All endpoints above were verified working as documented as of this assessment being written. Full docs: https://dummyjson.com/docs

## 📊 Evaluation Criteria (100 Points)

| Category | Points | What we're looking for |
|---|---|---|
| Architecture & Tech Stack | 25 | Correct repository pattern, clean Bloc/Provider usage, justified state-management choice, separation of concerns |
| Unit Testing | 25 | Coverage of repositories + Bloc/ChangeNotifier, meaningful mocks, happy path + edge cases, test readability |
| Code Quality | 15 | Readability, naming, consistent style, no dead code, appropriate use of `const`/immutability |
| Functionality | 15 | Login, session persistence, search, pagination, pull-to-refresh, post detail all work |
| Visual Accuracy vs Figma | 10 | Reasonably faithful to layout/spacing/type — not pixel-perfect |
| Error Handling | 5 | Typed failures, no unhandled exceptions reaching the UI, sensible empty/error states |
| Build Configuration | 5 | Working Dev/Staging/Production config via dart-define |

## 📋 Deliverables

- Flutter project that builds and runs on at least one platform (iOS or Android simulator/emulator)
- 3 working environment configs (Dev/Staging/Production)
- Unit test suite + coverage report (`flutter test --coverage`)
- README with setup instructions and any hardcoded credentials used
- Short demo video/screen recording (Loom or similar) of the app running

## 🛠️ Setup Instructions

**Prerequisites:**
- Flutter 3.19+ / Dart 3+
- Xcode (iOS) or Android Studio (Android) with a working simulator/emulator

**Run:**
```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=https://dummyjson.com --dart-define=PAGINATION_LIMIT=10 --dart-define=SEARCH_DEBOUNCE_MS=300
```

**Test:**
```bash
flutter test --coverage
# optional HTML report:
genhtml coverage/lcov.info -o coverage/html
```

## ✅ Success Criteria

- App builds and runs; login and dashboard both function against the live DummyJSON API
- Repository pattern cleanly separates data access from business logic from UI
- State management (Bloc or Provider) is used consistently and the choice is justified
- 70%+ unit test coverage on business logic, covering both success and failure paths
- Three environment configs are demonstrably different at runtime

**Timeline: 1 day.** This is intentionally scoped tighter than a production feature set — see [What's In / Out of Scope](#-whats-in--out-of-scope-for-one-day). We'd rather see a smaller surface area done well and tested than a larger surface area rushed.

## 🔐 A Note on Generative AI Tools

The use of generative AI tools (ChatGPT, Claude, GitHub Copilot, or similar) to **write, generate, or complete code, tests, or written answers for this assessment is strictly prohibited.** Every line you submit must be typed and understood by you.

This does **not** ban using AI (or documentation, Stack Overflow, etc.) as a **reference**. You're welcome to ask an AI tool a conceptual question — e.g. "what's the difference between `flutter_bloc`'s `emit` and `add`?" or "how does debouncing typically work in Dart?" — and get a **hint or explanation** back. What's not allowed is pasting a prompt and having it produce the implementation, a test, or a written answer for you to submit as your own. If in doubt, ask yourself: "did I write this, or did I transcribe it?"

Please don't share this assessment externally.
