import 'package:flutter/material.dart';
import 'package:task_bell/screens/birthdays_screen.dart';
import 'package:task_bell/screens/schedule_screen.dart';
import 'package:task_bell/services/theme_service.dart';
import 'package:task_bell/services/locale_service.dart';
import 'package:task_bell/localization/app_strings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    ThemeService.isDarkTheme.addListener(_onThemeChanged);
    LocaleService.localeNotifier.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    ThemeService.isDarkTheme.removeListener(_onThemeChanged);
    LocaleService.localeNotifier.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onThemeChanged() => setState(() {});
  void _onLocaleChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = AppStrings.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          s.settings,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        children: [
          _SettingsTile(
            leading: Icon(Icons.calendar_view_week, color: theme.iconTheme.color),
            title: Text(s.addSchedule),
            trailing: Icon(Icons.chevron_right, color: theme.iconTheme.color),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ScheduleScreen(),
                ),
              );
            },
          ),
          _SettingsTile(
            leading: Icon(Icons.language, color: theme.iconTheme.color),
            title: Text(s.language),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LocaleService.locale.languageCode == LocaleService.en
                      ? s.languageEnglish
                      : s.languageRussian,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: theme.iconTheme.color),
              ],
            ),
            onTap: () => _showLanguageDialog(context, s),
          ),
          _SettingsTile(
            leading: Icon(Icons.cake, color: theme.iconTheme.color),
            title: Text(s.birthdays),
            trailing: Icon(Icons.chevron_right, color: theme.iconTheme.color),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const BirthdaysScreen(),
                ),
              );
            },
          ),
          _SettingsTile(
            leading: Icon(Icons.dark_mode, color: theme.iconTheme.color),
            title: Text(s.darkTheme),
            trailing: Switch(
              value: ThemeService.darkTheme,
              onChanged: (value) => ThemeService.setDarkTheme(value),
            ),
            onTap: () => ThemeService.setDarkTheme(!ThemeService.darkTheme),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, AppStrings s) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(s.languageRussian),
              leading: Icon(
                Icons.check,
                color: LocaleService.locale.languageCode == LocaleService.ru
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
              ),
              onTap: () async {
                await LocaleService.setRussian();
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text(s.languageEnglish),
              leading: Icon(
                Icons.check,
                color: LocaleService.locale.languageCode == LocaleService.en
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
              ),
              onTap: () async {
                await LocaleService.setEnglish();
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Пункт настроек фиксированной высоты для одинакового размера всех вкладок.
class _SettingsTile extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.leading,
    required this.title,
    required this.trailing,
    this.onTap,
  });

  static const double _tileHeight = 56;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _tileHeight,
      child: ListTile(
        leading: leading,
        title: title,
        trailing: trailing,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      ),
    );
  }
}
