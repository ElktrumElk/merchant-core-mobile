import 'package:first_flutter_project/global/sales_global.dart';
import 'package:flutter/material.dart';

enum CreditStatus { paid, pending, overdue }

class CreditUser {
  final int id;
  final String name;
  final double amount;
  final String dueDate;
  final CreditStatus status;

  CreditUser({
    required this.id,
    required this.name,
    required this.amount,
    required this.dueDate,
    required this.status,
  });

  CreditUser copyWith({CreditStatus? status}) {
    return CreditUser(
      id: id,
      name: name,
      amount: amount,
      dueDate: dueDate,
      status: status ?? this.status,
    );
  }
}

class CreditStore extends ChangeNotifier {
  static final CreditStore _instance = CreditStore._internal();
  factory CreditStore() => _instance;
  CreditStore._internal();

  final List<CreditUser> _users = [];

  List<CreditUser> get users => List.unmodifiable(_users);
  double get totalOutstanding => _users.fold(0.0, (sum, u) => sum + u.amount);
  int get overdueCount => _users.where((u) => u.status == CreditStatus.overdue).length;
  double get collected => _users.where((u) => u.status == CreditStatus.paid).fold(0.0, (sum, u) => sum + u.amount);

  void loadSampleData() {
    if (_users.isNotEmpty) return;
    _users.addAll([
      CreditUser(id: 1, name: 'Alice Johnson', amount: 2500.00, dueDate: '2026-07-15', status: CreditStatus.pending),
      CreditUser(id: 2, name: 'Bob Smith', amount: 4800.00, dueDate: '2026-06-30', status: CreditStatus.overdue),
      CreditUser(id: 3, name: 'Carol White', amount: 1200.00, dueDate: '2026-07-20', status: CreditStatus.paid),
      CreditUser(id: 4, name: 'David Brown', amount: 3200.00, dueDate: '2026-08-01', status: CreditStatus.pending),
      CreditUser(id: 5, name: 'Eve Davis', amount: 1500.00, dueDate: '2026-06-25', status: CreditStatus.overdue),
      CreditUser(id: 6, name: 'Frank Wilson', amount: 6000.00, dueDate: '2026-07-10', status: CreditStatus.pending),
    ]);
    notifyListeners();
  }

  void markAsPaid(int userId) {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      final user = _users[index];
      _users[index] = user.copyWith(status: CreditStatus.paid);
      OrderStore().addOrder([], user.amount, label: 'Credit Payment - ${user.name}');
      notifyListeners();
    }
  }

  void addCreditUser(String name, double amount, String dueDate) {
    final newId = _users.isEmpty ? 1 : _users.map((u) => u.id).reduce((a, b) => a > b ? a : b) + 1;
    _users.add(CreditUser(
      id: newId,
      name: name,
      amount: amount,
      dueDate: dueDate,
      status: CreditStatus.pending,
    ));
    notifyListeners();
  }

  void deleteUser(int userId) {
    _users.removeWhere((u) => u.id == userId);
    notifyListeners();
  }
}
