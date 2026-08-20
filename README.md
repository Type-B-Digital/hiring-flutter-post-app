# Flutter Posts App Technical Assessment

This is a Flutter application built as a technical assessment.

## Setup Instructions

1. **Platform Setup:** 
   Because this project was scaffolded cleanly, please navigate to the project directory and run `flutter create .` to generate the native platform folders (`android`, `ios`, `web`, etc.).
   ```bash
   cd posts_app
   flutter create .
   ```

2. **Fetch Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the App:**
   The app supports three environments (Dev, Staging, Production). Run the app passing the environment variables via `--dart-define`.
   
   **Dev:**
   ```bash
   flutter run --dart-define=API_BASE_URL=https://dummyjson.com --dart-define=PAGINATION_LIMIT=10 --dart-define=SEARCH_DEBOUNCE_MS=300
   ```

   **Staging:**
   ```bash
   flutter run --dart-define=API_BASE_URL=https://dummyjson.com --dart-define=PAGINATION_LIMIT=15 --dart-define=SEARCH_DEBOUNCE_MS=500
   ```

   **Production:**
   ```bash
   flutter run --dart-define=API_BASE_URL=https://dummyjson.com --dart-define=PAGINATION_LIMIT=20 --dart-define=SEARCH_DEBOUNCE_MS=800
   ```

## Hardcoded Credentials

Use the following credentials to log in:
- **Username:** `emilys`
- **Password:** `emilyspass`

*(Or any other valid DummyJSON users like `michaelw` / `michaelwpass`)*

## Testing
To run the unit tests and generate a coverage report:
```bash
flutter test --coverage
```
