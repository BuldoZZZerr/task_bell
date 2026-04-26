import 'package:flutter/material.dart';
import 'package:task_bell/theme/app_theme.dart';
import 'package:task_bell/localization/app_strings.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: isDark ? 0.08 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryGreen,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: _buildIcon(context, Icons.calendar_today, 0),
            label: s.tabToday,
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(context, Icons.view_module, 1),
            label: s.tabWeek,
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(context, Icons.calendar_month, 2),
            label: s.tabCalendar,
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(context, Icons.settings, 3),
            label: s.tabSettings,
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(BuildContext context, IconData icon, int index) {
    final isSelected = currentIndex == index;
    if (index == 0 && isSelected) {
      // Иконка с галочкой для активного "Сегодня"
      return Stack(
        children: [
          Icon(icon, color: AppTheme.primaryGreen),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: AppTheme.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    }
    final theme = Theme.of(context);
    final unselected = theme.colorScheme.onSurfaceVariant;
    return Icon(icon, color: isSelected ? AppTheme.primaryGreen : unselected);
  }
}
