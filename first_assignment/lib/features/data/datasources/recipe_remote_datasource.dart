import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import '../../../../core/constants/api_constants.dart';

class RecipeRemoteDatasource {
  final http.Client _client;

  RecipeRemoteDatasource({http.Client? client})
      : _client = client ?? http.Client();

  /// Fetch all recipes from the API
  Future<List<Recipe>> getRecipes({int limit = 20, int skip = 0}) async {
    final uri = Uri.parse(
      '${ApiConstants.recipesUrl}?limit=$limit&skip=$skip',
    );

    final response = await _client
        .get(uri)
        .timeout(ApiConstants.receiveTimeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> recipesJson = data['recipes'] ?? [];
      return recipesJson.map((json) => Recipe.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to load recipes. Status: ${response.statusCode}',
      );
    }
  }

  /// Fetch a single recipe by ID
  Future<Recipe> getRecipeById(int id) async {
    final uri = Uri.parse(ApiConstants.recipeUrl(id));

    final response = await _client
        .get(uri)
        .timeout(ApiConstants.receiveTimeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Recipe.fromJson(data);
    } else {
      throw Exception(
        'Failed to load recipe #$id. Status: ${response.statusCode}',
      );
    }
  }

  /// Add a new recipe
  Future<Recipe> addRecipe(Map<String, dynamic> recipeData) async {
    final uri = Uri.parse(ApiConstants.addRecipeUrl());

    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(recipeData),
        )
        .timeout(ApiConstants.receiveTimeout);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Recipe.fromJson(data);
    } else {
      throw Exception(
        'Failed to create recipe. Status: ${response.statusCode}',
      );
    }
  }

  /// Update an existing recipe
  Future<Recipe> updateRecipe(int id, Map<String, dynamic> recipeData) async {
    final uri = Uri.parse(ApiConstants.updateRecipeUrl(id));

    final response = await _client
        .put(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(recipeData),
        )
        .timeout(ApiConstants.receiveTimeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Recipe.fromJson(data);
    } else {
      throw Exception(
        'Failed to update recipe #$id. Status: ${response.statusCode}',
      );
    }
  }

  /// Delete a recipe by ID
  Future<bool> deleteRecipe(int id) async {
    final uri = Uri.parse(ApiConstants.deleteRecipeUrl(id));

    final response = await _client
        .delete(uri)
        .timeout(ApiConstants.receiveTimeout);

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(
        'Failed to delete recipe #$id. Status: ${response.statusCode}',
      );
    }
  }
}

