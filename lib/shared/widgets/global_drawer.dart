import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:finsense/core/theme/app_theme.dart';
import 'package:finsense/features/accounts/view_models/account_provider.dart';

class GlobalDrawer extends ConsumerWidget {
  const GlobalDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountNotifierProvider);

    double netWorth = 0.0;
    if (accountsAsync.hasValue) {
      for (var a in accountsAsync.value!) {
        netWorth += a.balance;
      }
    }

    return Drawer(
      backgroundColor: AppTheme.deepNavy,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.cyan.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.account_balance,
                          color: AppTheme.cyan,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'FinSense AI',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'TOTAL NET WORTH',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.cyan,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  accountsAsync.when(
                    data: (_) => Text(
                      '₹${netWorth.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    loading: () => const CircularProgressIndicator(
                      color: AppTheme.emerald,
                    ),
                    error: (e, st) => const Text(
                      'Error loading',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(Icons.dashboard, 'Dashboard', () {
                    Navigator.pop(context);
                    context.go('/home');
                  }),
                  _buildDrawerItem(
                    Icons.account_balance_wallet,
                    'Accounts',
                    () {
                      Navigator.pop(context);
                      context.push('/accounts');
                    },
                  ),
                  _buildDrawerItem(Icons.category, 'Categories', () {
                    Navigator.pop(context);
                    context.push('/categories');
                  }),
                  _buildDrawerItem(Icons.receipt_long, 'All Transactions', () {
                    Navigator.pop(context);
                    context.go('/transactions');
                  }),
                  _buildDrawerItem(Icons.flag, 'Goals Pipeline', () {
                    Navigator.pop(context);
                    context.go('/goals');
                  }),
                  _buildDrawerItem(
                    Icons.chat_bubble_outline,
                    'AI Assistant',
                    () {
                      Navigator.pop(context);
                      context.go('/chat');
                    },
                  ),
                  const Divider(color: Colors.white24, height: 32),
                  _buildDrawerItem(Icons.settings, 'Settings', () {
                    Navigator.pop(context);
                    context.go('/settings');
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      onTap: onTap,
    );
  }
}
