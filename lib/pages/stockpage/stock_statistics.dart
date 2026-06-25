
import 'package:flutter/cupertino.dart';

import 'package:first_flutter_project/components/statistics/statistics.dart';
class StockStatistics extends StatelessWidget {
  const StockStatistics({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Statistics(title: 'Total Items', value: '0'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Statistics(title: 'Low Stock', value: '0'),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: Statistics(title: 'Value', value: '0'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Statistics(title: 'Out of Stock', value: '0'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}