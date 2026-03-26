import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../dashboard/application/transaction_provider.dart';
import '../../categories/application/category_provider.dart';
import '../../dashboard/presentation/widgets/global_drawer.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');
final typeFilterProvider = StateProvider<String>((ref) => 'All');

class AllTransactionsScreen extends ConsumerWidget {
  const AllTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionNotifierProvider);
    final categoriesAsync = ref.watch(categoryNotifierProvider);
    final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
    final typeFilter = ref.watch(typeFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: const GlobalDrawer(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'transactions_add_fab',
            onPressed: () => context.push('/transaction-entry'),
            backgroundColor: AppTheme.emerald,
            child: const Icon(Icons.add, color: AppTheme.deepNavy),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'transactions_ai_fab',
            onPressed: () {
              context.push('/transactions/ai-summary');
            },
            icon: const Icon(Icons.auto_awesome, color: AppTheme.deepNavy),
            label: const Text('AI Summary', style: TextStyle(color: AppTheme.deepNavy, fontWeight: FontWeight.bold)),
            backgroundColor: AppTheme.cyan,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by note...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: ['All', 'Income', 'Expense'].map((type) {
                final isSelected = typeFilter == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(type),
                    selected: isSelected,
                    showCheckmark: false,
                    onSelected: (_) => ref.read(typeFilterProvider.notifier).state = type,
                    backgroundColor: Colors.white.withOpacity(0.05),
                    selectedColor: AppTheme.emerald.withOpacity(0.2),
                    labelStyle: TextStyle(color: isSelected ? AppTheme.emerald : Colors.white),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                final filtered = transactions.reversed.where((t) {
                  final matchesType = typeFilter == 'All' || t.type == typeFilter;
                  final matchesQuery = t.note.toLowerCase().contains(searchQuery);
                  return matchesType && matchesQuery;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No transactions found.', style: TextStyle(color: Colors.white54)));
                }

                final Map<String, List<dynamic>> grouped = {};
                for (var t in filtered) {
                  final dateStr = DateFormat.yMMMd().format(t.date);
                  grouped.putIfAbsent(dateStr, () => []).add(t);
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: grouped.length,
                  itemBuilder: (context, index) {
                    final dateKey = grouped.keys.elementAt(index);
                    final dayTransactions = grouped[dateKey]!;
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Text(dateKey, style: const TextStyle(color: AppTheme.cyan, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                        ),
                        ...dayTransactions.map((t) {
                          final categories = categoriesAsync.valueOrNull ?? [];
                          final categoryName = categories.firstWhere((c) => c.id == t.categoryId, orElse: () => categories.first).name;

                          return Dismissible(
                            key: Key(t.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              alignment: Alignment.centerRight,
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            confirmDismiss: (direction) async {
                              return await showDialog<bool>(
                                context: context,
                                builder: (dialogCtx) => AlertDialog(
                                  backgroundColor: AppTheme.deepNavy,
                                  title: const Text('Confirm Deletion', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  content: const Text(
                                    'Are you sure you want to permanently delete this transaction? This will instantly impact your Net Worth and AI Analysis parameters.', 
                                    style: TextStyle(color: Colors.white70, height: 1.4)
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(dialogCtx, false),
                                      child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(dialogCtx, true),
                                      child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (_) {
                              ref.read(transactionNotifierProvider.notifier).deleteTransaction(t);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.02),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withOpacity(0.05)),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.white.withOpacity(0.1),
                                  child: Icon(t.type == 'Income' ? Icons.arrow_downward : Icons.arrow_upward, color: t.type == 'Income' ? AppTheme.emerald : Colors.redAccent, size: 20),
                                ),
                                title: Text(categoryName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                subtitle: t.note.isNotEmpty ? Text(t.note, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)) : null,
                                trailing: Text('₹${t.amount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                onTap: () => context.push('/transaction-entry', extra: t),
                                onLongPress: () {
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: AppTheme.deepNavy,
                                    builder: (ctx) => SafeArea(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading: const Icon(Icons.edit, color: AppTheme.cyan),
                                            title: const Text('Edit Transaction', style: TextStyle(color: Colors.white)),
                                            onTap: () {
                                              Navigator.pop(ctx);
                                              context.push('/transaction-entry', extra: t);
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.delete, color: Colors.redAccent),
                                            title: const Text('Delete', style: TextStyle(color: Colors.white)),
                                            onTap: () {
                                              Navigator.pop(ctx);
                                              showDialog(
                                                context: context,
                                                builder: (dialogCtx) => AlertDialog(
                                                  backgroundColor: AppTheme.deepNavy,
                                                  title: const Text('Confirm Deletion', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                                  content: const Text(
                                                    'Are you sure you want to permanently delete this transaction? This will instantly impact your Net Worth and AI Analysis parameters.', 
                                                    style: TextStyle(color: Colors.white70, height: 1.4)
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(dialogCtx),
                                                      child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        ref.read(transactionNotifierProvider.notifier).deleteTransaction(t);
                                                        Navigator.pop(dialogCtx);
                                                      },
                                                      child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.emerald)),
              error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent))),
            ),
          ),
        ],
      ),
    );
  }
}
