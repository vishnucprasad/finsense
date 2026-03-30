import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:finsense/core/database/app_database.dart';
import 'package:finsense/features/categories/models/category_model.dart';
import 'package:finsense/features/transactions/view_models/transaction_provider.dart';

part 'category_provider.g.dart';

@riverpod
class CategoryNotifier extends _$CategoryNotifier {
  static const _tableName = 'categories';

  @override
  FutureOr<List<CategoryModel>> build() async {
    return _loadCategories();
  }

  Future<List<CategoryModel>> _loadCategories() async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(_tableName);

    if (maps.isEmpty) {
      final defaultList = _getDefaultCategories();
      final batch = db.batch();
      for (final cat in defaultList) {
        batch.insert(
          _tableName,
          cat.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
      return defaultList;
    }

    return maps.map((map) => CategoryModel.fromMap(map)).toList();
  }

  List<CategoryModel> _getDefaultCategories() {
    return [
      CategoryModel(
        id: 'c1',
        name: 'Salary',
        type: 'Income',
        iconName: 'currency_rupee',
        colorHex: 'ff10b981',
      ), // Emerald
      CategoryModel(
        id: 'c2',
        name: 'Investment',
        type: 'Income',
        iconName: 'trending_up',
        colorHex: 'ff3b82f6',
      ), // Blue
      CategoryModel(
        id: 'c3',
        name: 'Food',
        type: 'Expense',
        iconName: 'restaurant',
        colorHex: 'fff43f5e',
      ), // Rose
      CategoryModel(
        id: 'c4',
        name: 'Rent',
        type: 'Expense',
        iconName: 'home',
        colorHex: 'ff8b5cf6',
      ), // Purple
      CategoryModel(
        id: 'c5',
        name: 'Transport',
        type: 'Expense',
        iconName: 'directions_car',
        colorHex: 'fff59e0b',
      ), // Amber
      CategoryModel(
        id: 'c6',
        name: 'Entertainment',
        type: 'Expense',
        iconName: 'movie',
        colorHex: 'ffec4899',
      ), // Pink
    ];
  }

  Future<void> addCategory(CategoryModel category) async {
    final db = await AppDatabase.instance.database;
    await db.insert(
      _tableName,
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    final currentList = state.valueOrNull ?? [];
    final newList = [...currentList, category];
    state = AsyncValue.data(newList);
  }

  Future<void> updateCategory(CategoryModel updatedCategory) async {
    final db = await AppDatabase.instance.database;
    await db.update(
      _tableName,
      updatedCategory.toMap(),
      where: 'id = ?',
      whereArgs: [updatedCategory.id],
    );

    final currentList = state.valueOrNull ?? [];
    final newList = currentList
        .map((c) => c.id == updatedCategory.id ? updatedCategory : c)
        .toList();
    state = AsyncValue.data(newList);
  }

  Future<void> deleteCategory(String id) async {
    final currentList = state.valueOrNull ?? [];
    final categoryToDelete = currentList.firstWhere(
      (c) => c.id == id,
      orElse: () =>
          CategoryModel(id: '', name: '', type: '', iconName: '', colorHex: ''),
    );
    if (categoryToDelete.id.isEmpty) return;

    final db = await AppDatabase.instance.database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);

    final newList = currentList.where((c) => c.id != id).toList();
    state = AsyncValue.data(newList);

    final fallbackCat = newList.firstWhere(
      (c) => c.type == categoryToDelete.type,
      orElse: () => newList.first,
    );
    await ref
        .read(transactionNotifierProvider.notifier)
        .clearCategoryFromTransactions(id, fallbackCat.id);
  }
}
