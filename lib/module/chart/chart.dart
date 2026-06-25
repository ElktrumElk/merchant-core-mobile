import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RevenueLineChart extends StatelessWidget {
  const RevenueLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      height: 250, // Charts need a explicit parental layout bound

      child: LineChart(
        LineChartData(
          // 1. Control Gridlines background presentation
          gridData: const FlGridData(show: true, drawVerticalLine: true),
          minY: -10,
          maxY: 10,
          titlesData: const FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),

          // 2. Map coordinates array (X represents index, Y represents value)
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 0), // Point 1
                FlSpot(10, 0), // Point 2
                FlSpot(20, 0), // Point 3
                FlSpot(30, 0), // Point 4
                FlSpot(40, 0), // Point 5
              ],
              isCurved: true, // Smooths the jagged straight plotting vectors
              color: Colors.blueAccent,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true), // Shows circular coordinates highlights

              // 3. Render elegant styling gradient fills underneath the curve
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.blueAccent.withAlpha(30),
                    Colors.blueAccent.withAlpha(30),
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
}
