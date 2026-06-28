import 'package:first_flutter_project/components/settings/userDetails.dart';
import 'package:flutter/material.dart';

class SettingPanel {
  ValueNotifier<IconData> colorModeIcon = ValueNotifier<IconData>(
    Icons.toggle_off_outlined,
  );

  ValueNotifier<IconData> getNotifications = ValueNotifier<IconData>(
    Icons.toggle_on,
  );

  void showSettingPanel(BuildContext context) {
    showModalBottomSheet(
      showDragHandle: true,
      context: context,
      builder: (context) {
        return ListenableBuilder(
          listenable: colorModeIcon,
          builder: (context, _) {
            return Container(
              padding: const EdgeInsets.all(20),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Text('Settings', style: TextStyle(fontSize: 20)),
                    ],
                  ),
                  const SizedBox(height: 20,),
                  UserDetails(),
                  const SizedBox(height: 10),
                  // body
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.dark_mode, color: Colors.grey),
                        const SizedBox(width: 10),
                        Text('Dark Mode', style: TextStyle(fontSize: 17)),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            if (colorModeIcon.value ==
                                Icons.toggle_off_outlined) {
                              colorModeIcon.value = Icons.toggle_on;
                            } else {
                              colorModeIcon.value = Icons.toggle_off_outlined;
                            }
                          },
                          icon: Icon(colorModeIcon.value),
                          iconSize: 50,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.notifications, color: Colors.grey),
                        const SizedBox(width: 10),
                        Text(
                          'Get Notifications',
                          style: TextStyle(fontSize: 17),
                        ),
                        const Spacer(),

                        ListenableBuilder(
                          listenable: getNotifications,
                          builder: (context, _) {
                            return IconButton(
                              onPressed: () {
                                if (getNotifications.value ==
                                    Icons.toggle_off_outlined) {
                                  getNotifications.value = Icons.toggle_on;
                                } else {
                                  getNotifications.value =
                                      Icons.toggle_off_outlined;
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
      },
    );
  }
}
