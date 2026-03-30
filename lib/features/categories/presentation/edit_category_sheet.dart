import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/category_model.dart';
import '../application/category_provider.dart';

class EditCategorySheet extends ConsumerStatefulWidget {
  final CategoryModel category;
  
  const EditCategorySheet({super.key, required this.category});

  @override
  ConsumerState<EditCategorySheet> createState() => _EditCategorySheetState();
}

class _EditCategorySheetState extends ConsumerState<EditCategorySheet> {
  late final TextEditingController _nameController;
  late String _selectedType;
  late String _selectedIcon;
  late String _selectedColor;

  final Map<String, IconData> _availableIcons = {
    'currency_rupee': Icons.currency_rupee,
    'trending_up': Icons.trending_up,
    'restaurant': Icons.restaurant,
    'home': Icons.home,
    'directions_car': Icons.directions_car,
    'movie': Icons.movie,
    'shopping_cart': Icons.shopping_cart,
    'medical_services': Icons.medical_services,
    'school': Icons.school,
    'flight': Icons.flight,
    'electrical_services': Icons.electrical_services,
  };

  final Map<String, Color> _availableColors = {
    'ff10b981': AppTheme.emerald,
    'ff3b82f6': Colors.blue,
    'fff43f5e': Colors.redAccent,
    'ff8b5cf6': Colors.purple,
    'fff59e0b': Colors.amber,
    'ffec4899': Colors.pink,
    'ff06b6d4': Colors.cyan,
    'ff14b8a6': Colors.teal,
    'ffeab308': Colors.yellow,
    'fff97316': Colors.orange,
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _selectedType = widget.category.type;
    _selectedIcon = widget.category.iconName;
    _selectedColor = widget.category.colorHex;

    if (!_availableIcons.containsKey(_selectedIcon)) _selectedIcon = 'currency_rupee';
    if (!_availableColors.containsKey(_selectedColor)) _selectedColor = 'ff10b981';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Category name cannot be empty'), backgroundColor: Colors.redAccent));
      return;
    }

    final updatedCategory = CategoryModel(
      id: widget.category.id,
      name: name,
      type: _selectedType,
      iconName: _selectedIcon,
      colorHex: _selectedColor,
    );

    ref.read(categoryNotifierProvider.notifier).updateCategory(updatedCategory);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.deepNavy,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Edit Category', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            Container(
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: ['Expense', 'Income'].map((type) {
                  final isSelected = _selectedType == type;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedType = type),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? (type == 'Income' ? AppTheme.emerald.withOpacity(0.2) : Colors.redAccent.withOpacity(0.2)) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            type,
                            style: TextStyle(
                              color: isSelected ? (type == 'Income' ? AppTheme.emerald : Colors.redAccent) : Colors.white54,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Category Name',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),

            const Text('Icon', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _availableIcons.entries.map((entry) {
                  final isSelected = _selectedIcon == entry.key;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = entry.key),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 60,
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.cyan.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: AppTheme.cyan) : null,
                      ),
                      child: Icon(entry.value, color: isSelected ? AppTheme.cyan : Colors.white54),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            const Text('Color', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _availableColors.entries.map((entry) {
                  final isSelected = _selectedColor == entry.key;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = entry.key),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 48,
                      decoration: BoxDecoration(
                        color: entry.value,
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: Colors.white, width: 3) : Border.all(color: Colors.transparent, width: 3),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.cyan,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _save,
                child: const Text('Update Category', style: TextStyle(color: AppTheme.deepNavy, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
