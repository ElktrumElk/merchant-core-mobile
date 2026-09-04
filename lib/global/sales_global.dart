import 'package:first_flutter_project/network/transaction_service.dart';
import 'package:flutter/material.dart';
import 'package:first_flutter_project/pages/stockpage/stock_page.dart';

class OrderRecord {
  final int id;
  final List<Product> items;
  final double total;
  final DateTime date;
  final String label;

  OrderRecord({
    required this.id,
    required this.items,
    required this.total,
    required this.date,
    this.label = 'Sale',
  });
}

class OrderStore extends ChangeNotifier {
  static final OrderStore _instance = OrderStore._internal();

  factory OrderStore() => _instance;

  OrderStore._internal();

  final List<OrderRecord> _orders = [];
  final TransactionService _transactionService = TransactionService();

  List<OrderRecord> get orders => List.unmodifiable(_orders);

  int get orderCount => _orders.length;

  double get totalRevenue => _orders.fold(0.0, (sum, o) => sum + o.total);

  int get _nextId => _orders.isEmpty ? 1 : _orders.last.id + 1;

  Future<void> fetchOrders() async {
    try {
      final txns = await _transactionService.getTransactions();
      _orders.clear();
      for (var txn in txns) {
        _orders.add(OrderRecord(
          id: txn['id'].hashCode,
          items: [], // Backend transaction doesn't return full items list here
          total: (txn['amount'] ?? 0.0).toDouble(),
          date: DateTime.parse(txn['created_at']),
          label: txn['type'] == 'sale' ? 'Cash Sale' : 'Transaction',
        ));
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to fetch transactions: $e');
    }
  }

  void addOrder(List<Product> items, double total, {String label = 'Sale'}) {
    _orders.add(
      OrderRecord(
        id: _nextId,
        items: List.from(items),
        total: total,
        date: DateTime.now(),
        label: label,
      ),
    );
    notifyListeners();
  }

  void clearOrders() {
    _orders.clear();
    notifyListeners();
  }

  Map<int, double> revenueByMonth({int months = 6}) {
    final now = DateTime.now();
    final result = <int, double>{};
    for (var i = months - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final key = month.year * 12 + month.month;
      result[key] = 0.0;
    }
    for (final order in _orders) {
      final key = order.date.year * 12 + order.date.month;
      if (result.containsKey(key)) {
        result[key] = result[key]! + order.total;
      }
    }
    return result;
  }
}
