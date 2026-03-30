import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:finsense/core/routing/main_layout.dart';
import 'package:finsense/features/dashboard/views/dashboard_screen.dart';
import 'package:finsense/features/dashboard/views/monthly_breakdown_screen.dart';
import 'package:finsense/features/transactions/views/transaction_entry_screen.dart';
import 'package:finsense/features/accounts/views/accounts_screen.dart';
import 'package:finsense/features/categories/views/category_manager_screen.dart';
import 'package:finsense/features/goals/views/goal_screen.dart';
import 'package:finsense/features/goals/views/set_goal_screen.dart';
import 'package:finsense/features/transactions/models/transaction_model.dart';
import 'package:finsense/features/ai_insights/views/chat_screen.dart';
import 'package:finsense/features/ai_insights/views/ai_summary_screen.dart';
import 'package:finsense/features/settings/views/settings_screen.dart';
import 'package:finsense/features/transactions/views/all_transactions_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    GoRoute(path: '/goals', builder: (context, state) => const GoalScreen()),
    GoRoute(
      path: '/accounts',
      builder: (context, state) => const AccountsScreen(),
    ),
    GoRoute(
      path: '/categories',
      builder: (context, state) => const CategoryManagerScreen(),
    ),
    GoRoute(
      path: '/set-goal',
      builder: (context, state) => const SetGoalScreen(),
    ),
    GoRoute(
      path: '/transaction-entry',
      builder: (context, state) {
        final t = state.extra as TransactionModel?;
        return TransactionEntryScreen(existingTransaction: t);
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainLayout(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const DashboardScreen(),
              routes: [
                GoRoute(
                  path: 'monthly-breakdown',
                  builder: (context, state) => const MonthlyBreakdownScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/transactions',
              builder: (context, state) => const AllTransactionsScreen(),
              routes: [
                GoRoute(
                  path: 'ai-summary',
                  builder: (context, state) => const AISummaryScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/chat',
              builder: (context, state) => const ChatScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
