import 'dart:async';

import 'package:first_flutter_project/components/greetingCard/greeting_card.dart';
import 'package:first_flutter_project/components/revenueTrend/revenue_trend.dart';
import 'package:first_flutter_project/components/statistics/home_statistics.dart';
import 'package:first_flutter_project/components/subcards/sub_cards.dart';
import 'package:first_flutter_project/global/credit_global.dart';
import 'package:first_flutter_project/global/sales_global.dart';
import 'package:first_flutter_project/global/stock/stock_global.dart';
import 'package:first_flutter_project/network/transaction_service.dart';
//import 'package:first_flutter_project/pages/stockpage/stock_page.dart';
import 'package:flutter/material.dart';

export './home_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final OrderStore _orderStore = OrderStore();
  final CreditStore _creditStore = CreditStore();
  Timer? _pollingTimer;

  void _loadItems() async {
    await StockGlobal.loadItems();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _loadItems();
      _creditStore.loadSampleData();
      _orderStore.fetchOrders();
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _creditStore.loadSampleData();
      _orderStore.fetchOrders();
    });
    _loadItems();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_orderStore, _creditStore, StockGlobal()]),
      builder: (context, _) {
        return ListView(
          scrollDirection: Axis.vertical,
          children: [
            const GreetingCard(
              title: 'Dashboard',
              message: 'Here is what happening at Merchant Core today',
            ),
            const HomeStatistics(),
            const RevenueTrend(),
            SubCards(
              title: 'Recent Transaction',
              trailing: _orderStore.orders.isEmpty
                  ? null
                  : TextButton(
                      onPressed: () => _clearRecentTransactions(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 32),
                      ),
                      child: const Text(
                        'Clear All',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
              widget: _buildRecentTransactions(),
            ),
            SubCards(
              title: 'Alerts',
              widget: _buildAlerts(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentTransactions() {
    final theme = Theme.of(context);
    final orders = _orderStore.orders.reversed.take(5).toList();

    if (orders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            'No transactions yet.\nComplete a sale to see it here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withAlpha(100),
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    return Column(
      children: orders.map((order) {
        final timeAgo = _timeAgo(order.date);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: order.label.startsWith('Credit')
                      ? Colors.orange.withAlpha(25)
                      : Colors.green.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  order.label.startsWith('Credit')
                      ? Icons.credit_card
                      : Icons.shopping_bag,
                  size: 18,
                  color: order.label.startsWith('Credit')
                      ? Colors.orange[700]
                      : Colors.green[700],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withAlpha(120),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'SLE ${order.total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Future<void> _clearRecentTransactions(BuildContext context) async {
    try {
      await TransactionService().clearTransactions();
      _orderStore.clearOrders();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to clear transactions: $e')),
        );
      }
    }
  }

  Widget _buildAlerts() {

    final theme = Theme.of(context);
    final alerts = <Map<String, dynamic>>[];

    final lowStockCount = StockGlobal().lowStock;

    if (lowStockCount > 0) {
      alerts.add({
        'icon': Icons.inventory_2,
        'message': '$lowStockCount product${lowStockCount == 1 ? '' : 's'} low on stock',
        'color': Colors.orange,
      });
    }

    final outOfStockCount = StockGlobal().outOfStock;
    if (outOfStockCount > 0) {
      alerts.add({
        'icon': Icons.block,
        'message': '$outOfStockCount product${outOfStockCount == 1 ? '' : 's'} out of stock',
        'color': Colors.red,
      });
    }

    final overdueCount = _creditStore.overdueCount;
    if (overdueCount > 0) {
      alerts.add({
        'icon': Icons.warning_amber,
        'message': '$overdueCount credit account${overdueCount == 1 ? '' : 's'} overdue',
        'color': Colors.red.shade700,
      });
    }

    if (alerts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 16, color: Colors.green[400]),
              const SizedBox(width: 6),
              Text(
                'All clear, no alerts',
                style: TextStyle(
                  color: Colors.green[400],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: alerts.map((alert) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              Icon(
                alert['icon'] as IconData,
                size: 18,
                color: alert['color'] as Color,
              ),
              const SizedBox(width: 10),
              Text(
                alert['message'] as String,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.month}/${date.day}';
  }
}
