import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/file_image_widget.dart';
import '../../data/models/recipe.dart';
import '../providers/recipe_provider.dart';
import 'edit_recipe_screen.dart';

class DetailScreen extends StatelessWidget {
  final Recipe recipe;
  const DetailScreen({super.key, required this.recipe});

  static const Color _primary = Color(0xFFE8824A);
  static const Color _bg = Color(0xFFFFF5EE);

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<RecipeProvider>();
    final currentRecipe = prov.allRecipes.firstWhere((r) => r.id == recipe.id, orElse: () => recipe);

    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, currentRecipe),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleSection(currentRecipe),
                  const SizedBox(height: 20),
                  _buildStatsRow(currentRecipe),
                  const SizedBox(height: 24),
                  _buildIngredientsSection(currentRecipe),
                  const SizedBox(height: 24),
                  _buildInstructionsSection(currentRecipe),
                  const SizedBox(height: 32),
                  _buildActionButtons(context, currentRecipe),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Recipe currentRecipe) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: _bg,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle),
          child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF2D2D2D)),
        ),
      ),
      actions: [
        Consumer<RecipeProvider>(
          builder: (ctx, prov, _) => GestureDetector(
            onTap: () => prov.toggleSaved(currentRecipe),
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle),
              child: Icon(
                prov.isSaved(currentRecipe.id) ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                color: prov.isSaved(currentRecipe.id) ? _primary : const Color(0xFF2D2D2D),
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: currentRecipe.image.isNotEmpty
            ? _buildImageDisplay(currentRecipe.image, fit: BoxFit.cover)
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: const Color(0xFFFFF0E6),
        child: const Center(child: Icon(Icons.restaurant_rounded, size: 80, color: _primary)),
      );

  Widget _buildImageDisplay(String image, {BoxFit fit = BoxFit.cover}) {
    if (image.trim().isEmpty) return _placeholder();
    if (image.startsWith('http')) {
      return Image.network(image, fit: fit, errorBuilder: (_, __, ___) => _placeholder());
    }
    if (image.startsWith('data:')) {
      try {
        final bytes = base64Decode(image.split(',').last);
        return Image.memory(bytes, fit: fit, errorBuilder: (_, __, ___) => _placeholder());
      } catch (_) {
        return _placeholder();
      }
    }
    if (kIsWeb) {
      return _placeholder();
    }
    return fileImageWidget(image, fit: fit, errorWidget: _placeholder());
  }

  Widget _buildTitleSection(Recipe currentRecipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          if (currentRecipe.mealType.isNotEmpty) _Tag(currentRecipe.mealType.first, _primary),
          const SizedBox(width: 8),
          _Tag(currentRecipe.difficulty,
              currentRecipe.difficulty == 'Easy' ? Colors.green : currentRecipe.difficulty == 'Medium' ? Colors.orange : Colors.red),
        ]),
        const SizedBox(height: 10),
        Text(currentRecipe.name,
            style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w800, color: const Color(0xFF2D2D2D), height: 1.2)),
        if (currentRecipe.cuisine.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(currentRecipe.cuisine, style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF888888))),
        ],
        const SizedBox(height: 10),
        Row(children: [
          Icon(Icons.star_rounded, color: Colors.amber[600], size: 18),
          const SizedBox(width: 4),
          Text(currentRecipe.rating.toStringAsFixed(1),
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF2D2D2D))),
          Text(' (${currentRecipe.reviewCount} reviews)',
              style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF888888))),
        ]),
      ],
    );
  }

  Widget _buildStatsRow(Recipe currentRecipe) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat(Icons.timer_outlined, '${currentRecipe.prepTimeMinutes}m', 'Prep'),
          _VSep(),
          _Stat(Icons.local_fire_department_outlined, '${currentRecipe.cookTimeMinutes}m', 'Cook'),
          _VSep(),
          _Stat(Icons.people_outline_rounded, '${currentRecipe.servings}', 'Servings'),
          _VSep(),
          _Stat(Icons.bolt_outlined, '${currentRecipe.caloriesPerServing.toInt()}', 'Kcal'),
        ],
      ),
    );
  }

  Widget _buildIngredientsSection(Recipe currentRecipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ingredients',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF2D2D2D))),
        const SizedBox(height: 12),
        ...currentRecipe.ingredients.map((ing) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: _primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.fiber_manual_record_rounded, color: _primary, size: 10),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(ing, style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF2D2D2D)))),
              ]),
            )),
      ],
    );
  }

  Widget _buildInstructionsSection(Recipe currentRecipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Instructions',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF2D2D2D))),
        const SizedBox(height: 12),
        ...currentRecipe.instructions.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: Text('${e.key + 1}',
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(e.value,
                        style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF555555), height: 1.5)),
                  ),
                ),
              ]),
            )),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, Recipe currentRecipe) {
    return Consumer<RecipeProvider>(
      builder: (ctx, prov, _) => Row(children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => EditRecipeScreen(recipe: currentRecipe))),
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: const Text('Edit'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _primary,
              side: const BorderSide(color: _primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: prov.isDeleting ? null : () => _confirmDelete(ctx, prov, currentRecipe),
            icon: prov.isDeleting
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.delete_outline_rounded, size: 18),
            label: Text(prov.isDeleting ? 'Deleting...' : 'Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ]),
    );
  }

  Future<void> _confirmDelete(BuildContext context, RecipeProvider prov, Recipe currentRecipe) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Recipe?', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text('This recipe will be permanently removed.', style: GoogleFonts.poppins(fontSize: 13)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: GoogleFonts.poppins(color: const Color(0xFF888888)))),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text('Delete', style: GoogleFonts.poppins())),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      final done = await prov.deleteRecipe(currentRecipe.id);
      if (done && context.mounted) Navigator.pop(context);
    }
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
        child: Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      );
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _Stat(this.icon, this.value, this.label);
  static const Color _primary = Color(0xFFE8824A);
  @override
  Widget build(BuildContext context) => Column(children: [
        Icon(icon, color: _primary, size: 22),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14, color: const Color(0xFF2D2D2D))),
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF888888))),
      ]);
}

class _VSep extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 40, color: const Color(0xFFF0F0F0));
}

