import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finsense/services/ai/gemini_service.dart';
import 'package:finsense/features/transactions/view_models/transaction_provider.dart';
import 'package:finsense/features/accounts/view_models/account_provider.dart';
import 'package:finsense/features/categories/view_models/category_provider.dart';

part 'dashboard_provider.g.dart';

String? _cachedInsight;
bool _hasRequestedInitial = false;

@riverpod
class FinancialTip extends _$FinancialTip {
  @override
  FutureOr<String?> build() async {
    if (_cachedInsight != null) return _cachedInsight;
    if (!_hasRequestedInitial) {
      _hasRequestedInitial = true;
      Future.microtask(() => loadTip());
    }
    return null;
  }

  Future<void> loadTip() async {
    state = const AsyncValue.loading();
    try {
      final gemini = await ref.read(geminiServiceProvider.future);
      if (gemini == null) {
        state = const AsyncValue.data(
          "Please set your Gemini API Key in Settings.",
        );
        return;
      }

      final transactions = await ref.read(transactionNotifierProvider.future);
      final accounts = await ref.read(accountNotifierProvider.future);
      final categories = await ref.read(categoryNotifierProvider.future);

      final buffer = StringBuffer();
      buffer.writeln("--- ACCOUNT BALANCES ---");
      double netWorth = 0.0;
      for (var a in accounts) {
        netWorth += a.balance;
        buffer.writeln(
          "${a.name} (${a.type}): ₹${a.balance.toStringAsFixed(2)}",
        );
      }
      buffer.writeln("Total Net Worth: ₹${netWorth.toStringAsFixed(2)}\n");

      if (transactions.isNotEmpty) {
        buffer.writeln("--- RECENT TRANSACTIONS ---");
        for (var t in transactions.take(20)) {
          final catName = categories
              .firstWhere(
                (c) => c.id == t.categoryId,
                orElse: () => categories.first,
              )
              .name;
          buffer.writeln(
            "- $catName [${t.type}]: ₹${t.amount.toStringAsFixed(2)} (${t.note})",
          );
        }
      } else {
        buffer.writeln("No recent transactions yet.");
      }

      final tip = await gemini.generateTip(buffer.toString());
      _cachedInsight = tip;
      state = AsyncValue.data(tip);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
