import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/transaction_model.dart';
import '../../accounts/application/account_provider.dart';

part 'transaction_provider.g.dart';

@riverpod
class TransactionNotifier extends _$TransactionNotifier {
  static const _prefsKey = 'transactions_key';

  @override
  FutureOr<List<TransactionModel>> build() async {
    return _loadTransactions();
  }

  Future<List<TransactionModel>> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStringList = prefs.getStringList(_prefsKey) ?? [];
    return jsonStringList.map((str) => TransactionModel.fromJson(str)).toList();
  }

  Future<void> _saveTransactions(List<TransactionModel> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStringList = transactions.map((t) => t.toJson()).toList();
    await prefs.setStringList(_prefsKey, jsonStringList);
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final currentList = state.valueOrNull ?? [];
    final newList = [...currentList, transaction];
    state = AsyncValue.data(newList);
    await _saveTransactions(newList);
    
    if (transaction.accountId.isNotEmpty) {
      final delta = transaction.type == 'Expense' ? -transaction.amount : transaction.amount;
      await ref.read(accountNotifierProvider.notifier).updateBalance(transaction.accountId, delta);
    }
  }

  Future<void> editTransaction(TransactionModel newTx, TransactionModel oldTx) async {
    final currentList = state.valueOrNull ?? [];
    final newList = currentList.map((t) => t.id == newTx.id ? newTx : t).toList();
    state = AsyncValue.data(newList);
    await _saveTransactions(newList);

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
    final currentList = state.valueOrNull ?? [];
    final newList = currentList.where((t) => t.id != transaction.id).toList();
    state = AsyncValue.data(newList);
    await _saveTransactions(newList);
    
    if (transaction.accountId.isNotEmpty) {
      final revertDelta = transaction.type == 'Expense' ? transaction.amount : -transaction.amount;
      await ref.read(accountNotifierProvider.notifier).updateBalance(transaction.accountId, revertDelta);
    }
  }

  Future<void> clearCategoryFromTransactions(String deletedCategoryId, String defaultCategoryId) async {
    final currentList = state.valueOrNull ?? [];
    bool changed = false;
    final newList = currentList.map((t) {
      if (t.categoryId == deletedCategoryId) {
        changed = true;
        return TransactionModel(
          id: t.id,
          accountId: t.accountId,
          categoryId: defaultCategoryId,
          amount: t.amount,
          date: t.date,
          note: t.note,
          type: t.type,
        );
      }
      return t;
    }).toList();

    if (changed) {
      state = AsyncValue.data(newList);
      await _saveTransactions(newList);
    }
  }

  Future<void> clearAccountTransactions(String accountId) async {
    final currentList = state.valueOrNull ?? [];
    final newList = currentList.where((t) => t.accountId != accountId).toList();
    if (newList.length != currentList.length) {
      state = AsyncValue.data(newList);
      await _saveTransactions(newList);
    }
  }
}
