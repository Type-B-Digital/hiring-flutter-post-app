# Flutter Posts App

## 🚀 Description
Briefly describe what you implemented.
- Implemented login against the DummyJSON API with persisted session
- Built the posts dashboard with debounced backend search and paginated posts
- Implemented pull-to-refresh and post detail view
- Used flutter_bloc for state management
- Used the repository pattern with separate remote and local data sources
- Used dio for networking and flutter_secure_storage for JWT persistence
- Added Dev, Staging, and Production configuration using --dart-define
- Added unit tests for repositories, Bloc logic, models, and error scenarios

---

## 🏗️ Architecture & Solution Rationale
- I selected Bloc because the application contains multiple event-driven state transitions including login, session restoration, logout, posts loading, pagination, refresh, and debounced search. Bloc provides predictable state transitions and makes the business logic easy to test independently from widgets.
- The application follows a feature-based repository architecture. Repository interfaces are defined in the domain layer, while implementations and remote/local data sources are placed in the data layer.


**Architecture Overview:**
- Repository layer: Repository interfaces are defined in the domain layer. Implementations coordinate DummyJSON API access through remote data sources and local JWT persistence through flutter_secure_storage.
- State management layer: flutter_bloc is used for authentication and posts state. Events represent user/application actions while states represent loading, success, empty, pagination, authentication, and error conditions.
- Widget layer: Widgets consume Bloc state using BlocBuilder, BlocListener, and/or BlocConsumer. Business logic and direct API calls are kept outside widgets.

---

## 🔐 Authentication Implementation
- The application authenticates against the DummyJSON /auth/login endpoint.
- The returned access token is stored using flutter_secure_storage. I selected secure storage because the JWT is authentication-sensitive data and should not be stored as normal application preferences.
- On application startup, the stored access token is checked and the session is restored using the authenticated /auth/me endpoint.
- Logout removes the locally persisted access token.
- Invalid credentials, network failures, server failures, and malformed responses are converted into typed failures before being presented to the UI.

**Credentials used for testing:**
- Username: `emilys`, Password: `emilyspass`

---

## 💾 Data & State Management
- Authentication tokens are persisted locally using flutter_secure_storage.
- Posts are fetched fresh from DummyJSON and are not cached locally because offline-first functionality is outside the assessment scope.
- Pagination uses the API total, skip, and limit values to determine whether more posts are available.
- Starting a new search resets the current pagination state and performs backend search using the DummyJSON search endpoint.
- Search results support pagination independently from the normal posts list.
- Search input is debounced using the SEARCH_DEBOUNCE_MS value from the active environment configuration.
- Pull-to-refresh resets the relevant pagination state and reloads fresh data from the backend.
- Empty search results are treated as a valid empty state rather than an error.

---

## 🎨 Design Implementation
- The implementation follows the supplied Figma design as closely as possible within the one-day timebox, focusing on layout, spacing, typography, colors, form fields, post cards, and overall screen structure.
- Reusable widgets were extracted for repeated UI components such as post cards, text fields, and state-specific content where appropriate.
- Loading, empty, and error states are handled explicitly instead of displaying only the successful data state.
- Architecture, functionality, testing, and error handling were prioritized over sub-pixel visual adjustments.

---

## 🔌 API Integration & Networking
- Networking is implemented using dio.
- A shared Dio client is configured with the environment-specific base URL, connection timeout, receive timeout, send timeout, and JSON headers.
- Dio is injected rather than created inside individual data sources, which makes the HTTP layer replaceable/mockable during testing.
- A request interceptor retrieves the locally stored access token and attaches the Authorization: Bearer <accessToken> header when a token is available.
- Dio/network exceptions are mapped into typed application failures before they reach the presentation layer.
- Pagination requests use limit and skip query parameters.
- Search requests use the DummyJSON /posts/search endpoint with q, limit, and skip query parameters.

---

## ⚙️ Build Configuration
- Dev, Staging, and Production configurations are implemented using --dart-define.
- The application reads configuration values through an AppConfig class using String.fromEnvironment and int.fromEnvironment.
- The following values differ between environments:

**Dev**

API_BASE_URL=https://dummyjson.com
PAGINATION_LIMIT=10
SEARCH_DEBOUNCE_MS=300

**Staging**

API_BASE_URL=https://dummyjson.com
PAGINATION_LIMIT=15
SEARCH_DEBOUNCE_MS=500

**Production**

API_BASE_URL=https://dummyjson.com
PAGINATION_LIMIT=20
SEARCH_DEBOUNCE_MS=800

---

## 🧪 Unit Testing Coverage
- Networking is implemented using dio.
- A shared Dio client is configured with the environment-specific base URL, connection timeout, receive timeout, send timeout, and JSON headers.
- Dio is injected rather than created inside individual data sources, which makes the HTTP layer replaceable/mockable during testing.
- Dio/network exceptions are mapped into typed application failures before they reach the presentation layer.
- Search requests use the DummyJSON /posts/search endpoint with q, limit, and skip query parameters.

**Testing checklist:**
- ✅ Auth logic (login success/failure, token persistence, logout, session restore)
- ✅ Repository layer (API calls, model mapping, error mapping)
- ✅ Bloc/ChangeNotifier (state transitions, search debounce, pagination)
- [-] Data model (de)serialization

**Coverage report:** 
- Coverage 92.8% achieved.
- Unit tests focus on business logic including authentication, repositories, Bloc behavior, models, pagination, search, and error handling.
- Widget, golden, and integration tests were intentionally not prioritized because the assessment specifically focuses on unit testing of business logic.
- mocktail is used to mock dependencies so tests do not call the live DummyJSON API.
- bloc_test is used to verify Bloc state transitions.
---

## 🎥 Demo Video
https://drive.google.com/file/d/1064fDomYc3D2Cr0B9WMQr0KlceFNP4-J/view?usp=sharing

---

## 📌 Known Limitations / Assumptions
- Registration is intentionally not implemented because it is outside the required assessment scope.
- Logout function not implemented in the UI.
- Refresh-token handling is not implemented.
- Biometric authentication is not implemented.
- Offline-first/background synchronization is not implemented.
- Push notifications are not implemented.
- Tablet/landscape-specific layouts are not implemented.
- CI/CD pipelines are not included.
- The application currently uses DummyJSON as the backend for all environments as specified in the assessment.

---

## 🛠️ Setup Instructions

**Prerequisites:**
- Flutter 3.19+ / Dart 3+

**Run:**
```bash
flutter pub get 
flutter run --dart-define=API_BASE_URL=https://dummyjson.com --dart-define=PAGINATION_LIMIT=10 --dart-define=SEARCH_DEBOUNCE_MS=300
```

**Test:**
```bash
flutter test --coverage
```

---

## ✅ Feature Completion Checklist

### 🔐 Authentication
- ✅ Login screen against DummyJSON
- ✅ Token storage and persistent session
- [-] Logout
- ✅ Validation and error handling

### 📱 Dashboard & Posts
- ✅ Posts list matching Figma design
- ✅ Backend search with debounce
- ✅ Pagination
- ✅ Pull-to-refresh
- ✅ Post detail screen
- ✅ Loading/empty/error states

### 🏗️ Architecture & Data
- ✅ Repository pattern implemented
- ✅ Bloc used
- ✅ Async/await networking
- ✅ Proper separation of concerns

### ⚙️ Configuration & Testing
- ✅ Three environment configs (Dev/Staging/Production)
- ✅ Unit tests with 70%+ coverage on business logic
- ✅ Edge cases and error scenarios tested

### 📋 Documentation & Quality
- ✅ Clean, readable code
- ✅ README with setup instructions
- ✅ Demo video included
