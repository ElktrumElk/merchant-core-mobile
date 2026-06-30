import 'package:first_flutter_project/module/storage/device_storage.dart';
import 'package:flutter/material.dart';

class ThemeNotifier extends ValueNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light);

  Future<void> init() async {
    DeviceStorage.setKey('colorMode');
    final saved = await DeviceStorage.loadValue('colorMode');
    if (saved == 'true') {
      value = ThemeMode.dark;
    }
  }

  Future<void> toggle() async {
    value = value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    DeviceStorage.setKey('colorMode');
    await DeviceStorage.saveValue(value.isDark.toString());
  }

  bool get isDarkMode => value == ThemeMode.dark;
}

final themeNotifier = ThemeNotifier();
