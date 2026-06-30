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
    this.hero = false,
    this.heroValue,
  });

  final String title;
  final String? value;
  final Color? color;
  final String? info;
  final Color? infoColor;
  final Color? iconColor;
  final String? iconUrl;
  final Widget? child;
  final bool hero;
  final String? heroValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (hero) {
      return Card(
        elevation: 3,
        color: theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: theme.colorScheme.primary.withAlpha(50)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withAlpha(180),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                heroValue ?? value ?? '',
                style: TextStyle(
                  color: color ?? theme.colorScheme.primary,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              if (info != null && info!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.trending_up, size: 14, color: Colors.green[700]),
                      const SizedBox(width: 4),
                      Text(
                        info!,
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

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
          if (info != '')
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
