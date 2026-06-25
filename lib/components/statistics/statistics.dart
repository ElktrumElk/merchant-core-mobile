import 'package:flutter/material.dart';

class Statistics extends StatelessWidget {
  const Statistics({
    super.key,
    required this.title,
    required this.value,
    this.color = Colors.black,
    this.info = '',
    this.iconColor = Colors.black,
    this.iconUrl = 'assets/icons/dollar.png',
    this.infoColor = Colors.black,
  });

  final String title;
  final String value;
  final Color? color;
  final String? info;
  final Color? infoColor;
  final Color? iconColor;
  final String? iconUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150.0,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Color(0xFFEAEAEA), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(90),
            blurRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
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
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
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
    );
  }
}
