import 'package:flutter/foundation.dart';
import '../../data/models/recipe.dart';
import '../../data/repositories/recipe_repository.dart';

enum RecipeStatus { initial, loading, success, error }

class RecipeProvider extends ChangeNotifier {
  final RecipeRepository _repository;

  RecipeProvider({RecipeRepository? repository})
      : _repository = repository ?? RecipeRepository();

  // --- State ---
  RecipeStatus _status = RecipeStatus.initial;
  List<Recipe> _recipes = [];
  final List<Recipe> _savedRecipes = [];
  String _errorMessage = '';
  String _selectedCategory = 'All';
  String _searchQuery = '';

  // Action-specific loading
  bool _isAdding = false;
  bool _isUpdating = false;
  bool _isDeleting = false;

  // --- Getters ---
  RecipeStatus get status => _status;
  List<Recipe> get recipes => _filteredRecipes;
  List<Recipe> get allRecipes => _recipes;
  List<Recipe> get savedRecipes => _savedRecipes;
  String get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isAdding => _isAdding;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;
  bool get isLoading => _status == RecipeStatus.loading;

  List<String> get categories {
    final cats = <String>{'All'};
    for (final r in _recipes) {
      if (r.mealType.isNotEmpty) {
        cats.add(r.mealType.first);
      }
    }
    return cats.toList();
  }

  List<Recipe> get _filteredRecipes {
    var list = _recipes;

    if (_selectedCategory != 'All') {
      list = list
          .where((r) => r.mealType.isNotEmpty &&
              r.mealType.first.toLowerCase() == _selectedCategory.toLowerCase())
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((r) =>
              r.name.toLowerCase().contains(q) ||
              r.cuisine.toLowerCase().contains(q) ||
              r.tags.any((t) => t.toLowerCase().contains(q)))
          .toList();
    }

    return list;
  }

  // --- Popular recipes (top rated) ---
  List<Recipe> get popularRecipes {
    final sorted = [..._recipes]..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(5).toList();
  }

  // --- Actions ---

  Future<void> fetchRecipes() async {
    _status = RecipeStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final recipes = await _repository.getRecipes(limit: 30);
      _recipes = recipes;
      // Restore saved state
      for (int i = 0; i < _recipes.length; i++) {
        final saved = _savedRecipes.any((s) => s.id == _recipes[i].id);
        if (saved) _recipes[i].isSaved = true;
      }
      _status = RecipeStatus.success;
    } catch (e) {
      _status = RecipeStatus.error;
      _errorMessage = _parseError(e.toString());
    }

    notifyListeners();
  }

  Future<Recipe?> addRecipe(Map<String, dynamic> data) async {
    _isAdding = true;
    notifyListeners();

    try {
      final newRecipe = await _repository.addRecipe(data);
      final recipeToAdd = newRecipe.id != 0
          ? newRecipe.copyWith(isSaved: false)
          : newRecipe.copyWith(id: DateTime.now().millisecondsSinceEpoch, isSaved: false);

      _recipes.insert(0, recipeToAdd);
      _isAdding = false;
      notifyListeners();
      return recipeToAdd;
    } catch (e) {
      _isAdding = false;
      _errorMessage = _parseError(e.toString());
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateRecipe(int id, Map<String, dynamic> data) async {
    _isUpdating = true;
    notifyListeners();

    try {
      final updated = await _repository.updateRecipe(id, data);
      final idx = _recipes.indexWhere((r) => r.id == id);
      if (idx != -1) {
        _recipes[idx] = updated.copyWith(isSaved: _recipes[idx].isSaved);
      }
      // Update in saved too
      final savedIdx = _savedRecipes.indexWhere((r) => r.id == id);
      if (savedIdx != -1) {
        _savedRecipes[savedIdx] = updated.copyWith(isSaved: true);
      }
      _isUpdating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isUpdating = false;
      _errorMessage = _parseError(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteRecipe(int id) async {
    _isDeleting = true;
    notifyListeners();

    try {
      await _repository.deleteRecipe(id);
      _recipes.removeWhere((r) => r.id == id);
      _savedRecipes.removeWhere((r) => r.id == id);
      _isDeleting = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Force local delete even if mock API throws 404 for our local uniqueId
      _recipes.removeWhere((r) => r.id == id);
      _savedRecipes.removeWhere((r) => r.id == id);
      _isDeleting = false;
      _errorMessage = '';
      notifyListeners();
      return true;
    }
  }

  void toggleSaved(Recipe recipe) {
    final idx = _recipes.indexWhere((r) => r.id == recipe.id);
    if (idx != -1) {
      _recipes[idx].isSaved = !_recipes[idx].isSaved;
      if (_recipes[idx].isSaved) {
        if (!_savedRecipes.any((r) => r.id == recipe.id)) {
          _savedRecipes.add(_recipes[idx]);
        }
      } else {
        _savedRecipes.removeWhere((r) => r.id == recipe.id);
      }
      notifyListeners();
    }
  }

  bool isSaved(int recipeId) =>
      _savedRecipes.any((r) => r.id == recipeId);

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  String _parseError(String raw) {
    if (raw.contains('SocketException') ||
        raw.contains('Failed host lookup')) {
      return 'No internet connection. Please check your network and try again.';
    }
    if (raw.contains('TimeoutException')) {
      return 'Connection timed out. Please try again.';
    }
    if (raw.contains('404')) {
      return 'Recipe not found.';
    }
    return 'Something went wrong. Please try again.';
  }
}

