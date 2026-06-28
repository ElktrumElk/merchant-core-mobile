import 'package:flutter/material.dart';

class UserDetails extends StatelessWidget {
  const UserDetails({super.key});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Icon(Icons.supervised_user_circle_rounded, size: 40, color: theme.colorScheme.primary),
          const SizedBox(width: 20,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Elkanah Cole', style: TextStyle(color: theme.colorScheme.onSurface)),
              Text('festinacole373@gmail.com', style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150)),)
            ],
          )
        ],  
      ),
    );
  }
}