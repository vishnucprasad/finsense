import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../application/category_provider.dart';
import '../../dashboard/presentation/widgets/global_drawer.dart';

class CategoryManagerScreen extends ConsumerWidget {
  const CategoryManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: const GlobalDrawer(),
      body: categoriesAsync.when(
        data: (categories) {
          final incomes = categories.where((c) => c.type == 'Income').toList();
          final expenses = categories.where((c) => c.type == 'Expense').toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('INCOME', style: TextStyle(color: AppTheme.emerald, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 16),
              ...incomes.map((c) => _buildCategoryTile(c, ref)),
              const SizedBox(height: 32),
              const Text('EXPENSE', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 16),
              ...expenses.map((c) => _buildCategoryTile(c, ref)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.emerald)),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.redAccent))),
      ),
    );
  }

  Widget _buildCategoryTile(category, WidgetRef ref) {
    final color = Color(int.parse(category.colorHex, radix: 16));
    
    IconData getIconData(String name) {
      switch (name) {
        case 'currency_rupee': return Icons.currency_rupee;
        case 'trending_up': return Icons.trending_up;
        case 'restaurant': return Icons.restaurant;
        case 'home': return Icons.home;
        case 'directions_car': return Icons.directions_car;
        case 'movie': return Icons.movie;
        default: return Icons.category;
      }
    }

    return Card(
      color: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(getIconData(category.iconName), color: color),
        ),
        title: Text(category.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.white54),
          onPressed: () => ref.read(categoryNotifierProvider.notifier).deleteCategory(category.id),
        ),
      ),
    );
  }
}
