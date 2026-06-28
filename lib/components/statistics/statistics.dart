import 'package:flutter/material.dart';

class Statistics extends StatelessWidget {
  const Statistics({
    super.key,
    required this.title,
    this.value,
    this.color = Colors.black,
    this.info = '',
    this.iconColor = Colors.black,
    this.iconUrl = 'assets/icons/dollar.png',
    this.infoColor = Colors.black,
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
    return Card(
      elevation: 5,
      color: Colors.white,
      child: Padding(padding: const EdgeInsetsGeometry.all(10), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header title and icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              Image.asset(
                iconUrl as String,
                width: 20,
                height: 20,
                color: iconColor,
              ),
            ],
          ),
          const SizedBox(height: 20),

          child ??
              // Value
              Text(
                value as String,
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
          if (info != '') const SizedBox(height: 20),
          Text(
            info as String,
            style: TextStyle(
              color: infoColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      )
    );
  }
}
