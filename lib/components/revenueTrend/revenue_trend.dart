

import 'package:first_flutter_project/module/chart/chart.dart';
import 'package:flutter/material.dart';

class RevenueTrend extends StatelessWidget {
  const RevenueTrend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.grey.withAlpha(70), offset: const Offset(0, 5))
          ],
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Revenue Trend',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                    border:
                        Border.all(color: Colors.grey.withAlpha(80), width: .5),
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: const Text('Last 6 Month'),
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