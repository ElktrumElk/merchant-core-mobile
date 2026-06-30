import 'package:first_flutter_project/components/settings/toggle_card.dart';
import 'package:first_flutter_project/global/valueNotifiers/gloabal_value_notifiers.dart';
import 'package:flutter/material.dart';

class NotificationPanel {
  void show(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade100;

    showModalBottomSheet(
      showDragHandle: true,
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              Text('Notifications',
                style: TextStyle(fontSize: 20, color: theme.colorScheme.onSurface)),
              const Spacer(),
              TextButton(
                onPressed: () => {},
                child: const Text('Clear All', style: TextStyle(fontSize: 13)),
              ),
            ]),
            const SizedBox(height: 16),
            ToggleCard(
              name: 'Push Notifications',
              icon: Icons.notifications_active,
              listenable: GlobalValueNotifiers.isGetNotify,
            ),
            const SizedBox(height: 16),
            Text('Recent Alerts',
              style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 10),
            _alertItem(bgColor, Icons.inventory_2, 'Low stock alert',
                '3 items are running out of stock', theme),
            _alertItem(bgColor, Icons.credit_card, 'Credit payment due',
                '2 payments are overdue', theme),
            _alertItem(bgColor, Icons.trending_up, 'Daily summary',
                'Today\'s revenue: SLE 0.00', theme),
          ]),
        );
      },
    );
  }

  Widget _alertItem(
    Color bg, IconData icon, String title, String subtitle, ThemeData theme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Icon(icon, size: 20, color: const Color(0xFF1565C0)),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
              style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface),
            ),
            Text(subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ],
        )),
      ]),
    );
  }
}
