import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/file_image_widget.dart';
import '../providers/recipe_provider.dart';
import '../../data/models/recipe.dart';
import 'detail_screen.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  static const Color _primary = Color(0xFFE8824A);
  static const Color _bg = Color(0xFFFFF5EE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Consumer<RecipeProvider>(
          builder: (context, prov, _) {
            final saved = prov.savedRecipes;
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context, saved.length)),
                if (saved.isEmpty)
                  SliverFillRemaining(child: _buildEmpty())
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _SavedCard(recipe: saved[i]),
                        ),
                        childCount: saved.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Saved', style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF888888))),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recipe Book', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF2D2D2D))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: _primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                child: Text('$count saved', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: _primary)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: _primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bookmark_border_rounded, size: 50, color: _primary),
            ),
            const SizedBox(height: 24),
            Text('No saved recipes yet', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF2D2D2D))),
            const SizedBox(height: 10),
            Text(
              'Tap the bookmark icon on any recipe\nto save it here for later.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF888888), height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedCard extends StatelessWidget {
  final Recipe recipe;
  const _SavedCard({required this.recipe});
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
                  ? _recipeImage(recipe.image, width: 90, height: 100, fit: BoxFit.cover)
                  : _imgPlaceholder(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (recipe.mealType.isNotEmpty)
                      Text(recipe.mealType.first,
                          style: GoogleFonts.poppins(fontSize: 10, color: _primary, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(recipe.name,
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF2D2D2D)),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(children: [
                      Icon(Icons.timer_outlined, size: 12, color: Colors.grey[500]),
                      const SizedBox(width: 3),
                      Text('${recipe.totalTimeMinutes} min',
                          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500])),
                      const SizedBox(width: 10),
                      Icon(Icons.star_rounded, size: 12, color: Colors.amber[600]),
                      const SizedBox(width: 3),
                      Text(recipe.rating.toStringAsFixed(1),
                          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500])),
                    ]),
                  ],
                ),
              ),
            ),
            Consumer<RecipeProvider>(
              builder: (_, prov, __) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => prov.toggleSaved(recipe),
                  child: const Icon(Icons.bookmark_rounded, color: _primary, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
        width: 90, height: 100,
        color: const Color(0xFFFFF0E6),
        child: const Icon(Icons.restaurant_rounded, color: _primary, size: 30),
      );

  Widget _recipeImage(String image, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (image.trim().isEmpty) return _imgPlaceholder();
    if (image.startsWith('http')) {
      return Image.network(image, width: width, height: height, fit: fit, errorBuilder: (_, __, ___) => _imgPlaceholder());
    }
    if (image.startsWith('data:')) {
      try {
        final bytes = base64Decode(image.split(',').last);
        return Image.memory(bytes, width: width, height: height, fit: fit, errorBuilder: (_, __, ___) => _imgPlaceholder());
      } catch (_) {
        return _imgPlaceholder();
      }
    }
    if (kIsWeb) {
      return _imgPlaceholder();
    }
    return fileImageWidget(image, width: width, height: height, fit: fit, errorWidget: _imgPlaceholder());
  }
}

