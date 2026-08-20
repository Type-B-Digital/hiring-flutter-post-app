# NewsBay — Flutter Posts App

A Flutter app built against the [DummyJSON](https://dummyjson.com) API — login, browse posts with search + pagination, view post details.

## What it does

- Login against DummyJSON's `POST /auth/login`, with a session that persists across restarts and gets re-validated against the server.
- Post list (`post_list_screen.dart`) with debounced search and infinite-scroll pagination.
- Post detail screen, plus a minimal profile screen.
- Provider (ChangeNotifier) for state management, with a small repository layer sitting in front of the API.
- Three environments (dev/staging/prod) wired through `--dart-define`.

---

## Setup

Needs Flutter 3.19+ / Dart 3+.

```bash
flutter pub get

# dev
flutter run --dart-define=FLAVOR=DEVELOPMENT --dart-define=API_BASE_URL=https://dummyjson.com --dart-define=PAGINATION_LIMIT=10 --dart-define=SEARCH_DEBOUNCE_MS=300

# staging
flutter run --dart-define=FLAVOR=STAGING --dart-define=API_BASE_URL=https://dummyjson.com --dart-define=PAGINATION_LIMIT=15 --dart-define=SEARCH_DEBOUNCE_MS=500

# production (defaults already match production, so this alone works too)
flutter run --dart-define=FLAVOR=PRODUCTION --dart-define=API_BASE_URL=https://dummyjson.com --dart-define=PAGINATION_LIMIT=20 --dart-define=SEARCH_DEBOUNCE_MS=800
```

Run tests:
```bash
flutter test --coverage
```

Test login: `emilys` / `emilyspass`

---

## Why Provider, not Bloc

Went with Provider mostly because this app is small in scope and I'm just more comfortable with it — I haven't used Bloc enough to move fast with it.

## Architecture

- `lib/repository/` — `AuthRepository`/`PostRepository` as interfaces with `*Impl` classes doing the actual Dio calls. `SessionStorage` wraps `shared_preferences` for the session.
- `AuthProvider` handles login/logout/session state, `PostProvider` handles the post list/search/pagination state.
- Screens read state with `context.watch`/`Consumer<T>` and call into providers with `context.read<T>().method()`. Navigation is `GoRouter`.

Tradeoffs given the timebox:
- Repositories catch `DioException` and rethrow a plain `Exception` with a only a friendly message.
- Auth only gets re-checked when the app relaunches, not while it's already open.
- Kept the UI minimal on purpose.
- `GoRouter`'s redirect always reads from local storage, so it won't fall back to login mid-navigation if the session expires while you're already in the app.

---

## Auth

Session is stored in `shared_preferences` (`lib/repository/session_storage.dart`) as one JSON blob — the whole `AuthUser`, including both tokens. Not how I'd do it for something real, but DummyJSON's tokens are short-lived sandbox tokens anyway, so it didn't feel worth the extra setup here.

On startup, `main()` awaits `AuthRepository.restoreSession()` before `runApp()`, so the very first frame already knows whether you're logged in — no splash screen or loading flash needed. That restore doesn't just trust whatever's cached locally either — it calls `GET /auth/me` with the saved token to check the server still accepts it:
- token still valid → session kept
- server rejects it → session cleared, sent to `/login` (DummyJSON's error codes are inconsistent here — I saw 500 for a malformed token and presumably 401 for an expired one — so any error response gets treated as a rejection)
- server unreachable (offline/timeout) → session kept anyway, fails open

Form validation is just empty-field checks; wrong credentials and network errors get caught in `AuthRepositoryImpl` and mapped to friendly strings ("Invalid username or password.", "No internet connection. Please try again."), shown under the password field via `AuthProvider.errorMessage`.

---

## Data & state

Only the session gets cached locally — posts are always fetched fresh from the API, no local DB.

`PostProvider` keeps a single `_searchQuery`, and both `fetchInitial()` and `fetchMore()` go through one private `_fetchPage({skip})` helper that picks `getPosts` or `searchPosts` depending on whether there's a query — so pagination just keeps working the same way whether you're browsing or searching, using the same `skip`/`limit` mechanics. `hasMore` comes from the API's own `total`/`skip`/response length, nothing tracked separately.

Search is debounced with a plain `dart:async` `Timer` that cancels and restarts on every keystroke, only calling `PostProvider.search()` after `AppConfig.searchDebounceMs` of no typing.

---

## Design

Tried to match the Figma login screen pretty closely — pulled the color palette straight from the exported PNG's pixels, and used `google_fonts` (Poppins) app-wide to get as close to the mockup as I could.

Corners cut given the timebox:
- Only built Login, Post List, and Post Detail to match the design — the Figma file has Dashboard/Profile/Friends/Followers/Chat frames that go beyond the written spec, so those got skipped. The Profile screen that exists is minimal (avatar initials, name, logout) and doesn't match any specific Figma frame — it's mainly there because the logout action needed somewhere to live.
- Didn't replicate the mockup's "Featured Posts" carousel + "Recent Posts" split on the post list — it's a single masonry grid, since DummyJSON posts don't really have a "featured" concept to hang that on.
- "Forgot password?" and "Sign up" on the login screen don't do anything right now. There was a "coming soon" dialog wired up to both at one point, it got removed during a layout cleanup, and I never got around to putting it back. Known gap, listed again below.

Custom widgets: `PostCard`, `PostSearchField`, `LoadingView`, `ErrorView`.

Loading/empty/error states: spinner on first load, retry button on failure, centered "No posts found" text for empty search results, small spinner footer at the bottom of the list while loading more.

---

## API / networking

One `Dio` instance built once in `main()` with `baseUrl: AppConfig.baseUrl` (from `--dart-define=API_BASE_URL`), shared by both `AuthRepositoryImpl` and `PostRepositoryImpl`.

Posts: `GET /posts?skip=&limit=` for browsing, `GET /posts/search?q=&skip=&limit=` for search.

---

## Build config

`--dart-define` flows into a plain `AppConfig` class (`lib/app_config.dart`) via `String.fromEnvironment`/`int.fromEnvironment`.

- `FLAVOR` (`DEVELOPMENT`/`STAGING`/`PRODUCTION`) picks sensible per-environment defaults for `PAGINATION_LIMIT` (10/15/20) and `SEARCH_DEBOUNCE_MS` (300/500/800) — so `--dart-define=FLAVOR=PRODUCTION` alone gets you production's values.
- Any of `PAGINATION_LIMIT`/`SEARCH_DEBOUNCE_MS`/`API_BASE_URL` can still be passed explicitly to override the flavor default.
- `API_BASE_URL` is the same across all three environments on purpose — DummyJSON only has the one public host, so there's nowhere else to point it. The plumbing for different hosts is still there if it's ever needed.

What actually changes between environments right now: page size per request and search debounce delay — checked this by running each flavor and watching the list/search behavior.

---

## Tests

Only got to the state-management layer — `AuthProvider` and `PostProvider`. Given the one-day timebox and still being fairly new to Flutter's testing tools (mocktail, mocking Dio), I prioritized coverage there over the repository/model layers.

Used `mocktail` to mock the repositories (`AuthRepository`, `PostRepository`).

What's covered:
- [x] Auth logic (login success/failure, logout) — session persistence/restore and the `/auth/me` expiry check aren't unit tested
- [ ] Repository layer (API calls, model mapping, error mapping)
- [x] Provider state transitions (loading/error/success for both providers, search updating the list) — pagination (`fetchMore`) specifically isn't covered
- [ ] Model (de)serialization

Coverage report: 28.1% total, 100%/60% on `AuthProvider`/`PostProvider` respectively. Below the 70%+ target I was aiming for — flagging that honestly here rather than inflating it.

---

## Known limitations

- **"Forgot password?" and "Sign up" are inert** on the login screen
- **The JWT is stored and validated but not attached to requests, and session expiry is only detected at app launch.** DummyJSON's other endpoints don't require auth, so `AuthProvider.isLoggedIn` is really just an in-memory check — once you're logged in, nothing re-validates the token for the rest of that session. If the token expires while the app stays open, browsing/searching/opening the profile screen all keep working fine with a dead token — expiry is only ever caught the next time the app re-launches. Re-checking `/auth/me` on each screen would fix this but isn't implemented.
- Simple repository pattern, plain-string error messages — no typed failure hierarchy.
- Unit test coverage is 28.1%, below the 70% target, concentrated on the provider layer only.

---

## What's done

**Auth** — login against DummyJSON, persisted + server-validated session, logout, validation and error handling.

**Posts** — list matching the design (login/list/detail only, see Design above), debounced search, pagination, pull-to-refresh, detail screen, loading/empty/error states.

**Architecture** — repository pattern (lighter version), Provider used throughout, async/await networking, reasonable separation of concerns.

**Config & testing** — three environment configs (dev/staging/prod); unit tests at 28.1% coverage (target was 70%+); auth error paths tested, repository/model edge cases not.

---

## ✅ Feature Completion Checklist

### 🔐 Authentication
- [x] Login screen against DummyJSON
- [x] Token storage and persistent session (with server-side expiry validation via `/auth/me`)
- [x] Logout
- [x] Validation and error handling

### 📱 Dashboard & Posts
- [x] Posts list matching Figma design (login/list/detail only — see Design Implementation)
- [x] Backend search with debounce
- [x] Pagination
- [x] Pull-to-refresh
- [x] Post detail screen
- [x] Loading/empty/error states

### 🏗️ Architecture & Data
- [x] Repository pattern implemented (lighter version — see Architecture & Rationale)
- [x] Provider used consistently
- [x] Async/await networking
- [x] Proper separation of concerns

### ⚙️ Configuration & Testing
- [x] Three environment configs (Dev/Staging/Production)
- [ ] Unit tests with 70%+ coverage on business logic (28.1% achieved — see Unit Testing Coverage)
- [ ] Edge cases and error scenarios tested (auth error paths covered; repository-layer and model edge cases are not)

### 📋 Documentation & Quality
- [x] Clean, readable code
- [x] README with setup instructions
- [x] Demo video included
