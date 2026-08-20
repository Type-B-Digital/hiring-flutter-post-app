# Flutter Posts App - Pull Request Template

## 🚀 Description

- Implemented login against the DummyJSON API (`POST /auth/login`) with a persisted, server-validated session
- Built a posts list (post_list_screen.dart) with debounced backend search and infinite-scroll pagination, using a masonry grid so cards size to their own content
- Built a post detail screen and a minimal profile screen (avatar initials, name, logout)
- Used **Provider** (ChangeNotifier) + a lightweight repository layer (interface + impl) for posts and auth
- Wired three environments (Dev/Staging/Production) via `--dart-define`, with `PAGINATION_LIMIT` and `SEARCH_DEBOUNCE_MS` actually affecting app behavior per environment

---

## 🏗️ Architecture & Solution Rationale

**Provider over Bloc:** chosen for the size of this app — a handful of screens with fairly simple state transitions (loading/data/error, logged-in/out). Bloc's event→state ceremony would add boilerplate without buying much here; `ChangeNotifier` + `Consumer`/`context.watch` covers everything needed with less code to read.

**Repository layer:** each feature has an abstract interface (`AuthRepository`, `PostRepository`) with a concrete `*Impl` class in the *same file* — a deliberate simplification from a stricter "interface file / impl file / remote data source file / local data source file" split. For a repository this small (2-3 methods each, one HTTP client), that split felt like ceremony without payoff. The one genuine separate data source is `SessionStorage` (shared_preferences wrapper) for auth's local persistence; the "remote data source" for both features is just the `dio` calls inline in the `*Impl` class.

**Tradeoffs given the timebox:**
- No typed `Failure` class hierarchy (`NetworkFailure`/`AuthFailure`/etc.) — repositories catch `DioException` and rethrow a plain `Exception` with a friendly message instead. Widgets never see a raw exception, but it's not the fully "typed" version the spec describes.
- No native Android/iOS flavor splitting — environments are `--dart-define` only.
- Scope trimmed to Login → Post List → Post Detail (+ a minimal Profile screen), matching what was actually specified in writing; the Figma file's Dashboard/Friends/Followers/Chat frames weren't built since they weren't in the written requirements.

**Architecture Overview:**
- **Repository layer:** `AuthRepository`/`PostRepository` interfaces + `*Impl` (dio calls) in `lib/repository/`; `SessionStorage` (shared_preferences) as the local data source for the session.
- **State management layer:** `AuthProvider` (login/logout/session state) and `PostProvider` (list/search/pagination state), both `ChangeNotifier`s in `lib/provider/`, constructed once in `main()` and provided via `MultiProvider`.
- **Widget layer:** screens read state via `context.watch`/`Consumer<T>` and dispatch actions via `context.read<T>().method()`; `GoRouter`'s `redirect` reacts to `AuthProvider` (via `refreshListenable`) to gate `/posts`/`/profile` behind login.

---

## 🔐 Authentication Implementation

**Token storage:** `shared_preferences` (`lib/repository/session_storage.dart`), storing the whole `AuthUser` (profile + `accessToken`/`refreshToken`) as one JSON string. Chose this over `flutter_secure_storage`/Hive because DummyJSON issues short-lived sandbox tokens with nothing sensitive behind them — the extra native-platform setup secure storage needs isn't worth it here, though it would be the right call for a real production token.

**Session persistence across restarts:** `main()` awaits `AuthRepository.restoreSession()` *before* `runApp()`, so the very first frame already knows whether the user is logged in — no splash screen or transitional loading state needed. `restoreSession()` doesn't just trust whatever's cached locally: it calls `GET /auth/me` with the saved token as a Bearer header to confirm the server still accepts it.
- Token still valid → session kept.
- Server rejects it (confirmed via testing: DummyJSON returns inconsistent status codes — 500 for a malformed token, presumably 401 for a cleanly-expired one — so *any* real error response is treated as rejection) → session cleared, user routed to `/login`.
- Server unreachable (offline/timeout) → session is kept regardless ("fails open"), so a bad connection at launch doesn't wrongly log out a legitimately signed-in user.

**Error handling:** empty-field validation on the form; wrong credentials and network failures are caught in `AuthRepositoryImpl` and mapped to friendly strings (`"Invalid username or password."`, `"No internet connection. Please try again."`), surfaced via `AuthProvider.errorMessage` and shown inline under the password field.

**Credentials used for testing:**
- Username: `emilys`, Password: `emilyspass` (pre-filled in the login form for convenience during review)

---

## 💾 Data & State Management

**Cached vs. fresh:** only the auth session is cached locally (shared_preferences). Posts are always fetched fresh from the API — no local post cache/database, since DummyJSON's `/posts` is fast and cheap to call and there's no offline-browsing requirement.

**Pagination + search interaction:** `PostProvider` holds a single `_searchQuery` string. Both `fetchInitial()` and `fetchMore()` funnel through a private `_fetchPage({skip})` helper that picks `getPosts` or `searchPosts` based on whether `_searchQuery` is empty — so pagination transparently continues through search results using the same `skip`/`limit` mechanism as normal browsing. `hasMore` is derived from the API's own `total`/`skip`/response-length rather than tracked separately.

**Debounce:** `PostSearchField` (`lib/widgets/search_bar.dart`) uses a `dart:async` `Timer`, cancelling and restarting on every keystroke, only calling `PostProvider.search()` after `AppConfig.searchDebounceMs` of no typing (300/500/800ms across Dev/Staging/Production).

---

## 🎨 Design Implementation

Matched the Figma file's login screen closely: color palette values were sampled directly from the exported PNG's pixels (not just the labeled swatches) — this caught that the login header's gradient doesn't actually end at the labeled "Primary2" swatch (a near-black green), but at a much lighter muted teal; the code follows the sampled value, not the mislabeled swatch. Used `google_fonts` (Poppins) app-wide, pill-shaped buttons/inputs, and rounded cards to match the mockup's visual language.

**Cut corners given the timebox:**
- Only Login, Post List, and Post Detail were built to match the design; the Figma file's Dashboard/Profile/Friends/Followers/Chat frames go beyond the written spec and weren't implemented (a minimal Profile screen — avatar initials, name, logout — was added since the app bar needed *somewhere* for the logout action to live, but it doesn't match any specific Figma frame).
- The Post List doesn't replicate the mockup's "Featured Posts" horizontal carousel + "Recent Posts" split — it's a single masonry grid, since DummyJSON's posts have no "featured" concept.
- "Forgot password?" and "Sign up" on the login screen are currently inert (no dialog, no action) — an earlier iteration had a "coming soon" dialog wired to both, which was later removed to simplify layout and never re-added. **Known gap**, see below.

**Custom widgets:** `PostCard` (masonry-friendly card with an even-on-all-sides shadow via a custom `BoxShadow`, since Material's `Card` elevation only really shows on the bottom); `PostSearchField` (debounced); `LoadingView`/`ErrorView` (generic, reused across list/detail states).

**Loading/empty/error states:** spinner (`LoadingView`) on first load; `ErrorView` with a retry button on failure; centered "No posts found" text when a search returns nothing; a small spinner footer at the bottom of the list while a `fetchMore()` page load is in flight.

---

## 🔌 API Integration & Networking

**dio setup:** a single `Dio` instance built once in `main()` with `baseUrl: AppConfig.baseUrl` (from `--dart-define=API_BASE_URL`), shared by both `AuthRepositoryImpl` and `PostRepositoryImpl`.

**Error mapping strategy:** `DioException` → caught inside the repository → mapped to a plain `Exception` carrying a human-readable message → caught again in the relevant `Provider`, exposed as a `String?` (`errorMessage`/`error`) → rendered directly in the UI. No raw exception or status code ever reaches a widget. (As noted above, this is a plain-string approach rather than a typed `Failure` hierarchy — a conscious simplification, not an oversight.)

**Pagination and search request handling:** `GET /posts?skip=&limit=` for browsing, `GET /posts/search?q=&skip=&limit=` for search — both parsed into the same `PostPage` model (`posts`, `total`, `skip`, `limit`, with a computed `hasMore`).

---

## ⚙️ Build Configuration

`--dart-define` with a plain `AppConfig` class (`lib/app_config.dart`) reading `String.fromEnvironment`/`int.fromEnvironment` — no native flavor splitting.

- `FLAVOR` (`DEVELOPMENT`/`STAGING`/`PRODUCTION`) picks sensible **per-environment defaults** for `PAGINATION_LIMIT` (10/15/20) and `SEARCH_DEBOUNCE_MS` (300/500/800) — so `--dart-define=FLAVOR=PRODUCTION` alone is enough to get production's values.
- Any of `PAGINATION_LIMIT`/`SEARCH_DEBOUNCE_MS`/`API_BASE_URL` can still be passed explicitly and will override the flavor-derived default.
- `API_BASE_URL` is intentionally identical across all three environments (`https://dummyjson.com`) — DummyJSON only exposes one public host, so there's nothing real to point environments at differently; the plumbing to do so is in place regardless.

**What actually differs between environments:** page size per request and search debounce delay — verified by running each flavor and observing the post list/search behavior change accordingly.

---

## 🧪 Unit Testing Coverage

**Coverage achieved:** 28.1% overall (`flutter test --coverage`, `coverage/lcov.info`), concentrated entirely in the state-management layer:
- `lib/provider/auth_provider.dart` — 100% (14/14 lines)
- `lib/provider/post_provider.dart` — 60% (21/35 lines)
- Repository layer, models, and `app_config.dart` — 0% (untested)

**What's tested vs. not, and why:** given the one-day timebox and still-growing familiarity with Flutter's testing tools (mocktail, dio mocking), coverage was prioritized on `AuthProvider`/`PostProvider` — the most behavior-dense, most bug-prone code, and the layer a bug in would be most visible to a user. Repository-layer tests (mocking `dio` directly — `registerFallbackValue`, argument matchers, `DioException` type discrimination) and model (de)serialization tests were left out; those are the natural next layer to add coverage to, but weren't reached in the time available.

**Mocking approach:** `mocktail`, mocking the repository *interfaces* (`AuthRepository`, `PostRepository`) rather than `dio` directly — this keeps the provider tests fast and simple, at the cost of not covering the HTTP-error-mapping logic inside the repository implementations themselves.

**Testing checklist:**
- [x] Auth logic (login success/failure, logout) — session persistence/restore and the `/auth/me` expiry check are implemented but not unit tested
- [ ] Repository layer (API calls, model mapping, error mapping)
- [x] ChangeNotifier state transitions (loading/error/success for both providers, search updating the list) — pagination (`fetchMore`) specifically isn't covered
- [ ] Data model (de)serialization

**Coverage report:** 28.1% total; 100%/60% on `AuthProvider`/`PostProvider` respectively (see breakdown above). Below the 70%+ target — flagged honestly rather than inflated.

---

## 🎥 Demo Video

[Add Loom link here]

---

## 📌 Known Limitations / Assumptions

- **"Forgot password?" and "Sign up" are inert** on the login screen (no dialog, no navigation) — a "coming soon" dialog existed at one point and was dropped during layout cleanup; should be restored before this ships anywhere real.
- **The JWT is stored and validated but not attached to requests, and session expiry is only detected at app launch.** `accessToken` is persisted and checked against `GET /auth/me` on restore, but it's never sent as an `Authorization` header on `/posts`/`/posts/search` calls, since those DummyJSON endpoints don't require auth. A practical consequence: `AuthProvider.isLoggedIn` is just an in-memory `user != null` check — once you're logged in, nothing re-validates the token against the server for the rest of that app session. If the token expires while the app stays open (e.g. testing with a short `expiresInMins`), browsing/searching/refreshing the post list, or opening the profile screen, all keep working normally with the dead token — expiry is only ever caught the *next time the app is cold-launched*, when `restoreSession()` runs its `/auth/me` check again. Fixing this properly would mean attaching the token to every request and reacting to a 401 with a forced logout, and/or periodically re-checking `/auth/me` on a timer while the app is active — neither is implemented.
- **`API_BASE_URL` doesn't differ across environments** — see Build Configuration above; this matches the assignment's own stated values, not an oversight.
- **Repository pattern is a lighter version of the spec's "interface → impl → remote/local data sources" description** — no separate remote-data-source class exists distinct from the repository `*Impl`.
- **No typed `Failure` class hierarchy** — plain friendly-`String` error messages are used instead throughout.
- **Scope is Login → Post List → Post Detail (+ minimal Profile) only** — the Figma file's Dashboard/Friends/Followers/Chat frames were not built; they weren't described in the written spec.
- **Unit test coverage is 28.1%, below the 70% target**, concentrated on the provider/state-management layer only — see Unit Testing Coverage above for the honest breakdown and reasoning.
- **No native Android/iOS flavors** — the bonus flavor-splitting item was not attempted.
- **Dark mode is implemented in the theme (`ThemeProvider`/`AppTheme.darkTheme`) but has no UI control to toggle it** — an earlier app-bar toggle button was removed during a design pass and not replaced.

---

## 🛠️ Setup Instructions

**Prerequisites:**
- Flutter 3.19+ / Dart 3+

**Run:**
```bash
flutter pub get

# Dev
flutter run --dart-define=FLAVOR=DEVELOPMENT --dart-define=API_BASE_URL=https://dummyjson.com --dart-define=PAGINATION_LIMIT=10 --dart-define=SEARCH_DEBOUNCE_MS=300

# Staging
flutter run --dart-define=FLAVOR=STAGING --dart-define=API_BASE_URL=https://dummyjson.com --dart-define=PAGINATION_LIMIT=15 --dart-define=SEARCH_DEBOUNCE_MS=500

# Production
flutter run --dart-define=FLAVOR=PRODUCTION --dart-define=API_BASE_URL=https://dummyjson.com --dart-define=PAGINATION_LIMIT=20 --dart-define=SEARCH_DEBOUNCE_MS=800
```

**Test:**
```bash
flutter test --coverage
```

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
- [ ] README with setup instructions (setup instructions are in this PR description; a standalone README wasn't added)
- [ ] Demo video included
