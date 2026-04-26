import 'package:flutter/material.dart';
import 'package:task_bell/database/hive_service.dart';

class ThemeService {
  static const String _keyDarkTheme = 'isDarkTheme';

  static final ValueNotifier<bool> isDarkTheme = ValueNotifier<bool>(_loadDarkTheme());

  static bool _loadDarkTheme() {
    try {
      return HiveService.settingsBox.get(_keyDarkTheme, defaultValue: false) as bool;
    } catch (_) {
      return false;
    }
  }

  static bool get darkTheme => isDarkTheme.value;

  static Future<void> setDarkTheme(bool value) async {
    if (isDarkTheme.value == value) return;
    isDarkTheme.value = value;
    await HiveService.settingsBox.put(_keyDarkTheme, value);
  }

  static ThemeMode get themeMode => isDarkTheme.value ? ThemeMode.dark : ThemeMode.light;
}
