import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:task_bell/theme/app_theme.dart';
import 'package:task_bell/screens/today_screen.dart';
import 'package:task_bell/screens/week_screen.dart';
import 'package:task_bell/screens/calendar_screen.dart';
import 'package:task_bell/screens/settings_screen.dart';
import 'package:task_bell/widgets/bottom_navigation.dart';
import 'package:task_bell/database/hive_service.dart';
import 'package:task_bell/services/theme_service.dart';
import 'package:task_bell/services/locale_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

  final List<Widget> _screens = [
    const TodayScreen(),
    const WeekScreen(),
    const CalendarScreen(),
    const SettingsScreen(),
  ];

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

  bool _assetsPrecached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_assetsPrecached) return;
    _assetsPrecached = true;
    for (final path in _backgroundLight) {
      precacheImage(AssetImage(path), context);
    }
    for (final path in _backgroundDark) {
      precacheImage(AssetImage(path), context);
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService.isDarkTheme,
      builder: (context, isDark, _) {
        final bgAsset = isDark
            ? _backgroundDark[_currentIndex]
            : _backgroundLight[_currentIndex];
        final fallbackAsset = _currentIndex == 0
            ? (isDark ? _backgroundDark[1] : _backgroundLight[1])
            : null;
        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                bgAsset,
                key: ValueKey(bgAsset),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  if (fallbackAsset != null) {
                    return Image.asset(
                      fallbackAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
                      ),
                    );
                  }
                  return Container(
                    color: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
                  );
                },
              ),
              _screens[_currentIndex],
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
