# Flutter Posts App - Pull Request Template

## 🚀 Description
Briefly describe what you implemented.
> Example:
> - Implemented login against the DummyJSON API with persisted session
> - Built the posts dashboard with debounced search and paginated list
> - Used flutter_bloc + a repository layer for posts and auth

---

## 🏗️ Architecture & Solution Rationale
- Why you picked Bloc or Provider over the other
- How you structured the repository layer (interfaces, remote/local data sources)
- Any tradeoffs you made given the one-day timebox

**Architecture Overview:**
- Repository layer: [API + local storage approach]
- State management layer: [Bloc/Provider — how state/events are organized]
- Widget layer: [how widgets consume state, e.g. BlocBuilder/Consumer usage]

---

## 🔐 Authentication Implementation
- Token storage approach (Hive / secure storage / shared_preferences) and why
- Session persistence across restarts
- Error handling for invalid credentials / network failure

**Credentials used for testing:**
- Username: `emilys`, Password: `emilyspass`
- [any others you used]

---

## 💾 Data & State Management
- What you cache locally vs. always fetch fresh
- How pagination and search interact in your state management layer
- Debounce implementation for search

---

## 🎨 Design Implementation
- How closely you matched the Figma design and where you intentionally cut corners given the timebox
- Any custom widgets you built
- Loading/empty/error state treatment

---

## 🔌 API Integration & Networking
- `dio`/`http` setup, base client configuration
- Error mapping strategy (network error → typed failure → UI message)
- Pagination and search request handling

---

## ⚙️ Build Configuration
- How Dev/Staging/Production are configured (`--dart-define`, flavors, or other)
- What differs between environments in your implementation

---

## 🧪 Unit Testing Coverage
- Coverage % achieved (`flutter test --coverage`)
- What's tested vs. intentionally not tested, and why
- Mocking approach (e.g. mocktail, fakes)

**Testing checklist:**
- [ ] Auth logic (login success/failure, token persistence, logout, session restore)
- [ ] Repository layer (API calls, model mapping, error mapping)
- [ ] Bloc/ChangeNotifier (state transitions, search debounce, pagination)
- [ ] Data model (de)serialization

**Coverage report:** [percentage or link]

---

## 🎥 Demo Video
Link to a short screen recording of the app running (Loom or similar).

---

## 📌 Known Limitations / Assumptions
Anything left out of scope, incomplete, or assumed — including anything you deliberately skipped per the "What's In / Out of Scope" section of the README.

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
- [ ] Login screen against DummyJSON
- [ ] Token storage and persistent session
- [ ] Logout
- [ ] Validation and error handling

### 📱 Dashboard & Posts
- [ ] Posts list matching Figma design
- [ ] Backend search with debounce
- [ ] Pagination
- [ ] Pull-to-refresh
- [ ] Post detail screen
- [ ] Loading/empty/error states

### 🏗️ Architecture & Data
- [ ] Repository pattern implemented
- [ ] Bloc or Provider used consistently
- [ ] Async/await networking
- [ ] Proper separation of concerns

### ⚙️ Configuration & Testing
- [ ] Three environment configs (Dev/Staging/Production)
- [ ] Unit tests with 70%+ coverage on business logic
- [ ] Edge cases and error scenarios tested

### 📋 Documentation & Quality
- [ ] Clean, readable code
- [ ] README with setup instructions
- [ ] Demo video included
