import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:task_bell/theme/app_theme.dart';
import 'package:task_bell/screens/today_screen.dart';
import 'package:task_bell/screens/week_screen.dart';
import 'package:task_bell/screens/calendar_screen.dart';
import 'package:task_bell/screens/settings_screen.dart';
import 'package:task_bell/widgets/bottom_navigation.dart';
import 'package:task_bell/widgets/optimized_background_image.dart';
import 'package:task_bell/database/hive_service.dart';
import 'package:task_bell/services/theme_service.dart';
import 'package:task_bell/services/locale_service.dart';
import 'package:task_bell/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final imageCache = PaintingBinding.instance.imageCache;
  imageCache.maximumSize = 20;
  imageCache.maximumSizeBytes = 20 << 20;
  await HiveService.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    LocaleService.localeNotifier.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    LocaleService.localeNotifier.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LocaleService.localeNotifier,
      builder: (context, locale, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: ThemeService.isDarkTheme,
          builder: (context, isDark, _) {
            return MaterialApp(
              title: 'Task Bell',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
              locale: locale,
              supportedLocales: const [
                Locale('ru'),
                Locale('en'),
              ],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              debugShowCheckedModeBanner: false,
              home: const MainScreen(),
            );
          },
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  static const List<String> _backgroundLight = [
    'assets/bgs/light/today_light.png',
    'assets/bgs/light/week_light.png',
    'assets/bgs/light/calendar_light.png',
    'assets/bgs/light/settings_light.png',
  ];
  static const List<String> _backgroundDark = [
    'assets/bgs/dark/today_dark.png',
    'assets/bgs/dark/week_dark.png',
    'assets/bgs/dark/calendar_dark.png',
    'assets/bgs/dark/settings_dark.png',
  ];

  String? _lastPrecachedPath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _precacheCurrentBackground();
      _bootstrapNotificationsLater();
    });
    ThemeService.isDarkTheme.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    ThemeService.isDarkTheme.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (!mounted) return;
    _precacheCurrentBackground();
  }

  void _bootstrapNotificationsLater() {
    Future<void>.delayed(const Duration(seconds: 5), () async {
      try {
        await NotificationService.instance.init();
        await NotificationService.instance.rescheduleAllIfNeeded();
      } catch (e, st) {
        debugPrint('Notification bootstrap failed: $e\n$st');
      }
    });
  }

  void _precacheCurrentBackground() {
    if (!mounted) return;
    final isDark = ThemeService.isDarkTheme.value;
    final path = isDark
        ? _backgroundDark[_currentIndex]
        : _backgroundLight[_currentIndex];
    if (_lastPrecachedPath == path) return;
    _lastPrecachedPath = path;
    precacheImage(
      OptimizedBackgroundImage.resizedProvider(context, path),
      context,
    );
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _precacheCurrentBackground();
    });
  }

  Widget _screenForIndex(int index) {
    switch (index) {
      case 0:
        return const TodayScreen();
      case 1:
        return const WeekScreen();
      case 2:
        return const CalendarScreen();
      case 3:
        return const SettingsScreen();
      default:
        return const TodayScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService.isDarkTheme,
      builder: (context, isDark, _) {
        final bgAsset = isDark
            ? _backgroundDark[_currentIndex]
            : _backgroundLight[_currentIndex];
        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              RepaintBoundary(
                child: OptimizedBackgroundImage(assetPath: bgAsset),
              ),
              _screenForIndex(_currentIndex),
            ],
          ),
          bottomNavigationBar: AppBottomNavigation(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
          ),
        );
      },
    );
  }
}
