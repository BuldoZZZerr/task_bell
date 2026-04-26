import 'package:flutter/material.dart';
import 'package:task_bell/database/hive_service.dart';

class LocaleService {
  static const String _keyLocale = 'locale';
  static const String ru = 'ru';
  static const String en = 'en';

  static final ValueNotifier<Locale> localeNotifier = ValueNotifier<Locale>(_loadLocale());

  static Locale _loadLocale() {
    try {
      final code = HiveService.settingsBox.get(_keyLocale, defaultValue: ru) as String?;
      return code == en ? const Locale('en') : const Locale('ru');
    } catch (_) {
      return const Locale('ru');
    }
  }

  static Locale get locale => localeNotifier.value;

  static Future<void> setLocale(String languageCode) async {
    final newLocale = languageCode == en ? const Locale('en') : const Locale('ru');
    if (localeNotifier.value == newLocale) return;
    localeNotifier.value = newLocale;
    await HiveService.settingsBox.put(_keyLocale, languageCode);
  }

  static Future<void> setRussian() => setLocale(ru);
  static Future<void> setEnglish() => setLocale(en);
}
