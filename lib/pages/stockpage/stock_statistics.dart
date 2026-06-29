import 'package:flutter/material.dart';
import 'package:first_flutter_project/components/statistics/statistics.dart';

class StockStatistics extends StatelessWidget {
  final int totalItems;
  final int lowStock;
  final double totalValue;
  final int outOfStock;

  const StockStatistics({
    super.key,
    required this.totalItems,
    required this.lowStock,
    required this.totalValue,
    required this.outOfStock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Statistics(title: 'Total Items', value: totalItems.toString()),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Statistics(title: 'Low Stock', value: lowStock.toString()),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Statistics(title: 'Value', value: 'SLE ${totalValue.toStringAsFixed(2)}'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Statistics(title: 'Out of Stock', value: outOfStock.toString()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
