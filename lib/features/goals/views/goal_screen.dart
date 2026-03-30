import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:finsense/core/theme/app_theme.dart';
import 'package:finsense/features/goals/view_models/goal_provider.dart';
import 'package:finsense/shared/widgets/global_drawer.dart';

class GoalScreen extends ConsumerWidget {
  const GoalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal Engine'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: const GlobalDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/set-goal'),
        backgroundColor: AppTheme.cyan,
        child: const Icon(Icons.add, color: AppTheme.deepNavy),
      ),
      body: goalsAsync.when(
        data: (goals) {
          if (goals.isEmpty) {
            return const Center(
              child: Text(
                "No goals active. Let's set one!",
                style: TextStyle(color: Colors.white54),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final g = goals[index];
              final progress = g.targetAmount == 0
                  ? 0.0
                  : g.currentSaved / g.targetAmount;
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          g.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white54),
                          onPressed: () => ref
                              .read(goalNotifierProvider.notifier)
                              .deleteGoal(g.id),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Target: ₹${g.targetAmount.toStringAsFixed(0)} by ${DateFormat.yMMMd().format(g.targetDate)}',
                      style: const TextStyle(color: AppTheme.cyan),
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: Colors.white.withOpacity(0.1),
                      color: AppTheme.emerald,
                      minHeight: 8,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'AI Steady Path:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    g.aiGeneratedPlan != null && g.aiGeneratedPlan!.isNotEmpty
                        ? MarkdownBody(
                            data: g.aiGeneratedPlan!,
                            styleSheet: MarkdownStyleSheet(
                              p: const TextStyle(
                                color: Colors.white54,
                                height: 1.4,
                                fontSize: 14,
                              ),
                              h1: const TextStyle(
                                color: AppTheme.cyan,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              h2: const TextStyle(
                                color: AppTheme.cyan,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              h3: const TextStyle(
                                color: AppTheme.cyan,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              strong: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                              listBullet: const TextStyle(
                                color: Colors.white54,
                              ),
                            ),
                          )
                        : const Text(
                            'No plan generated.',
                            style: TextStyle(
                              color: Colors.white54,
                              height: 1.4,
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
        error: (err, _) => Center(
          child: Text(
            'Error: $err',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }
}
