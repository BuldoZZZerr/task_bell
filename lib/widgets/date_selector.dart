import 'package:flutter/material.dart';
import 'package:task_bell/theme/app_theme.dart';
import 'package:task_bell/utils/date_formatter.dart';

class DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final List<DateTime> dates;
  final VoidCallback? onPreviousWeek;
  final VoidCallback? onNextWeek;

  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.dates,
    this.onPreviousWeek,
    this.onNextWeek,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPreviousWeek,
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dates.length,
              itemBuilder: (context, index) {
                final date = dates[index];
                final isSelected = DateFormatter.isSameDay(date, selectedDate);
                final isToday = DateFormatter.isSameDay(
                  date,
                  DateTime.now(),
                );

                return GestureDetector(
                  onTap: () => onDateSelected(date),
                  child: Container(
                    width: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryGreen
                          : isToday
                              ? AppTheme.lightPink
                              : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        DateFormatter.formatDayNumber(date),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onNextWeek,
          ),
        ],
      ),
    );
  }
}
