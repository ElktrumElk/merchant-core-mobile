import 'package:first_flutter_project/components/greetingCard/greeting_card.dart';
import 'package:first_flutter_project/components/statistics/statistics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

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
}

class CreditLedger extends StatefulWidget {
  const CreditLedger({super.key});

  @override
  State<CreditLedger> createState() => _CreditLedgerState();
}

class _CreditLedgerState extends State<CreditLedger> {
  final List<CreditUser> _users = [
    CreditUser(id: 1, name: 'Alice Johnson', amount: 2500.00, dueDate: '2026-07-15', status: CreditStatus.pending),
    CreditUser(id: 2, name: 'Bob Smith', amount: 4800.00, dueDate: '2026-06-30', status: CreditStatus.overdue),
    CreditUser(id: 3, name: 'Carol White', amount: 1200.00, dueDate: '2026-07-20', status: CreditStatus.paid),
    CreditUser(id: 4, name: 'David Brown', amount: 3200.00, dueDate: '2026-08-01', status: CreditStatus.pending),
    CreditUser(id: 5, name: 'Eve Davis', amount: 1500.00, dueDate: '2026-06-25', status: CreditStatus.overdue),
    CreditUser(id: 6, name: 'Frank Wilson', amount: 6000.00, dueDate: '2026-07-10', status: CreditStatus.pending),
  ];

  double get _totalOutstanding =>
      _users.fold(0.0, (sum, u) => sum + u.amount);
  int get _overdueCount =>
      _users.where((u) => u.status == CreditStatus.overdue).length;
  double get _collected =>
      _users.where((u) => u.status == CreditStatus.paid).fold(0.0, (sum, u) => sum + u.amount);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView(
      children: [
        const GreetingCard(
          title: 'Credit',
          message: 'Get Insight of your credit',
        ),
        Container(
          padding: const EdgeInsets.all(10),
          child: StaggeredGrid.count(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              StaggeredGridTile.count(
                crossAxisCellCount: 2,
                mainAxisCellCount: 2,
                child: Statistics(
                  title: 'Total Outstanding',
                  heroValue: 'NLE ${_totalOutstanding.toStringAsFixed(2)}',
                  hero: true,
                  info: '12% from last month',
                ),
              ),
              StaggeredGridTile.count(
                crossAxisCellCount: 1,
                mainAxisCellCount: 1,
                child: Statistics(
                  title: 'Overdue',
                  value: _overdueCount.toString(),
                  color: Colors.red.shade600,
                  iconUrl: 'assets/icons/alert.png',
                  iconColor: Colors.red.shade600,
                ),
              ),
              StaggeredGridTile.count(
                crossAxisCellCount: 1,
                mainAxisCellCount: 1,
                child: Statistics(
                  title: 'Collected',
                  value: 'NLE ${_collected.toStringAsFixed(2)}',
                  color: Colors.green.shade600,
                  iconUrl: 'assets/icons/dollar.png',
                  iconColor: Colors.green.shade600,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Credit History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                '${_users.length} users',
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withAlpha(150),
                ),
              ),
            ],
          ),
        ),
        ..._users.map((user) => _buildUserTile(context, user, isDark)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildUserTile(BuildContext context, CreditUser user, bool isDark) {
    final theme = Theme.of(context);

    Color statusColor;
    String statusLabel;
    IconData statusIcon;
    switch (user.status) {
      case CreditStatus.paid:
        statusColor = Colors.green;
        statusLabel = 'Paid';
        statusIcon = Icons.check_circle;
      case CreditStatus.pending:
        statusColor = Colors.orange;
        statusLabel = 'Pending';
        statusIcon = Icons.schedule;
      case CreditStatus.overdue:
        statusColor = Colors.red;
        statusLabel = 'Overdue';
        statusIcon = Icons.error;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: user.status == CreditStatus.overdue
              ? Colors.red.withAlpha(60)
              : theme.dividerColor,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: theme.colorScheme.primary.withAlpha(30),
            child: Text(
              user.name.isNotEmpty ? user.name[0] : '?',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Due: ${user.dueDate}',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withAlpha(130),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'NLE ${user.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 12, color: statusColor),
                    const SizedBox(width: 3),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
