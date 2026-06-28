import 'package:flutter/material.dart';

class Statistics extends StatelessWidget {
  const Statistics({
    super.key,
    required this.title,
    this.value,
    this.color,
    this.info = '',
    this.iconColor,
    this.iconUrl = 'assets/icons/dollar.png',
    this.infoColor,
    this.child,
  });

  final String title;
  final String? value;
  final Color? color;
  final String? info;
  final Color? infoColor;
  final Color? iconColor;
  final String? iconUrl;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      color: theme.cardColor,
      child: Padding(padding: const EdgeInsets.all(10), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withAlpha(180),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Image.asset(
                iconUrl as String,
                width: 20,
                height: 20,
                color: iconColor ?? theme.colorScheme.onSurface.withAlpha(150),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child ??
              Text(
                value as String,
                style: TextStyle(
                  color: color ?? theme.colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
          if (info != '') const SizedBox(height: 20),
          Text(
            info as String,
            style: TextStyle(
              color: infoColor ?? theme.colorScheme.onSurface.withAlpha(150),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      ),
    );
  }
}
