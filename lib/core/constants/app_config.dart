class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://dummyjson.com',
  );

  static const int paginationLimit = int.fromEnvironment(
    'PAGINATION_LIMIT',
    defaultValue: 10,
  );

  static const int searchDebounceMs = int.fromEnvironment(
    'SEARCH_DEBOUNCE_MS',
    defaultValue: 300,
  );
}
