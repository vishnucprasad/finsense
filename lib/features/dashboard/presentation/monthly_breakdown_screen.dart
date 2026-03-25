import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../categories/application/category_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../application/transaction_provider.dart';
import 'widgets/global_drawer.dart';

class MonthlyBreakdownScreen extends ConsumerWidget {
  const MonthlyBreakdownScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionNotifierProvider);
    final categoriesAsync = ref.watch(categoryNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Breakdown'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: const GlobalDrawer(),
      body: transactionsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.emerald),
        ),
        error: (e, st) => Center(
          child: Text(
            'Error: $e',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
        data: (transactions) {
          final now = DateTime.now();
          final thisMonth = transactions
              .where(
                (t) => t.date.month == now.month && t.date.year == now.year,
              )
              .toList();
          final lastMonth = transactions
              .where(
                (t) =>
                    t.date.month == (now.month == 1 ? 12 : now.month - 1) &&
                    t.date.year == (now.month == 1 ? now.year - 1 : now.year),
              )
              .toList();

          final thisMonthTotal = thisMonth.fold(
            0.0,
            (sum, t) => sum + t.amount,
          );
          final lastMonthTotal = lastMonth.fold(
            0.0,
            (sum, t) => sum + t.amount,
          );

          final categories = categoriesAsync.valueOrNull ?? [];
          final Map<String, double> categoryTotals = {};
          for (var t in thisMonth) {
            final categoryName = categories.firstWhere((c) => c.id == t.categoryId, orElse: () => categories.first).name;
            categoryTotals[categoryName] =
                (categoryTotals[categoryName] ?? 0) + t.amount;
          }

          final List<PieChartSectionData> pieSections = [];
          final colors = [
            AppTheme.emerald,
            AppTheme.cyan,
            Colors.blueAccent,
            Colors.purpleAccent,
            Colors.orangeAccent,
          ];
          int colorIndex = 0;
          categoryTotals.forEach((category, amount) {
            final percentage = thisMonthTotal > 0
                ? (amount / thisMonthTotal) * 100
                : 0;
            if (percentage > 0) {
              pieSections.add(
                PieChartSectionData(
                  value: amount,
                  color: colors[colorIndex % colors.length],
                  title: '$category\n${percentage.toStringAsFixed(0)}%',
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              );
              colorIndex++;
            }
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Spending by Category (This Month)',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                if (pieSections.isEmpty)
                  const SizedBox(
                    height: 250,
                    child: Center(
                      child: Text(
                        'No spending data for this month',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 50,
                        sections: pieSections,
                      ),
                    ),
                  ),
                const SizedBox(height: 40),
                const Text(
                  'Current vs Previous Month',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 250,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY:
                          (thisMonthTotal > lastMonthTotal
                                  ? thisMonthTotal
                                  : lastMonthTotal) *
                              1.2 +
                          100,
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  value == 0 ? 'Prev Month' : 'This Month',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(
                              toY: lastMonthTotal,
                              color: Colors.white38,
                              width: 22,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(
                              toY: thisMonthTotal,
                              color: AppTheme.cyan,
                              width: 22,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
