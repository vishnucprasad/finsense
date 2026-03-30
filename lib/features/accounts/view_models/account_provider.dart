import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:finsense/core/database/app_database.dart';
import 'package:finsense/features/accounts/models/account_model.dart';
import 'package:finsense/features/transactions/view_models/transaction_provider.dart';

part 'account_provider.g.dart';

@riverpod
class AccountNotifier extends _$AccountNotifier {
  static const _tableName = 'accounts';

  @override
  FutureOr<List<AccountModel>> build() async {
    return _loadAccounts();
  }

  Future<List<AccountModel>> _loadAccounts() async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(_tableName);
    return maps.map((map) => AccountModel.fromMap(map)).toList();
  }

  Future<void> addAccount(AccountModel account) async {
    final db = await AppDatabase.instance.database;
    await db.insert(
      _tableName,
      account.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    final currentList = state.valueOrNull ?? [];
    state = AsyncValue.data([...currentList, account]);
  }

  Future<void> updateBalance(String id, double delta) async {
    final db = await AppDatabase.instance.database;
    final currentList = state.valueOrNull ?? [];
    final newList = currentList.map((a) {
      if (a.id == id) {
        final updatedAccount = a.copyWith(balance: a.balance + delta);
        db.update(
          _tableName,
          updatedAccount.toMap(),
          where: 'id = ?',
          whereArgs: [id],
        );
        return updatedAccount;
      }
      return a;
    }).toList();

    state = AsyncValue.data(newList);
  }

  Future<void> updateAccount(AccountModel updatedAccount) async {
    final db = await AppDatabase.instance.database;
    await db.update(
      _tableName,
      updatedAccount.toMap(),
      where: 'id = ?',
      whereArgs: [updatedAccount.id],
    );

    final currentList = state.valueOrNull ?? [];
    final newList = currentList
        .map((a) => a.id == updatedAccount.id ? updatedAccount : a)
        .toList();
    state = AsyncValue.data(newList);
  }

  Future<void> deleteAccount(String id) async {
    final db = await AppDatabase.instance.database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);

    final currentList = state.valueOrNull ?? [];
    final newList = currentList.where((a) => a.id != id).toList();
    state = AsyncValue.data(newList);

    // Purge corresponding transactions universally
    await ref
        .read(transactionNotifierProvider.notifier)
        .clearAccountTransactions(id);
  }
}
