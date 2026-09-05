import 'package:first_flutter_project/components/settings/toggle_card.dart';
import 'package:first_flutter_project/global/sales_global.dart';
import 'package:first_flutter_project/global/valueNotifiers/gloabal_value_notifiers.dart';
import 'package:flutter/material.dart';

final OrderStore orderStore = OrderStore();

class NotificationPanel {
  void show(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade100;

    showModalBottomSheet(
      showDragHandle: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        ValueNotifier<List> orders = ValueNotifier<List>(
          orderStore.orders.reversed.take(7).toList(),
        );
        final sheetHeight = MediaQuery.of(ctx).size.height * 0.65;
        return Container(
          height: sheetHeight,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListenableBuilder(
            listenable: orders,
            builder: (context, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 20,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          OrderStore().clearOrders();
                          OrderStore();
                        },
                        child: const Text(
                          'Clear All',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ToggleCard(
                    name: 'Push Notifications',
                    icon: Icons.notifications_active,
                    listenable: GlobalValueNotifiers.isGetNotify,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    orders.value.isEmpty ? 'No Recent Alerts' : 'Recent Alerts',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: orders.value.isEmpty
                        ? Center(
                            child: Text(
                              'No recent alerts',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 8),
                            itemCount: orders.value.length,
                            itemBuilder: (context, index) {
                              final order = orders.value[index];
                              return _alertItem(
                                bgColor,
                                order.label.startsWith('Credit')
                                    ? Icons.credit_card
                                    : Icons.money_off,
                                order.label,
                                order.date.toString(),
                                theme,
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _alertItem(
    Color bg,
    IconData icon,
    String title,
    String subtitle,
    ThemeData theme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1565C0)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
