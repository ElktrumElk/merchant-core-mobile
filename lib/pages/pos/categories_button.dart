import 'package:flutter/material.dart';

class CategoriesButton extends StatelessWidget {
  const CategoriesButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 50,
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children: [
              FilledButton(
                onPressed: () {},
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.transparent),
                  foregroundColor: WidgetStateProperty.all(theme.colorScheme.onSurface),
                  side: WidgetStateProperty.all(
                    BorderSide(color: theme.dividerColor),
                  ),
                ),
                child: Text('All'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
