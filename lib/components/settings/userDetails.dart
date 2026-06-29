import 'package:first_flutter_project/components/settings/user.dart';
import 'package:flutter/material.dart';

class UserDetails extends StatelessWidget {
  const UserDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasData = AuthUser.username.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Icon(
            Icons.supervised_user_circle_rounded,
            size: 40,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                hasData ? AuthUser.username : 'User',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              Text(
                hasData ? AuthUser.userEmail : 'email@example.com',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withAlpha(150),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
