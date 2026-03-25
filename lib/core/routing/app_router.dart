import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'main_layout.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/dashboard/presentation/monthly_breakdown_screen.dart';
import '../../features/dashboard/presentation/transaction_entry_screen.dart';
import '../../features/accounts/presentation/accounts_screen.dart';
import '../../features/categories/presentation/category_manager_screen.dart';
import '../../features/goals/presentation/goal_screen.dart';
import '../../features/goals/presentation/set_goal_screen.dart';
import '../../../core/models/transaction_model.dart';
import '../../features/ai_assistant/presentation/chat_screen.dart';
import '../../features/ai_assistant/presentation/ai_summary_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/transactions/presentation/all_transactions_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/goals',
      builder: (context, state) => const GoalScreen(),
    ),
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
