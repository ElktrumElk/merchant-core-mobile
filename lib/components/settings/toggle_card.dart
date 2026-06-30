
import 'package:flutter/material.dart';

class ToggleCard extends StatelessWidget {

  final ValueNotifier<bool> _listenable;
  final String name;
  final IconData icon;
  const ToggleCard({super.key, required this.name, required this.icon, required this._listenable});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade100,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey),
            const SizedBox(width: 10),
            Text(
              name,
              style: TextStyle(fontSize: 17, color: Theme
                  .of(context)
                  .colorScheme
                  .onSurface),
            ),
            const Spacer(),
            ListenableBuilder(
              listenable: _listenable,
              builder: (context, _) {
                return IconButton(
                  onPressed: () {
                    _listenable.value = !_listenable.value;
                  },
                  icon: Icon(_listenable.value ? Icons.toggle_on : Icons.toggle_off_outlined, color: Color(0xFF000000),),
                  iconSize: 50,
                );
              },
            ),
          ],
        ),
      );
  }
}