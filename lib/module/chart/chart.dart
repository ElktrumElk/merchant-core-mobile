import 'package:first_flutter_project/global/sales_global.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RevenueLineChart extends StatelessWidget {
  const RevenueLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final revenueData = OrderStore().revenueByMonth(months: 6);
    final entries = revenueData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (entries.isEmpty || entries.every((e) => e.value == 0.0)) {
      return Container(
        padding: const EdgeInsets.all(10.0),
        height: 250,
        child: Center(
          child: Text(
            'No revenue data yet.\nComplete a sale to see trends.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withAlpha(100),
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    final maxY = entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final minY = 0.0;
    final yPadding = maxY * 0.15;

    final spots = <FlSpot>[];
    for (var i = 0; i < entries.length; i++) {
      spots.add(FlSpot(i.toDouble(), entries[i].value));
    }

    final monthLabels = entries.map((e) {
      final month = e.key % 12;
      return _monthAbbr(month == 0 ? 12 : month);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(10.0),
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: theme.dividerColor.withAlpha(100),
                strokeWidth: 1,
              );
            },
          ),
          minY: minY,
          maxY: maxY + yPadding,
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i >= 0 && i < monthLabels.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        monthLabels[i],
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withAlpha(150),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                getTitlesWidget: (value, meta) {
                  if (value == meta.min || value == meta.max) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                      'SLE ${value.toInt()}',
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.onSurface.withAlpha(120),
                      ),
                    ),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              preventCurveOverShooting: true,
              color: theme.colorScheme.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: theme.colorScheme.primary,
                    strokeWidth: 2,
                    strokeColor: theme.cardColor,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withAlpha(50),
                    theme.colorScheme.primary.withAlpha(10),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthAbbr(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
