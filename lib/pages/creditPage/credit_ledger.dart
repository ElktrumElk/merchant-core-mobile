import 'package:first_flutter_project/components/greetingCard/greeting_card.dart';
import 'package:first_flutter_project/components/statistics/statistics.dart';
import 'package:first_flutter_project/global/credit_global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class CreditLedger extends StatefulWidget {
  const CreditLedger({super.key});

  @override
  State<CreditLedger> createState() => _CreditLedgerState();
}

class _CreditLedgerState extends State<CreditLedger> {
  final CreditStore _creditStore = CreditStore();

  @override
  void initState() {
    super.initState();
    _creditStore.loadSampleData();
  }

  void _markAsPaid(CreditUser user) {
    _creditStore.markAsPaid(user.id);
  }

  void _deleteUser(CreditUser user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Remove ${user.name} from credit list?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              _creditStore.deleteUser(user.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: _creditStore,
      builder: (context, _) {
        final users = _creditStore.users;

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
                      heroValue: 'SLE ${_creditStore.totalOutstanding.toStringAsFixed(2)}',
                      hero: true,
                      info: '${_creditStore.overdueCount} overdue',
                    ),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 1,
                    mainAxisCellCount: 1,
                    child: Statistics(
                      title: 'Overdue',
                      value: _creditStore.overdueCount.toString(),
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
                      value: 'SLE ${_creditStore.collected.toStringAsFixed(2)}',
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
                    '${users.length} users',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface.withAlpha(150),
                    ),
                  ),
                ],
              ),
            ),
            ...users.map((user) => _buildUserTile(context, user, isDark)),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildUserTile(BuildContext context, CreditUser user, bool isDark) {
    final theme = Theme.of(context);
    final isPaid = user.status == CreditStatus.paid;

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
            backgroundColor: !isPaid
                ? theme.colorScheme.primary.withAlpha(30)
                : Colors.green.withAlpha(30),
            child: Icon(
              isPaid ? Icons.check_circle : Icons.person,
              size: 20,
              color: isPaid ? Colors.green : theme.colorScheme.primary,
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
                    color: isPaid
                        ? theme.colorScheme.onSurface.withAlpha(120)
                        : theme.colorScheme.onSurface,
                    decoration: isPaid ? TextDecoration.lineThrough : null,
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
                'SLE ${user.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isPaid
                      ? Colors.green
                      : theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isPaid)
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
                  if (isPaid)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 12, color: Colors.green),
                          const SizedBox(width: 3),
                          Text(
                            'Paid',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(width: 6),
                  if (!isPaid)
                    GestureDetector(
                      onTap: () => _markAsPaid(user),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.green.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.payments, size: 16, color: Colors.green[700]),
                      ),
                    ),
                  GestureDetector(
                    onTap: () => _deleteUser(user),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.delete_outline, size: 16, color: Colors.red[400]),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
