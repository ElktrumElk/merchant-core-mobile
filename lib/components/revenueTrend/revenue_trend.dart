

import 'package:first_flutter_project/module/chart/chart.dart';
import 'package:flutter/material.dart';

class RevenueTrend extends StatelessWidget {
  const RevenueTrend({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withAlpha(130) : Colors.grey.withAlpha(70),
              offset: const Offset(0, 5),
            ),
          ],
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Revenue Trend',
                  style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                    border:
                        Border.all(color: theme.dividerColor, width: .5),
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: Text('Last 6 Month', style: TextStyle(color: theme.colorScheme.onSurface)),
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const RevenueLineChart(),
        ],
      ),
    );
  }

}