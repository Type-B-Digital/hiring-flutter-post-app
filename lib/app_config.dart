import 'dart:io';

class AppConfig {
  static const String flavor =
      String.fromEnvironment('FLAVOR', defaultValue: 'DEVELOPMENT');
  static const bool isProduction = flavor == 'PRODUCTION';
  static const bool isStaging = flavor == 'STAGING';

  static String get devHost =>
      Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';
  
  
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://dummyjson.com',
  );

  // used only when PAGINATION_LIMIT / SEARCH_DEBOUNCE_MS not provided via --dart-define, so these defaults are flavor-specific.
  static const int _defaultPaginationLimit = isProduction
      ? 20
      : isStaging
          ? 15
          : 10;
  static const int _defaultSearchDebounceMs = isProduction
      ? 800
      : isStaging
          ? 500
          : 300;

  static const int paginationLimit = int.fromEnvironment(
    'PAGINATION_LIMIT',
    defaultValue: _defaultPaginationLimit,
  );

  static const int searchDebounceMs = int.fromEnvironment(
    'SEARCH_DEBOUNCE_MS',
    defaultValue: _defaultSearchDebounceMs,
  );
}
