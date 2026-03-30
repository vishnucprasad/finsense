import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finsense/core/theme/app_theme.dart';
import 'package:finsense/features/accounts/view_models/account_provider.dart';
import 'package:finsense/features/accounts/views/add_account_sheet.dart';
import 'package:finsense/features/accounts/views/edit_account_sheet.dart';
import 'package:finsense/shared/widgets/global_drawer.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Accounts'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: const GlobalDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: AppTheme.deepNavy,
            builder: (context) => const AddAccountSheet(),
          );
        },
        backgroundColor: AppTheme.cyan,
        child: const Icon(Icons.add, color: AppTheme.deepNavy),
      ),
      body: accountsAsync.when(
        data: (accounts) {
          if (accounts.isEmpty) {
            return const Center(
              child: Text(
                "No accounts found. Add one!",
                style: TextStyle(color: Colors.white54),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final acc = accounts[index];
              final color = Color(int.parse(acc.colorHex, radix: 16));
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.8), color.withOpacity(0.4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          acc.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              acc.type == 'Bank'
                                  ? Icons.account_balance
                                  : (acc.type == 'Card'
                                        ? Icons.credit_card
                                        : Icons.money),
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.white70,
                              ),
                              color: AppTheme.deepNavy,
                              onSelected: (value) {
                                if (value == 'edit') {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: AppTheme.deepNavy,
                                    builder: (context) =>
                                        EditAccountSheet(account: acc),
                                  );
                                } else if (value == 'delete') {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      backgroundColor: AppTheme.deepNavy,
                                      title: const Text(
                                        'Delete Account',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      content: const Text(
                                        'Deleting this account will permanently remove its associated transactions and impact historical net worth mappings. Are you absolutely sure?',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          height: 1.4,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: Colors.white54,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            ref
                                                .read(
                                                  accountNotifierProvider
                                                      .notifier,
                                                )
                                                .deleteAccount(acc.id);
                                            Navigator.pop(ctx);
                                          },
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(
                                              color: Colors.redAccent,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                    const PopupMenuItem<String>(
                                      value: 'edit',
                                      child: ListTile(
                                        leading: Icon(
                                          Icons.edit,
                                          color: AppTheme.cyan,
                                        ),
                                        title: Text(
                                          'Edit Account',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'delete',
                                      child: ListTile(
                                        leading: Icon(
                                          Icons.delete,
                                          color: Colors.redAccent,
                                        ),
                                        title: Text(
                                          'Delete Account',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      acc.type,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'BALANCE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white54,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      '₹${acc.balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.emerald),
        ),
        error: (e, _) => Center(
          child: Text(
            'Error: $e',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }
}
