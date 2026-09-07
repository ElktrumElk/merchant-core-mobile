import 'dart:async';

import 'package:flutter/material.dart';

class AppToast {
  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;

  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.of(context);
    final overlayState = _currentEntry;
    if (overlayState != null && overlayState.mounted) {
      _dismissTimer?.cancel();
      overlayState.remove();
    }

    final entry = OverlayEntry(
      builder: (context) => _ToastWidget(message: message, isError: isError),
    );

    _currentEntry = entry;
    overlay.insert(entry);

    _dismissTimer = Timer(duration, () {
      if (entry.mounted) {
        entry.remove();
      }
      if (_currentEntry == entry) {
        _currentEntry = null;
      }
    });
  }
}

class _ToastWidget extends StatelessWidget {
  const _ToastWidget({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? Colors.red.shade700 : Color(0xFF323232);
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      left: 24,
      right: 24,
      top: topPadding + 12,
      child: IgnorePointer(
        child: Material(
          color: color,
          elevation: 6,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withAlpha(60),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isError ? Icons.error_outline : Icons.check_circle,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
