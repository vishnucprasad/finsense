import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:finsense/core/theme/app_theme.dart';
import 'package:finsense/features/ai_insights/view_models/ai_summary_provider.dart';
import 'package:finsense/features/ai_insights/view_models/chat_provider.dart';

class AISummaryScreen extends ConsumerStatefulWidget {
  const AISummaryScreen({super.key});

  @override
  ConsumerState<AISummaryScreen> createState() => _AISummaryScreenState();
}

class _AISummaryScreenState extends ConsumerState<AISummaryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aiSummaryProvider.notifier).generateNewSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(aiSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI Financial Health',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'As of ${DateFormat.yMMMd().format(DateTime.now())}',
              style: const TextStyle(fontSize: 12, color: Colors.white54),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: summaryAsync.when(
        data: (summary) {
          if (summary == null) return _buildLoading();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNarrativeCard(summary.narrative),
                const SizedBox(height: 24),
                _buildBurnRateAndSavings(
                  summary.burnRate,
                  summary.savingsPotential,
                ),
                const SizedBox(height: 24),
                _buildChartContainer(summary.projectedBalances),
                const SizedBox(height: 24),
                _buildTopCategories(summary.topCategories),
                const SizedBox(height: 24),
                _buildSteadyPath(summary.steadyPathRecommendations),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.cyan,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      ref
                          .read(chatControllerProvider.notifier)
                          .sendMessage(
                            "I have some follow-up questions regarding the AI Summary you just generated.",
                            hiddenContext:
                                "Recently generated AI Summary: ${summary.narrative}",
                          );
                      context.go('/chat');
                    },
                    icon: const Icon(
                      Icons.chat_bubble,
                      color: AppTheme.deepNavy,
                    ),
                    label: const Text(
                      'Ask a Follow-up',
                      style: TextStyle(
                        color: AppTheme.deepNavy,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
        loading: () => _buildLoading(),
        error: (err, _) {
          String errorMessage =
              'An unexpected error occurred while generating your insights. Please verify your connection.';
          final errStr = err.toString().toLowerCase();

          if (errStr.contains('quota exceeded') ||
              errStr.contains('rate limit') ||
              errStr.contains('429')) {
            errorMessage =
                'Your Gemini API key has exceeded its quota or rate limit. Please check your Google Cloud billing details or try again later.';
          } else if (errStr.contains('api key not valid') ||
              errStr.contains('api key')) {
            errorMessage =
                'Your AI API key was rejected. Please check your Settings to ensure it is entered correctly.';
          } else if (errStr.contains('socketexception') ||
              errStr.contains('network') ||
              errStr.contains('failed host')) {
            errorMessage =
                'Looks like you are offline. Please check your internet connection and try again.';
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off, color: Colors.white24, size: 80),
                  const SizedBox(height: 24),
                  const Text(
                    'Insight Unavailable',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.cyan.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => ref
                        .read(aiSummaryProvider.notifier)
                        .generateNewSummary(),
                    icon: const Icon(Icons.refresh, color: AppTheme.cyan),
                    label: const Text(
                      'Try Again',
                      style: TextStyle(
                        color: AppTheme.cyan,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNarrativeCard(String narrative) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cyan.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cyan.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: AppTheme.cyan),
              SizedBox(width: 8),
              Text(
                'The Story',
                style: TextStyle(
                  color: AppTheme.cyan,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            narrative,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBurnRateAndSavings(double burnRate, String savings) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Burn Rate',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${burnRate.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.emerald.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Actionable Savings',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  savings,
                  style: const TextStyle(
                    color: AppTheme.emerald,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartContainer(List<double> balances) {
    if (balances.isEmpty) return const SizedBox.shrink();

    final spots = balances
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
    final maxY =
        balances.reduce((curr, next) => curr > next ? curr : next) * 1.2;
    final minY =
        balances.reduce((curr, next) => curr < next ? curr : next) * 0.8;

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Projected Trajectory',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (balances.length - 1).toDouble(),
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppTheme.cyan,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.cyan.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCategories(Map<String, double> categories) {
    return ExpansionTile(
      title: const Text(
        'Budget Leaks (Top Spend)',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      iconColor: AppTheme.cyan,
      collapsedIconColor: Colors.white54,
      children: categories.entries.map((e) {
        return ListTile(
          leading: const Icon(Icons.trending_up, color: Colors.amber),
          title: Text(e.key, style: const TextStyle(color: Colors.white)),
          trailing: Text(
            '₹${e.value.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSteadyPath(List<String> recommendations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Steady Path Recommendations',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...recommendations.map(
          (r) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.emerald,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    r,
                    style: const TextStyle(color: Colors.white70, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.05),
      highlightColor: Colors.white.withOpacity(0.2),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
