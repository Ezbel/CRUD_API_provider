class ApiConstants {
  // Base URL for the recipe API (JSONPlaceholder-style mock or real backend)
  // Using a public mock REST API for demonstration
  static const String baseUrl = 'https://dummyjson.com';

  // Recipe endpoints
  static const String recipesEndpoint = '/recipes';

  // Full URLs
  static String get recipesUrl => '$baseUrl$recipesEndpoint';
  static String recipeUrl(int id) => '$baseUrl$recipesEndpoint/$id';
  static String addRecipeUrl() => '$baseUrl$recipesEndpoint/add';
  static String updateRecipeUrl(int id) => '$baseUrl$recipesEndpoint/$id';
  static String deleteRecipeUrl(int id) => '$baseUrl$recipesEndpoint/$id';

  // Pagination
  static const int defaultLimit = 20;
  static const int defaultSkip = 0;

  // Timeout durations
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}

