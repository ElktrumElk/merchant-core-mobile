import 'package:first_flutter_project/components/settings/toggle_card.dart';
import 'package:first_flutter_project/global/valueNotifiers/gloabal_value_notifiers.dart';
import 'package:first_flutter_project/network/notification_service.dart';
import 'package:flutter/material.dart';

class NotificationPanel {
  final NotificationService _notificationService = NotificationService();

  void show(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade100;

    showModalBottomSheet(
      showDragHandle: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        ValueNotifier<List<Map<String, dynamic>>> notifications =
            ValueNotifier<List<Map<String, dynamic>>>([]);
        _loadNotifications(notifications);
        final sheetHeight = MediaQuery.of(ctx).size.height * 0.65;
        return Container(
          height: sheetHeight,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListenableBuilder(
            listenable: notifications,
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
                        onPressed: () => _clearAll(context, notifications),
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
                    notifications.value.isEmpty
                        ? 'No Recent Alerts'
                        : 'Recent Alerts',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: notifications.value.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.notifications_none,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No recent alerts',
                                  style: TextStyle(color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 8),
                            itemCount: notifications.value.length,
                            itemBuilder: (context, index) {
                              final notification = notifications.value[index];
                              return _alertItem(
                                bgColor,
                                Icons.notifications_active,
                                notification['title']?.toString() ?? '',
                                notification['message']?.toString() ?? '',
                                theme,
                                onDelete: () =>
                                    _deleteNotification(context, notifications, notification),
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

  Future<void> _loadNotifications(
    ValueNotifier<List<Map<String, dynamic>>> notifications,
  ) async {
    try {
      final data = await _notificationService.getNotifications();
      notifications.value = data;
    } catch (e) {
      debugPrint('Failed to load notifications: $e');
    }
  }

  Future<void> _clearAll(
    BuildContext context,
    ValueNotifier<List<Map<String, dynamic>>> notifications,
  ) async {
    try {
      await _notificationService.clearNotifications();
      notifications.value = [];
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to clear notifications: $e')),
        );
      }
    }
  }

  Future<void> _deleteNotification(
    BuildContext context,
    ValueNotifier<List<Map<String, dynamic>>> notifications,
    Map<String, dynamic> notification,
  ) async {
    final id = notification['id']?.toString();
    if (id == null || id.isEmpty) {
      return;
    }
    try {
      await _notificationService.deleteNotification(id);
      notifications.value =
          notifications.value.where((n) => n['id']?.toString() != id).toList();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete notification: $e')),
        );
      }
    }
  }

  Widget _alertItem(
    Color bg,
    IconData icon,
    String title,
    String subtitle,
    ThemeData theme, {
    required VoidCallback onDelete,
  }) {
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
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_forever_outlined),
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}
