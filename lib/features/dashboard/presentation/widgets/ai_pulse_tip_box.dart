import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/dashboard_provider.dart';

class AIPulseTipBox extends ConsumerWidget {
  const AIPulseTipBox({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipState = ref.watch(financialTipProvider);

    return GlassmorphismContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppTheme.cyan),
              const SizedBox(width: 8),
              Text(
                'AI Financial Insight',
                style: TextStyle(
                  color: AppTheme.emerald.withOpacity(0.9),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white70, size: 20),
                onPressed: () => ref.read(financialTipProvider.notifier).loadTip(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          tipState.when(
            data: (tip) => Text(
              tip ?? 'Tap the refresh icon to scan your recent transactions and get a behavioral tip.',
              style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
            ),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(color: AppTheme.cyan),
              ),
            ),
            error: (err, _) {
              final errStr = err.toString().toLowerCase();
              String msg = 'An error occurred loading insight.';
              if (errStr.contains('quota extended') || errStr.contains('quota exceeded') || errStr.contains('rate limit') || errStr.contains('429')) {
                msg = 'Your API key quota exceeded.';
              } else if (errStr.contains('api key not valid') || errStr.contains('api key')) {
                msg = 'Invalid or missing API key.';
              } else if (errStr.contains('socketexception') || errStr.contains('network') || errStr.contains('failed host')) {
                msg = 'Network connection failed.';
              }
              return Text(
                msg,
                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              );
            },
          ),
        ],
      ),
    );
  }
}
