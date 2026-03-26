import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/category_model.dart';
import '../../dashboard/application/transaction_provider.dart';

part 'category_provider.g.dart';

@riverpod
class CategoryNotifier extends _$CategoryNotifier {
  static const _prefsKey = 'categories_key';

  @override
  FutureOr<List<CategoryModel>> build() async {
    return _loadCategories();
  }

  Future<List<CategoryModel>> _loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStringList = prefs.getStringList(_prefsKey);
    
    if (jsonStringList == null || jsonStringList.isEmpty) {
      final defaults = _getDefaultCategories();
      await _saveCategories(defaults);
      return defaults;
    }
    
    return jsonStringList.map((str) => CategoryModel.fromJson(str)).toList();
  }

  List<CategoryModel> _getDefaultCategories() {
    return [
      CategoryModel(id: 'c1', name: 'Salary', type: 'Income', iconName: 'currency_rupee', colorHex: 'ff10b981'), // Emerald
      CategoryModel(id: 'c2', name: 'Investment', type: 'Income', iconName: 'trending_up', colorHex: 'ff3b82f6'), // Blue
      CategoryModel(id: 'c3', name: 'Food', type: 'Expense', iconName: 'restaurant', colorHex: 'fff43f5e'), // Rose
      CategoryModel(id: 'c4', name: 'Rent', type: 'Expense', iconName: 'home', colorHex: 'ff8b5cf6'), // Purple
      CategoryModel(id: 'c5', name: 'Transport', type: 'Expense', iconName: 'directions_car', colorHex: 'fff59e0b'), // Amber
      CategoryModel(id: 'c6', name: 'Entertainment', type: 'Expense', iconName: 'movie', colorHex: 'ffec4899'), // Pink
    ];
  }

  Future<void> _saveCategories(List<CategoryModel> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStringList = categories.map((c) => c.toJson()).toList();
    await prefs.setStringList(_prefsKey, jsonStringList);
  }

  Future<void> addCategory(CategoryModel category) async {
    final currentList = state.valueOrNull ?? [];
    final newList = [...currentList, category];
    state = AsyncValue.data(newList);
    await _saveCategories(newList);
  }

  Future<void> editCategory(CategoryModel category) async {
    final currentList = state.valueOrNull ?? [];
    final newList = currentList.map((c) => c.id == category.id ? category : c).toList();
    state = AsyncValue.data(newList);
    await _saveCategories(newList);
  }

  Future<void> deleteCategory(String id) async {
    final currentList = state.valueOrNull ?? [];
    if (currentList.length <= 1) return;
    
    final categoryToDelete = currentList.firstWhere((c) => c.id == id, orElse: () => currentList.first);
    final fallbackCategory = currentList.firstWhere((c) => c.id != id && c.type == categoryToDelete.type, orElse: () => currentList.firstWhere((c) => c.id != id));

    final newList = currentList.where((c) => c.id != id).toList();
    state = AsyncValue.data(newList);
    await _saveCategories(newList);
    
    await ref.read(transactionNotifierProvider.notifier).clearCategoryFromTransactions(id, fallbackCategory.id);
  }
}
