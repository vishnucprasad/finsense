import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../categories/application/category_provider.dart';
import 'widgets/ai_pulse_tip_box.dart';
import '../../../../core/theme/app_theme.dart';
import '../application/transaction_provider.dart';
import 'widgets/global_drawer.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionNotifierProvider);
    final categoriesAsync = ref.watch(categoryNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: const GlobalDrawer(),
      floatingActionButton: FloatingActionButton(
        heroTag: 'dashboard_add_fab',
        onPressed: () => context.push('/transaction-entry'),
        backgroundColor: AppTheme.emerald,
        child: const Icon(Icons.add, color: AppTheme.deepNavy),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const AIPulseTipBox(),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => context.push('/home/monthly-breakdown'),
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.pie_chart, size: 48, color: AppTheme.cyan),
                    const SizedBox(width: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Monthly Breakdown', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('See spending details', style: TextStyle(color: Colors.white.withOpacity(0.6))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Transactions',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                TextButton(
                  onPressed: () => context.go('/transactions'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerRight,
                  ),
                  child: const Text('Show All', style: TextStyle(color: AppTheme.cyan, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            transactionsAsync.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return const Text('No transactions yet. Tap + to add one.', style: TextStyle(color: Colors.white54));
                }
                final displayed = transactions.reversed.take(5).toList();
                return Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayed.length,
                  itemBuilder: (context, index) {
                    final t = displayed[index];
                    final subtitleText = StringBuffer(DateFormat.MMMd().format(t.date));
                    if (t.note.isNotEmpty) {
                      subtitleText.write(' - ${t.note}');
                    }

                    final categories = categoriesAsync.valueOrNull ?? [];
                    final categoryName = categories.firstWhere((c) => c.id == t.categoryId, orElse: () => categories.first).name;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        child: const Icon(Icons.receipt_long, color: AppTheme.emerald, size: 20),
                      ),
                      title: Text(categoryName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text(subtitleText.toString(), style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                      trailing: Text('₹${t.amount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      onLongPress: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: AppTheme.deepNavy,
                          builder: (context) => SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.edit, color: AppTheme.cyan),
                                  title: const Text('Edit Transaction', style: TextStyle(color: Colors.white)),
                                  onTap: () {
                                    Navigator.pop(context);
                                    context.push('/transaction-entry', extra: t);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.delete, color: Colors.redAccent),
                                  title: const Text('Delete', style: TextStyle(color: Colors.white)),
                                  onTap: () {
                                    ref.read(transactionNotifierProvider.notifier).deleteTransaction(t);
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                ],
              );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.emerald)),
              error: (err, _) => Text('Error loading transactions: $err', style: const TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      ),
    );
  }
}
