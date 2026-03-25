import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/account_model.dart';

part 'account_provider.g.dart';

@riverpod
class AccountNotifier extends _$AccountNotifier {
  static const _prefsKey = 'accounts_key';

  @override
  FutureOr<List<AccountModel>> build() async {
    return _loadAccounts();
  }

  Future<List<AccountModel>> _loadAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStringList = prefs.getStringList(_prefsKey) ?? [];
    return jsonStringList.map((str) => AccountModel.fromJson(str)).toList();
  }

  Future<void> _saveAccounts(List<AccountModel> accounts) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStringList = accounts.map((a) => a.toJson()).toList();
    await prefs.setStringList(_prefsKey, jsonStringList);
  }

  Future<void> addAccount(AccountModel account) async {
    final currentList = state.valueOrNull ?? [];
    final newList = [...currentList, account];
    state = AsyncValue.data(newList);
    await _saveAccounts(newList);
  }

  Future<void> updateBalance(String accountId, double amountDelta) async {
    final currentList = state.valueOrNull ?? [];
    final newList = currentList.map((a) {
      if (a.id == accountId) {
        return a.copyWith(balance: a.balance + amountDelta);
      }
      return a;
    }).toList();
    state = AsyncValue.data(newList);
    await _saveAccounts(newList);
  }

  Future<void> deleteAccount(String id) async {
    final currentList = state.valueOrNull ?? [];
    final newList = currentList.where((a) => a.id != id).toList();
    state = AsyncValue.data(newList);
    await _saveAccounts(newList);
  }
}
