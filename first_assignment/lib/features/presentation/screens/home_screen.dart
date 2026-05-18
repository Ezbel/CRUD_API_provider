import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/file_image_widget.dart';
import '../providers/recipe_provider.dart';
import '../../data/models/recipe.dart';
import 'add_recipe_screen.dart';
import 'detail_screen.dart';
import 'saved_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _searchController = TextEditingController();
  static const Color _primary = Color(0xFFE8824A);
  static const Color _bg = Color(0xFFFFF5EE);

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [_HomePage(searchController: _searchController), const SavedScreen(), const ProfileScreen()];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeProvider>().fetchRecipes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, -4))],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.home_rounded, label: 'Home', selected: _currentIndex == 0, onTap: () => setState(() => _currentIndex = 0)),
                _NavItem(icon: Icons.bookmark_rounded, label: 'Saved', selected: _currentIndex == 1, onTap: () => setState(() => _currentIndex = 1)),
                _NavItem(icon: Icons.person_rounded, label: 'Profile', selected: _currentIndex == 2, onTap: () => setState(() => _currentIndex = 2)),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddRecipeScreen())),
              backgroundColor: _primary,
              elevation: 4,
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            )
          : null,
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});

  static const Color _primary = Color(0xFFE8824A);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _primary.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? _primary : const Color(0xFFBBBBBB), size: 26),
            const SizedBox(height: 2),
            Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: selected ? FontWeight.w600 : FontWeight.w400, color: selected ? _primary : const Color(0xFFBBBBBB))),
          ],
        ),
      ),
    );
  }
}

// ── Inner home page widget ──────────────────────────────────────────────────
class _HomePage extends StatelessWidget {
  const _HomePage({required this.searchController});

  final TextEditingController searchController;
  static const Color _primary = Color(0xFFE8824A);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<RecipeProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            color: _primary,
            onRefresh: provider.fetchRecipes,
            child: CustomScrollView(
              slivers: [
                _buildHeader(context, provider),
                _buildSearchBar(context, provider),
                if (provider.searchQuery.isEmpty) _buildBanner(context, provider),
                if (provider.searchQuery.isEmpty) _buildCategorySection(context, provider),
                if (provider.searchQuery.isEmpty) _buildPopularSection(context, provider),
                _buildAllRecipesSection(context, provider),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, RecipeProvider provider) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hello, Chef! 👋', style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF888888))),
                  Text('What to cook today?', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF2D2D2D))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, RecipeProvider provider) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: TextField(
          controller: searchController,
          onChanged: provider.setSearchQuery,
          decoration: InputDecoration(
            hintText: 'Search recipes...',
            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFBBBBBB)),
            suffixIcon: provider.searchQuery.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      searchController.clear();
                      provider.setSearchQuery('');
                    },
                    child: const Icon(Icons.close_rounded, color: Color(0xFFBBBBBB)),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildBanner(BuildContext context, RecipeProvider provider) {
    if (provider.popularRecipes.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    final featured = provider.popularRecipes.first;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(recipe: featured))),
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(colors: [_primary, _primary.withValues(alpha: 0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: Stack(
              children: [
                if (featured.image.isNotEmpty)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: _recipeImage(featured.image, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                    ),
                  ),
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                      gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent]),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(6)),
                          child: Text('Family Sunday Special 🍽️', style: GoogleFonts.poppins(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(height: 4),
                        Text(featured.name, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text('${featured.mealTypeString} · ${featured.totalTimeMinutes} min', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, RecipeProvider provider) {
    final cats = provider.categories;
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Categories', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF2D2D2D))),
              ],
            ),
          ),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: cats.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final cat = cats[i];
                final selected = provider.selectedCategory == cat;
                final icons = {'All': Icons.grid_view_rounded, 'Breakfast': Icons.free_breakfast_rounded, 'Lunch': Icons.lunch_dining_rounded, 'Dinner': Icons.dinner_dining_rounded, 'Snack': Icons.cookie_rounded, 'Dessert': Icons.cake_rounded};
                final icon = icons[cat] ?? Icons.restaurant_rounded;
                return GestureDetector(
                  onTap: () => provider.setCategory(cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 68,
                    decoration: BoxDecoration(
                      color: selected ? _primary : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, color: selected ? Colors.white : _primary, size: 26),
                        const SizedBox(height: 4),
                        Text(cat, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: selected ? Colors.white : const Color(0xFF555555)), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularSection(BuildContext context, RecipeProvider provider) {
    if (provider.popularRecipes.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Popular Recipes', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF2D2D2D))),
              ],
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: provider.popularRecipes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (_, i) => _PopularCard(recipe: provider.popularRecipes[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllRecipesSection(BuildContext context, RecipeProvider provider) {
    if (provider.status == RecipeStatus.loading && provider.allRecipes.isEmpty) {
      return SliverToBoxAdapter(child: _LoadingShimmer());
    }
    if (provider.status == RecipeStatus.error && provider.allRecipes.isEmpty) {
      return SliverToBoxAdapter(child: _ErrorWidget(message: provider.errorMessage, onRetry: provider.fetchRecipes));
    }
    final recipes = provider.recipes;
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('My Recipes', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF2D2D2D))),
                  Text('${recipes.length} items', style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF888888))),
                ],
              ),
            );
          }
          if (recipes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(children: [
                  Icon(Icons.search_off_rounded, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text('No recipes found', style: GoogleFonts.poppins(color: const Color(0xFF888888))),
                ]),
              ),
            );
          }
          final recipe = recipes[i - 1];
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: _RecipeListCard(recipe: recipe),
          );
        },
        childCount: recipes.isEmpty ? 2 : recipes.length + 1,
      ),
    );
  }
}

// ── Recipe List Card ──────────────────────────────────────────────────────────
class _RecipeListCard extends StatelessWidget {
  final Recipe recipe;
  const _RecipeListCard({required this.recipe});
  static const Color _primary = Color(0xFFE8824A);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(recipe: recipe))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: recipe.image.isNotEmpty
                  ? _recipeImage(recipe.image, width: 90, height: 90, fit: BoxFit.cover)
                  : _placeholderImage(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (recipe.mealType.isNotEmpty)
                      Text(recipe.mealType.join(', '), style: GoogleFonts.poppins(fontSize: 10, color: _primary, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(recipe.name, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF2D2D2D)), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(children: [
                      Icon(Icons.timer_outlined, size: 13, color: Colors.grey[500]),
                      const SizedBox(width: 3),
                      Text('${recipe.totalTimeMinutes} min', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500])),
                      const SizedBox(width: 10),
                      Icon(Icons.star_rounded, size: 13, color: Colors.amber[600]),
                      const SizedBox(width: 3),
                      Text(recipe.rating.toStringAsFixed(1), style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500])),
                    ]),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Consumer<RecipeProvider>(
                builder: (context, prov, _) => GestureDetector(
                  onTap: () => prov.toggleSaved(recipe),
                  child: Icon(
                    prov.isSaved(recipe.id) ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                    color: prov.isSaved(recipe.id) ? _primary : Colors.grey[400],
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage() => Container(
    width: 90, height: 90,
    color: const Color(0xFFFFF0E6),
    child: const Icon(Icons.restaurant_rounded, color: Color(0xFFE8824A), size: 32),
  );
}

Widget _recipeImage(String image, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
  if (image.trim().isEmpty) {
    return Container(
      width: width ?? 90,
      height: height ?? 90,
      color: const Color(0xFFFFF0E6),
      child: const Icon(Icons.restaurant_rounded, color: Color(0xFFE8824A), size: 32),
    );
  }
  if (image.startsWith('http')) {
    return Image.network(image, width: width, height: height, fit: fit, errorBuilder: (_, __, ___) => Container(
      width: width ?? 90,
      height: height ?? 90,
      color: const Color(0xFFFFF0E6),
      child: const Icon(Icons.restaurant_rounded, color: Color(0xFFE8824A), size: 32),
    ));
  }
  if (image.startsWith('data:')) {
    try {
      final bytes = base64Decode(image.split(',').last);
      return Image.memory(bytes, width: width, height: height, fit: fit, errorBuilder: (_, __, ___) => Container(
        width: width ?? 90,
        height: height ?? 90,
        color: const Color(0xFFFFF0E6),
        child: const Icon(Icons.restaurant_rounded, color: Color(0xFFE8824A), size: 32),
      ));
    } catch (_) {
      return Container(
        width: width ?? 90,
        height: height ?? 90,
        color: const Color(0xFFFFF0E6),
        child: const Icon(Icons.restaurant_rounded, color: Color(0xFFE8824A), size: 32),
      );
    }
  }
  if (kIsWeb) {
    return Container(
      width: width ?? 90,
      height: height ?? 90,
      color: const Color(0xFFFFF0E6),
      child: const Icon(Icons.restaurant_rounded, color: Color(0xFFE8824A), size: 32),
    );
  }
  return fileImageWidget(image, width: width, height: height, fit: fit, errorWidget: Container(
    width: width ?? 90,
    height: height ?? 90,
    color: const Color(0xFFFFF0E6),
    child: const Icon(Icons.restaurant_rounded, color: Color(0xFFE8824A), size: 32),
  ));
}

// ── Popular Card ──────────────────────────────────────────────────────────────
class _PopularCard extends StatelessWidget {
  final Recipe recipe;
  const _PopularCard({required this.recipe});
  static const Color _primary = Color(0xFFE8824A);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(recipe: recipe))),
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: recipe.image.isNotEmpty
                  ? _recipeImage(recipe.image, width: 150, height: 110, fit: BoxFit.cover)
                  : Container(height: 110, color: const Color(0xFFFFF0E6), child: const Icon(Icons.restaurant_rounded, color: Color(0xFFE8824A), size: 40)),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe.name, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF2D2D2D)), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.star_rounded, size: 12, color: Colors.amber[600]),
                    const SizedBox(width: 2),
                    Text(recipe.rating.toStringAsFixed(1), style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500])),
                    const Spacer(),
                    Text('${recipe.totalTimeMinutes}m', style: GoogleFonts.poppins(fontSize: 10, color: _primary, fontWeight: FontWeight.w600)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Loading Shimmer ──────────────────────────────────────────────────────────
class _LoadingShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: List.generate(4, (_) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 90,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            Container(width: 90, height: 90, decoration: const BoxDecoration(color: Color(0xFFF0F0F0), borderRadius: BorderRadius.horizontal(left: Radius.circular(16)))),
            const SizedBox(width: 12),
            Expanded(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 12, width: 80, color: const Color(0xFFF0F0F0)),
                const SizedBox(height: 6),
                Container(height: 14, width: 140, color: const Color(0xFFF0F0F0)),
                const SizedBox(height: 6),
                Container(height: 11, width: 100, color: const Color(0xFFF0F0F0)),
              ],
            )),
          ]),
        )),
      ),
    );
  }
}

// ── Error Widget ──────────────────────────────────────────────────────────────
class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorWidget({required this.message, required this.onRetry});
  static const Color _primary = Color(0xFFE8824A);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20)]),
              child: const Icon(Icons.wifi_off_rounded, size: 48, color: Color(0xFFE8824A)),
            ),
            const SizedBox(height: 20),
            Text('Something burned!', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF2D2D2D))),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF888888))),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(backgroundColor: _primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ],
        ),
      ),
    );
  }
}

