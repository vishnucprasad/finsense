import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:finsense/core/database/app_database.dart';
import 'package:finsense/features/transactions/models/transaction_model.dart';
import 'package:finsense/features/accounts/view_models/account_provider.dart';

part 'transaction_provider.g.dart';

@riverpod
class TransactionNotifier extends _$TransactionNotifier {
  static const _tableName = 'transactions';

  @override
  FutureOr<List<TransactionModel>> build() async {
    return _loadTransactions();
  }

  Future<List<TransactionModel>> _loadTransactions() async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(_tableName);
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final db = await AppDatabase.instance.database;
    await db.insert(_tableName, transaction.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

    final currentList = state.valueOrNull ?? [];
    final newList = [...currentList, transaction];
    state = AsyncValue.data(newList);
    
    if (transaction.accountId.isNotEmpty) {
      final delta = transaction.type == 'Expense' ? -transaction.amount : transaction.amount;
      await ref.read(accountNotifierProvider.notifier).updateBalance(transaction.accountId, delta);
    }
  }

  Future<void> editTransaction(TransactionModel newTx, TransactionModel oldTx) async {
    final db = await AppDatabase.instance.database;
    await db.update(_tableName, newTx.toMap(), where: 'id = ?', whereArgs: [newTx.id]);

    final currentList = state.valueOrNull ?? [];
    final newList = currentList.map((t) => t.id == newTx.id ? newTx : t).toList();
    state = AsyncValue.data(newList);

    if (oldTx.accountId.isNotEmpty) {
      final revertDelta = oldTx.type == 'Expense' ? oldTx.amount : -oldTx.amount;
      await ref.read(accountNotifierProvider.notifier).updateBalance(oldTx.accountId, revertDelta);
    }
    
    if (newTx.accountId.isNotEmpty) {
      final applyDelta = newTx.type == 'Expense' ? -newTx.amount : newTx.amount;
      await ref.read(accountNotifierProvider.notifier).updateBalance(newTx.accountId, applyDelta);
    }
  }

  Future<void> deleteTransaction(TransactionModel transaction) async {
    final db = await AppDatabase.instance.database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [transaction.id]);

    final currentList = state.valueOrNull ?? [];
    final newList = currentList.where((t) => t.id != transaction.id).toList();
    state = AsyncValue.data(newList);
    
    if (transaction.accountId.isNotEmpty) {
      final revertDelta = transaction.type == 'Expense' ? transaction.amount : -transaction.amount;
      await ref.read(accountNotifierProvider.notifier).updateBalance(transaction.accountId, revertDelta);
    }
  }

  Future<void> clearCategoryFromTransactions(String deletedCategoryId, String defaultCategoryId) async {
    final db = await AppDatabase.instance.database;
    await db.update(
      _tableName, 
      {'categoryId': defaultCategoryId}, 
      where: 'categoryId = ?', 
      whereArgs: [deletedCategoryId]
    );

    final currentList = state.valueOrNull ?? [];
    bool changed = false;
    final newList = currentList.map((t) {
      if (t.categoryId == deletedCategoryId) {
        changed = true;
        return t.copyWith(categoryId: defaultCategoryId);
      }
      return t;
    }).toList();

    if (changed) {
      state = AsyncValue.data(newList);
    }
  }

  Future<void> clearAccountTransactions(String accountId) async {
    final db = await AppDatabase.instance.database;
    await db.delete(_tableName, where: 'accountId = ?', whereArgs: [accountId]);

    final currentList = state.valueOrNull ?? [];
    final newList = currentList.where((t) => t.accountId != accountId).toList();
    if (newList.length != currentList.length) {
      state = AsyncValue.data(newList);
    }
  }
}
