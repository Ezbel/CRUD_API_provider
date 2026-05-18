import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/file_image_widget.dart';
import '../providers/recipe_provider.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});
  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  static const Color _primary = Color(0xFFE8824A);
  static const Color _bg = Color(0xFFFFF5EE);

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _cuisineCtrl = TextEditingController();
  final _prepCtrl = TextEditingController(text: '15');
  final _cookCtrl = TextEditingController(text: '30');
  final _servingsCtrl = TextEditingController(text: '4');
  final _calCtrl = TextEditingController(text: '250');
  final _imageCtrl = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  String _difficulty = 'Easy';
  String _mealType = 'Dinner';
  final List<TextEditingController> _ingredientControllers = [TextEditingController()];
  final List<TextEditingController> _instructionControllers = [TextEditingController()];

  final _difficulties = ['Easy', 'Medium', 'Hard'];
  final _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Dessert'];

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
      'prepTimeMinutes': int.tryParse(_prepCtrl.text) ?? 15,
      'cookTimeMinutes': int.tryParse(_cookCtrl.text) ?? 30,
      'servings': int.tryParse(_servingsCtrl.text) ?? 4,
      'caloriesPerServing': double.tryParse(_calCtrl.text) ?? 250,
      'image': _imageCtrl.text.trim(),
      'ingredients': _ingredientControllers.map((c) => c.text.trim()).where((i) => i.isNotEmpty).toList(),
      'instructions': _instructionControllers.map((c) => c.text.trim()).where((i) => i.isNotEmpty).toList(),
      'tags': [_mealType],
      'rating': 0,
      'reviewCount': 0,
      'userId': 1,
    };

    final prov = context.read<RecipeProvider>();
    final result = await prov.addRecipe(data);
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recipe added!', style: GoogleFonts.poppins()), backgroundColor: _primary, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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
        title: Text('Add New Recipe', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 18)),
        backgroundColor: _bg,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildImagePicker(),
            const SizedBox(height: 24),
            _sectionTitle('Recipe Name'),
            const SizedBox(height: 8),
            _buildTextField(_nameCtrl, 'e.g. Creamy Tomato Pasta', validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 16),
            _sectionTitle('Cuisine'),
            const SizedBox(height: 8),
            _buildTextField(_cuisineCtrl, 'e.g. Italian, Mexican...'),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionTitle('Category'),
                const SizedBox(height: 8),
                _buildDropdown(_mealType, _mealTypes, (v) => setState(() => _mealType = v!)),
              ])),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionTitle('Difficulty'),
                const SizedBox(height: 8),
                _buildDropdown(_difficulty, _difficulties, (v) => setState(() => _difficulty = v!)),
              ])),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _buildNumberField(_prepCtrl, 'Prep (min)')),
              const SizedBox(width: 12),
              Expanded(child: _buildNumberField(_cookCtrl, 'Cook (min)')),
              const SizedBox(width: 12),
              Expanded(child: _buildNumberField(_servingsCtrl, 'Servings')),
            ]),
            const SizedBox(height: 16),
            _sectionTitle('Calories per serving'),
            const SizedBox(height: 8),
            _buildNumberField(_calCtrl, 'e.g. 350'),
            const SizedBox(height: 24),
            _sectionTitle('Ingredients'),
            const SizedBox(height: 8),
            _buildDynamicList(
              controllers: _ingredientControllers,
              hint: 'e.g. 1 cup flour',
              onAdd: () => setState(() => _ingredientControllers.add(TextEditingController())),
              onRemove: (i) => setState(() => _ingredientControllers.removeAt(i)),
            ),
            const SizedBox(height: 24),
            _sectionTitle('Instructions'),
            const SizedBox(height: 8),
            _buildDynamicList(
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
                  onPressed: prov.isAdding ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: prov.isAdding
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('Save Recipe', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: () => _showImagePicker(context, _imageCtrl),
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8E8E8), width: 1.5),
        ),
        child: _imageCtrl.text.isNotEmpty
            ? ClipRRect(borderRadius: BorderRadius.circular(14), child: _buildImageDisplay(_imageCtrl.text, fit: BoxFit.contain))
            : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.add_photo_alternate_rounded, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text('Upload Photo', style: GoogleFonts.poppins(color: const Color(0xFF888888), fontSize: 14)),
              ]),
      ),
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
                _showUrlDialog(ctrl);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showUrlDialog(TextEditingController ctrl) {
    showDialog(
      context: context,
      builder: (_) {
        final tempCtrl = TextEditingController(text: ctrl.text);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Image URL', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16)),
          content: TextField(controller: tempCtrl, decoration: InputDecoration(hintText: 'Paste image URL...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.poppins(color: const Color(0xFF888888)))),
            ElevatedButton(
              onPressed: () { 
                final url = tempCtrl.text.trim();
                if (url.isNotEmpty) {
                  ctrl.text = url; 
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

  Widget _buildImageDisplay(String image, {BoxFit fit = BoxFit.contain}) {
    if (image.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    if (image.startsWith('http')) {
      return Image.network(image, width: double.infinity, height: double.infinity, fit: fit, errorBuilder: (_, __, ___) => _imagePlaceholder());
    }
    if (image.startsWith('data:')) {
      try {
        final bytes = base64Decode(image.split(',').last);
        return ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.memory(bytes, width: double.infinity, height: double.infinity, fit: fit, errorBuilder: (_, __, ___) => _imagePlaceholder()));
      } catch (_) {
        return _imagePlaceholder();
      }
    }
    if (kIsWeb) {
      return _imagePlaceholder();
    }
    return ClipRRect(borderRadius: BorderRadius.circular(14), child: fileImageWidget(image, width: double.infinity, height: double.infinity, fit: fit, errorWidget: _imagePlaceholder()));
  }

  Widget _imagePlaceholder() => Container(
        color: const Color(0xFFF9F3EE),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.broken_image_rounded, size: 40, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text('Unable to display image', style: GoogleFonts.poppins(color: const Color(0xFF888888), fontSize: 12)),
          ]),
        ),
      );

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

  Widget _sectionTitle(String text) => Text(text,
      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF555555)));

  Widget _buildTextField(TextEditingController ctrl, String hint, {String? Function(String?)? validator}) =>
      TextFormField(
        controller: ctrl,
        validator: validator,
        style: GoogleFonts.poppins(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _primary, width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );

  Widget _buildNumberField(TextEditingController ctrl, String label) => TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        style: GoogleFonts.poppins(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF888888)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _primary, width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      );

  Widget _buildDropdown(String value, List<String> items, ValueChanged<String?> onChanged) => Container(
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

  Widget _buildDynamicList({
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
                      filled: true,
                      fillColor: Colors.white,
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
}

