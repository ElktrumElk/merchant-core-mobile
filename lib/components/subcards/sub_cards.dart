import 'package:flutter/material.dart';

class SubCards extends StatelessWidget {
  const SubCards({super.key, this.title = '', this.widget, this.trailing});

  final String title;
  final Widget? widget;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border.all(color: theme.dividerColor, width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: theme.dividerColor)),
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                ?trailing,
              ],
            ),
          ),
          if (widget != null) ...[
            const SizedBox(height: 8),
            widget!,
          ],
        ],
      ),
    );
  }
}
