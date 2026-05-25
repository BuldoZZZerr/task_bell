import 'package:task_bell/models/task.dart';
import 'package:task_bell/utils/date_formatter.dart';

/// Проверка, попадает ли задача на указанный календарный день.
bool taskMatchesDate(Task task, DateTime date) {
  if (DateFormatter.isSameDay(task.date, date)) {
    return true;
  }

  final dateOnly = DateTime(date.year, date.month, date.day);
  final taskStart = DateTime(task.date.year, task.date.month, task.date.day);
  if (dateOnly.isBefore(taskStart)) {
    return false;
  }

  switch (task.recurrence) {
    case 1:
      return true;
    case 2:
      if (task.recurrenceWeekdays.isNotEmpty) {
        return task.recurrenceWeekdays.contains(date.weekday);
      }
      return date.weekday == task.date.weekday;
    case 3:
      return date.day == task.date.day;
    case 4:
      return date.day == task.date.day && date.month == task.date.month;
    default:
      return false;
  }
}

/// Дни в диапазоне [from, to], когда задача повторяется.
List<DateTime> taskOccurrenceDays(Task task, DateTime from, DateTime to) {
  final days = <DateTime>[];
  var cursor = DateTime(from.year, from.month, from.day);
  final end = DateTime(to.year, to.month, to.day);

  while (!cursor.isAfter(end)) {
    if (taskMatchesDate(task, cursor)) {
      days.add(cursor);
    }
    cursor = cursor.add(const Duration(days: 1));
  }
  return days;
}
