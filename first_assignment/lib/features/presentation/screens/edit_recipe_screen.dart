import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/file_image_widget.dart';
import '../../data/models/recipe.dart';
import '../providers/recipe_provider.dart';

class EditRecipeScreen extends StatefulWidget {
  final Recipe recipe;
  const EditRecipeScreen({super.key, required this.recipe});
  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  static const Color _primary = Color(0xFFE8824A);
  static const Color _bg = Color(0xFFFFF5EE);

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _cuisineCtrl;
  late final TextEditingController _prepCtrl;
  late final TextEditingController _cookCtrl;
  late final TextEditingController _servingsCtrl;
  late final TextEditingController _calCtrl;
  late final TextEditingController _imageCtrl;
  final ImagePicker _imagePicker = ImagePicker();

  late String _difficulty;
  late String _mealType;
  final List<TextEditingController> _ingredientControllers = [];
  final List<TextEditingController> _instructionControllers = [];

  final _difficulties = ['Easy', 'Medium', 'Hard'];
  final _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Dessert'];

  @override
  void initState() {
    super.initState();
    final r = widget.recipe;
    _nameCtrl = TextEditingController(text: r.name);
    _cuisineCtrl = TextEditingController(text: r.cuisine);
    _prepCtrl = TextEditingController(text: r.prepTimeMinutes.toString());
    _cookCtrl = TextEditingController(text: r.cookTimeMinutes.toString());
    _servingsCtrl = TextEditingController(text: r.servings.toString());
    _calCtrl = TextEditingController(text: r.caloriesPerServing.toInt().toString());
    _imageCtrl = TextEditingController(text: r.image);
    _difficulty = _difficulties.contains(r.difficulty) ? r.difficulty : 'Easy';
    _mealType = r.mealType.isNotEmpty && _mealTypes.contains(r.mealType.first) ? r.mealType.first : 'Dinner';
    _ingredientControllers.addAll(
      r.ingredients.isNotEmpty
          ? r.ingredients.map((i) => TextEditingController(text: i))
          : [TextEditingController()],
    );
    _instructionControllers.addAll(
      r.instructions.isNotEmpty
          ? r.instructions.map((i) => TextEditingController(text: i))
          : [TextEditingController()],
    );
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _cuisineCtrl, _prepCtrl, _cookCtrl, _servingsCtrl, _calCtrl, _imageCtrl]) {
      c.dispose();
    }
    for (final c in [..._ingredientControllers, ..._instructionControllers]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'name': _nameCtrl.text.trim(),
      'cuisine': _cuisineCtrl.text.trim(),
      'difficulty': _difficulty,
      'mealType': [_mealType],
      'prepTimeMinutes': int.tryParse(_prepCtrl.text) ?? widget.recipe.prepTimeMinutes,
      'cookTimeMinutes': int.tryParse(_cookCtrl.text) ?? widget.recipe.cookTimeMinutes,
      'servings': int.tryParse(_servingsCtrl.text) ?? widget.recipe.servings,
      'caloriesPerServing': double.tryParse(_calCtrl.text) ?? widget.recipe.caloriesPerServing,
      'image': _imageCtrl.text.trim().isNotEmpty ? _imageCtrl.text.trim() : widget.recipe.image,
      'ingredients': _ingredientControllers.map((c) => c.text.trim()).where((i) => i.isNotEmpty).toList(),
      'instructions': _instructionControllers.map((c) => c.text.trim()).where((i) => i.isNotEmpty).toList(),
      'tags': [_mealType],
      'rating': widget.recipe.rating,
      'reviewCount': widget.recipe.reviewCount,
      'userId': widget.recipe.userId,
    };

    final prov = context.read<RecipeProvider>();
    final success = await prov.updateRecipe(widget.recipe.id, data);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recipe updated!', style: GoogleFonts.poppins()), backgroundColor: _primary, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(prov.errorMessage, style: GoogleFonts.poppins()), backgroundColor: Colors.red[400], behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text('Edit Recipe', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 18)),
        backgroundColor: _bg,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            onPressed: () => _confirmDelete(context, context.read<RecipeProvider>()),
          ),
        ],
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildImagePreview(),
            const SizedBox(height: 24),
            _label('Recipe Name'),
            const SizedBox(height: 8),
            _field(_nameCtrl, 'Recipe name', validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 16),
            _label('Cuisine'),
            const SizedBox(height: 8),
            _field(_cuisineCtrl, 'e.g. Italian'),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label('Category'),
                const SizedBox(height: 8),
                _dropdown(_mealType, _mealTypes, (v) => setState(() => _mealType = v!)),
              ])),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label('Difficulty'),
                const SizedBox(height: 8),
                _dropdown(_difficulty, _difficulties, (v) => setState(() => _difficulty = v!)),
              ])),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _numField(_prepCtrl, 'Prep (min)')),
              const SizedBox(width: 12),
              Expanded(child: _numField(_cookCtrl, 'Cook (min)')),
              const SizedBox(width: 12),
              Expanded(child: _numField(_servingsCtrl, 'Servings')),
            ]),
            const SizedBox(height: 16),
            _label('Calories per serving'),
            const SizedBox(height: 8),
            _numField(_calCtrl, 'e.g. 350'),
            const SizedBox(height: 24),
            _label('Ingredients'),
            const SizedBox(height: 8),
            _dynamicList(
              controllers: _ingredientControllers,
              hint: 'e.g. 1 cup flour',
              onAdd: () => setState(() => _ingredientControllers.add(TextEditingController())),
              onRemove: (i) => setState(() => _ingredientControllers.removeAt(i)),
            ),
            const SizedBox(height: 24),
            _label('Instructions'),
            const SizedBox(height: 8),
            _dynamicList(
              controllers: _instructionControllers,
              hint: 'Step description...',
              numbered: true,
              onAdd: () => setState(() => _instructionControllers.add(TextEditingController())),
              onRemove: (i) => setState(() => _instructionControllers.removeAt(i)),
            ),
            const SizedBox(height: 32),
            Consumer<RecipeProvider>(
              builder: (_, prov, __) => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: prov.isUpdating ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: prov.isUpdating
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('Update Recipe', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 1.5),
      ),
      child: Stack(
        children: [
          if (_imageCtrl.text.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _buildImageDisplay(_imageCtrl.text, width: double.infinity, height: 280, fit: BoxFit.contain),
            )
          else
            _imgPlaceholder(),
          Positioned(
            bottom: 10, right: 10,
            child: GestureDetector(
              onTap: () => _showImagePicker(context, _imageCtrl),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(8)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.edit_rounded, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  Text('Change photo', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imgPlaceholder() => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.image_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 6),
          Text('No image', style: GoogleFonts.poppins(color: const Color(0xFF888888), fontSize: 13)),
        ]),
      );

  void _showImageDialog() {
    showDialog(
      context: context,
      builder: (_) {
        final ctrl = TextEditingController(text: _imageCtrl.text);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Image URL', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16)),
          content: TextField(controller: ctrl, decoration: InputDecoration(hintText: 'Paste image URL...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.poppins(color: const Color(0xFF888888)))),
            ElevatedButton(
              onPressed: () { 
                final url = ctrl.text.trim();
                if (url.isNotEmpty) {
                  _imageCtrl.text = url;
                  setState(() {});
                }
                Navigator.pop(context); 
              },
              style: ElevatedButton.styleFrom(backgroundColor: _primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text('Apply', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  void _showImagePicker(BuildContext context, TextEditingController ctrl) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: _bg,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text('Upload Photo', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: _primary),
              title: Text('Choose from Gallery', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(ImageSource.gallery, ctrl);
              },
            ),
            ListTile(
              leading: const Icon(Icons.link_rounded, color: _primary),
              title: Text('Paste Image URL', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                _showImageDialog();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageDisplay(String image, {BoxFit fit = BoxFit.contain, double? width, double? height}) {
    if (image.trim().isEmpty) {
      return const SizedBox.shrink();
    }
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

  Future<void> _pickImage(ImageSource source, TextEditingController ctrl) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source, imageQuality: 85);
      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          final lower = pickedFile.name.toLowerCase();
          final mime = lower.endsWith('.jpg') || lower.endsWith('.jpeg')
              ? 'image/jpeg'
              : lower.endsWith('.gif')
                  ? 'image/gif'
                  : 'image/png';
          ctrl.text = 'data:$mime;base64,${base64Encode(bytes)}';
        } else {
          ctrl.text = pickedFile.path;
        }
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to pick image. Please check permissions and try again.', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Widget _label(String text) => Text(text, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF555555)));

  Widget _field(TextEditingController ctrl, String hint, {String? Function(String?)? validator}) => TextFormField(
        controller: ctrl,
        validator: validator,
        style: GoogleFonts.poppins(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _primary, width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );

  Widget _numField(TextEditingController ctrl, String label) => TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        style: GoogleFonts.poppins(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF888888)),
          filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _primary, width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      );

  Widget _dropdown(String value, List<String> items, ValueChanged<String?> onChanged) => Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE8E8E8))),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
            onChanged: onChanged,
            isExpanded: true,
          ),
        ),
      );

  Widget _dynamicList({
    required List<TextEditingController> controllers,
    required String hint,
    required VoidCallback onAdd,
    required void Function(int) onRemove,
    bool numbered = false,
  }) {
    return Column(
      children: [
        ...controllers.asMap().entries.map((e) => Padding(
              key: ValueKey(e.value),
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                if (numbered)
                  Container(
                    width: 32, height: 32,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(8)),
                    child: Center(child: Text('${e.key + 1}', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12))),
                  ),
                Expanded(
                  child: TextFormField(
                    controller: e.value,
                    style: GoogleFonts.poppins(fontSize: 13),
                    maxLines: numbered ? 2 : 1,
                    decoration: InputDecoration(
                      hintText: hint,
                      filled: true, fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _primary, width: 1.5)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ),
                if (controllers.length > 1)
                  IconButton(icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFFBBBBBB)), onPressed: () => onRemove(e.key)),
              ]),
            )),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add_circle_outline_rounded, size: 18, color: _primary),
          label: Text('Add ${numbered ? 'Step' : 'Ingredient'}', style: GoogleFonts.poppins(color: _primary, fontSize: 13)),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, RecipeProvider prov) async {
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
      final done = await prov.deleteRecipe(widget.recipe.id);
      if (done && context.mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    }
  }
}

