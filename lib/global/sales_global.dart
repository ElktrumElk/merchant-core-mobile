import 'package:flutter/material.dart';
import 'package:first_flutter_project/pages/stockpage/stock_page.dart';

class OrderRecord {
  final int id;
  final List<Product> items;
  final double total;
  final DateTime date;

  OrderRecord({
    required this.id,
    required this.items,
    required this.total,
    required this.date,
  });
}

class OrderStore extends ChangeNotifier {
  static final OrderStore _instance = OrderStore._internal();
  factory OrderStore() => _instance;
  OrderStore._internal();

  final List<OrderRecord> _orders = [];

  List<OrderRecord> get orders => List.unmodifiable(_orders);
  int get orderCount => _orders.length;
  double get totalRevenue => _orders.fold(0.0, (sum, o) => sum + o.total);

  int get _nextId => _orders.isEmpty ? 1 : _orders.last.id + 1;

  void addOrder(List<Product> items, double total) {
    _orders.add(OrderRecord(
      id: _nextId,
      items: List.from(items),
      total: total,
      date: DateTime.now(),
    ));
    notifyListeners();
  }
}
