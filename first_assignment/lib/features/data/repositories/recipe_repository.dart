import '../datasources/recipe_remote_datasource.dart';
import '../models/recipe.dart';

class RecipeRepository {
  final RecipeRemoteDatasource _remoteDatasource;

  RecipeRepository({RecipeRemoteDatasource? remoteDatasource})
      : _remoteDatasource =
            remoteDatasource ?? RecipeRemoteDatasource();

  /// Get all recipes
  Future<List<Recipe>> getRecipes({int limit = 20, int skip = 0}) async {
    try {
      return await _remoteDatasource.getRecipes(limit: limit, skip: skip);
    } catch (e) {
      throw Exception('Repository error fetching recipes: $e');
    }
  }

  /// Get single recipe
  Future<Recipe> getRecipeById(int id) async {
    try {
      return await _remoteDatasource.getRecipeById(id);
    } catch (e) {
      throw Exception('Repository error fetching recipe #$id: $e');
    }
  }

  /// Create recipe
  Future<Recipe> addRecipe(Map<String, dynamic> recipeData) async {
    try {
      return await _remoteDatasource.addRecipe(recipeData);
    } catch (e) {
      throw Exception('Repository error creating recipe: $e');
    }
  }

  /// Update recipe
  Future<Recipe> updateRecipe(int id, Map<String, dynamic> recipeData) async {
    try {
      return await _remoteDatasource.updateRecipe(id, recipeData);
    } catch (e) {
      throw Exception('Repository error updating recipe #$id: $e');
    }
  }

  /// Delete recipe
  Future<bool> deleteRecipe(int id) async {
    try {
      return await _remoteDatasource.deleteRecipe(id);
    } catch (e) {
      throw Exception('Repository error deleting recipe #$id: $e');
    }
  }
}

