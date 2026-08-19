# Flutter Posts App - Pull Request Template

## 🚀 Description
- Implemented login against the DummyJSON API with a persisted session (token stored via `shared_preferences`, checked on app start)
- Built the posts dashboard with backend search (debounced), pagination, pull-to-refresh, and a post detail screen
- Used `flutter_bloc` (Cubit) + a repository layer for both auth and posts

---

## 🏗️ Architecture & Solution Rationale
- Picked Bloc's Cubit API over Provider for explicit, testable state transitions per feature (`AuthCubit`, `PostsCubit`, `SearchCubit`, `PostDetailCubit`) without writing full event classes for a scope this size.
- Repository layer sits between Cubits and networking: `AuthRepository`/`PostRepository` wrap a shared `DioClient`, map raw JSON into typed models, and translate `DioException` into a typed `ApiException` so Cubits never touch Dio directly.
- Given the timebox, I prioritized the auth flow and posts list/detail (the graded surface) over profile/notifications/chat, which are stubbed as `ComingSoonView`.

**Architecture Overview:**
- Repository layer: `DioClient` (base Dio + auth-header interceptor) → `AuthRepository` / `PostRepository` → typed models (`AuthUserModel`, `PostModel`, `PostPage`)
- State management layer: one Cubit per feature slice (auth, posts list, search, post detail), each emitting an immutable state class with `copyWith`
- Widget layer: `BlocProvider`/`BlocBuilder`/`BlocConsumer` — screens read Cubits via `context.read`/`context.watch`, listeners handle one-off side effects (snackbars on error)

---

## 🔐 Authentication Implementation
- Token storage: `shared_preferences` via `LocalStorage` (`storage_keys.dart` for key namespacing) — simplest fit for a bearer token on a timeboxed assessment; no biometric/secure-enclave requirement was specified.
- Session persistence: `AuthGate` calls `AuthCubit.checkAuthStatus()` on start, which checks `LocalStorage.hasToken()` and, if present, calls `GET /auth/me` to validate the token and hydrate the user; on failure it clears the token and falls back to the login screen.
- Error handling: `AuthService`/`AuthRepository` map network/auth failures to `ApiException`, surfaced in the login form via a `SnackBar`.

**Credentials used for testing:**
- Username: `emilys`, Password: `emilyspass`

---

## 💾 Data & State Management
- Posts list is always fetched fresh per page (no local cache) — pagination is `skip`/`limit`-based against DummyJSON, tracked in `PostsState` (`posts`, `hasMore`, `isLoadingMore`, `isRefreshing`).
- Search runs as a separate `SearchCubit`/`SearchState` rather than filtering the posts list in place, so paginated browsing and search results don't fight over the same state.
- Debounce: `SearchCubit.onQueryChanged` cancels any pending `Timer` and starts a new one at `AppConfig.searchDebounceMs` (dart-define, defaults to 300ms); a stale-response guard (`query != state.query`) drops results for a query the user has since changed.

---

## 🎨 Design Implementation
- Matched the provided Figma closely for the login, dashboard, and post detail screens.
- Custom widgets: `AuthTextField`, `PostCard`, `FeaturedPostCard`, `ComingSoonView` (shared placeholder for out-of-scope tabs), `PostsSliverList`.
- Loading/empty/error states are handled per screen (`CircularProgressIndicator`, empty-state messaging with retry actions, `SnackBar` for transient errors).
- **Sign Up is disabled** on the login screen with a "Coming soon" chip — see Known Limitations.

---

## 🔌 API Integration & Networking
- `dio` with a single shared `DioClient`: base URL from `AppConfig.apiBaseUrl`, request interceptor attaches `Authorization: Bearer <token>` when present, `LogInterceptor` configured with headers/bodies off (auth requests carry the password, `/auth/me` carries the token).
- Error mapping: `DioException` → `mapDioException` → typed `ApiException(message)` → Cubits emit a failure state with that message for the UI to render directly.
- Pagination via `skip`/`limit` query params; search via a dedicated `/posts/search?q=` endpoint.

---

## ⚙️ Build Configuration
- Dev/Staging/Production are configured via `--dart-define-from-file`, with `env/dev.json`, `env/staging.json`, `env/prod.json` and matching `.vscode/launch.json` run configs.
- What differs per environment: `PAGINATION_LIMIT` (10 / 15 / 20) and `SEARCH_DEBOUNCE_MS` (300 / 500 / 800); `API_BASE_URL` is the same DummyJSON endpoint across all three since no separate staging/prod backend was provided.

---

## 🧪 Unit Testing Coverage
- Coverage achieved: **25.3%** overall line coverage (`flutter test --coverage`, 222/877 lines).
- What's tested: auth end-to-end — `LocalStorage` (100%), `AuthUserModel` (de)serialization (61%), `AuthRepository` (64%), `AuthState`/`AuthCubit` (87% / 25%), `login_screen` widget test (76%).
- What's **not** tested, and why: the posts feature (`PostsCubit`, `SearchCubit`, `PostDetailCubit`, `PostRepository`, `PostService`) has no dedicated tests — given the one-day timebox I prioritized breadth of features over full test coverage and focused testing effort on the auth flow. This is the main gap I'd close first with more time.
- Mocking approach: `mocktail` for `Dio`/repository doubles, `bloc_test` available as a dev dependency for Cubit state-transition tests (not yet used for the posts Cubits).

**Testing checklist:**
- [x] Auth logic (login success/failure, token persistence, logout, session restore)
- [x] Repository layer (API calls, model mapping, error mapping) — auth only
- [ ] Bloc/ChangeNotifier (state transitions, search debounce, pagination) — posts Cubits untested
- [x] Data model (de)serialization — auth and post models

**Coverage report:** 25.3% overall (see breakdown above); `coverage/lcov.info` generated via `flutter test --coverage`

---

## 🎥 Demo Video
[Add your Loom/screen-recording link here before submitting]

---

## 📌 Known Limitations / Assumptions
- **Sign Up is out of scope**: the login screen shows "Sign up" disabled with a "Coming soon" chip rather than a functional registration flow, since DummyJSON doesn't support real account creation.
- Top Rate, News, and Chat bottom-nav tabs are stubbed with a shared `ComingSoonView` placeholder — out of scope per the assessment's focus on auth + posts.
- Posts feature (Cubits, repository, service) has no unit tests yet (see Testing Coverage above) — the biggest known gap.
- No local caching/offline support for posts; every list load and search hits the network.
- "Remember me" checkbox and "Forgot password?" link are present in the UI per the design but are not wired to any behavior — DummyJSON has no such endpoints.

---

## 🛠️ Setup Instructions

**Prerequisites:**
- Flutter 3.19+ / Dart 3+

**Run:**
```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=https://dummyjson.com --dart-define=PAGINATION_LIMIT=10 --dart-define=SEARCH_DEBOUNCE_MS=300
```

Or using the checked-in env files:
```bash
flutter run --dart-define-from-file=env/dev.json
```

**Test:**
```bash
flutter test --coverage
```

---

## ✅ Feature Completion Checklist

### 🔐 Authentication
- [x] Login screen against DummyJSON
- [x] Token storage and persistent session
- [x] Logout
- [x] Validation and error handling

### 📱 Dashboard & Posts
- [x] Posts list matching Figma design
- [x] Backend search with debounce
- [x] Pagination
- [x] Pull-to-refresh
- [x] Post detail screen
- [x] Loading/empty/error states

### 🏗️ Architecture & Data
- [x] Repository pattern implemented
- [x] Bloc or Provider used consistently
- [x] Async/await networking
- [x] Proper separation of concerns

### ⚙️ Configuration & Testing
- [x] Three environment configs (Dev/Staging/Production)
- [ ] Unit tests with 70%+ coverage on business logic (currently 25.3% overall — auth well covered, posts feature untested)
- [x] Edge cases and error scenarios tested (auth flow only)

### 📋 Documentation & Quality
- [x] Clean, readable code
- [ ] README with setup instructions (README is still the default Flutter template — worth updating before/after this PR)
- [ ] Demo video included
