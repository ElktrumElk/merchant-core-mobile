import 'package:first_flutter_project/components/settings/userDetails.dart';
import 'package:first_flutter_project/global/theme_notifier.dart';
import 'package:flutter/material.dart';

class SettingPanel {
  ValueNotifier<IconData> getNotifications = ValueNotifier<IconData>(
    Icons.toggle_on,
  );

  void showSettingPanel(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      showDragHandle: true,
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text('Settings', style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.onSurface)),
                ],
              ),
              const SizedBox(height: 20,),
              UserDetails(),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade100,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.dark_mode, color: themeNotifier.isDarkMode ? Colors.grey : Colors.grey),
                    const SizedBox(width: 10),
                    Text('Dark Mode', style: TextStyle(fontSize: 17, color: Theme.of(context).colorScheme.onSurface)),
                    const Spacer(),
                    ValueListenableBuilder<ThemeMode>(
                      valueListenable: themeNotifier,
                      builder: (context, mode, _) {
                        return IconButton(
                          onPressed: () {
                            themeNotifier.toggle();
                          },
                          icon: Icon(
                            mode == ThemeMode.dark ? Icons.toggle_on : Icons.toggle_off_outlined,
                          ),
                          iconSize: 50,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade100,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.notifications, color: Colors.grey),
                    const SizedBox(width: 10),
                    Text(
                      'Get Notifications',
                      style: TextStyle(fontSize: 17, color: Theme.of(context).colorScheme.onSurface),
                    ),
                    const Spacer(),
                    ListenableBuilder(
                      listenable: getNotifications,
                      builder: (context, _) {
                        return IconButton(
                          onPressed: () {
                            if (getNotifications.value == Icons.toggle_off_outlined) {
                              getNotifications.value = Icons.toggle_on;
                            } else {
                              getNotifications.value = Icons.toggle_off_outlined;
                            }
                          },
                          icon: Icon(getNotifications.value, color: Colors.blue,),
                          iconSize: 50,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
