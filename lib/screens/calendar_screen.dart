import 'package:flutter/material.dart';
import 'package:task_bell/theme/app_theme.dart';
import 'package:task_bell/utils/date_formatter.dart';
import 'package:task_bell/localization/app_strings.dart';
import 'package:task_bell/screens/day_tasks_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selectedMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    _selectedDate = DateTime.now();
  }

  Future<void> _showDayTasksScreen(DateTime date) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DayTasksScreen(selectedDate: date),
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
      );
    });
  }

  List<DateTime> _getDaysInMonth() {
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final firstDayOfWeek = firstDay.weekday % 7; // 0 = Sunday

    final days = <DateTime>[];

    // Add days from previous month
    if (firstDayOfWeek > 0) {
      final previousMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
      );
      final lastDayOfPreviousMonth =
          DateTime(previousMonth.year, previousMonth.month + 1, 0).day;
      for (int i = firstDayOfWeek - 1; i >= 0; i--) {
        days.add(DateTime(
          previousMonth.year,
          previousMonth.month,
          lastDayOfPreviousMonth - i,
        ));
      }
    }

    // Add days from current month
    for (int day = 1; day <= lastDay.day; day++) {
      days.add(DateTime(_selectedMonth.year, _selectedMonth.month, day));
    }

    // Add days from next month to complete the grid
    final remainingDays = 42 - days.length; // 6 weeks * 7 days
    for (int day = 1; day <= remainingDays; day++) {
      days.add(DateTime(_selectedMonth.year, _selectedMonth.month + 1, day));
    }

    return days;
  }

  @override
  Widget build(BuildContext context) {
    final days = _getDaysInMonth();
    final s = AppStrings.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Header with month/year
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _previousMonth,
                      ),
                      Text(
                        DateFormatter.formatMonthYear(_selectedMonth, Localizations.localeOf(context)),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_up),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedMonth,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            initialDatePickerMode: DatePickerMode.year,
                          );
                          if (picked != null && mounted) {
                            setState(() {
                              _selectedMonth = DateTime(picked.year, picked.month);
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        _selectedMonth.year.toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _nextMonth,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Weekday headers
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: s.weekdayShort
                    .map(
                      (day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 8),
            // Calendar grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1,
                  ),
                  itemCount: days.length,
                  itemBuilder: (context, index) {
                    final day = days[index];
                    final isCurrentMonthDay =
                        day.month == _selectedMonth.month;
                    final isSelected = _selectedDate != null &&
                        DateFormatter.isSameDay(day, _selectedDate!);
                    final isToday = isCurrentMonthDay &&
                        DateFormatter.isSameDay(day, DateTime.now());

                    return GestureDetector(
                      onTap: () {
                        if (isCurrentMonthDay) {
                          setState(() {
                            _selectedDate = day;
                          });
                          // Show day tasks screen
                          _showDayTasksScreen(day);
                        } else {
                          // Navigate to that month
                          setState(() {
                            _selectedMonth = DateTime(day.year, day.month);
                            _selectedDate = day;
                          });
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryGreen.withValues(alpha: 0.2)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color: AppTheme.primaryGreen,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            day.day.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              color: isCurrentMonthDay
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Colors.grey,
                              fontWeight: isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
