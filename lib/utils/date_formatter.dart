import 'dart:ui';

class DateFormatter {
  static const _monthsGenitiveRu = [
    'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
    'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
  ];
  static const _monthsGenitiveEn = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  static const _weekdaysRu = [
    'Понедельник', 'Вторник', 'Среда', 'Четверг',
    'Пятница', 'Суббота', 'Воскресенье',
  ];
  static const _weekdaysEn = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday',
  ];
  static const _monthsNominativeRu = [
    'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
    'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь',
  ];
  static const _monthsNominativeEn = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static String formatFullDate(DateTime date, [Locale? locale]) {
    final isEn = locale?.languageCode == 'en';
    final weekdays = isEn ? _weekdaysEn : _weekdaysRu;
    final months = isEn ? _monthsGenitiveEn : _monthsGenitiveRu;
    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    final day = date.day;
    return '$weekday, $day $month';
  }

  static String formatMonthYear(DateTime date, [Locale? locale]) {
    final isEn = locale?.languageCode == 'en';
    final months = isEn ? _monthsNominativeEn : _monthsNominativeRu;
    return months[date.month - 1];
  }

  static String formatDayNumber(DateTime date) {
    return date.day.toString();
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static String? formatTimeFromMinutes(int? timeMinutes) {
    if (timeMinutes == null) return null;
    final h = timeMinutes ~/ 60;
    final m = timeMinutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  static String? formatTimeRangeFromMinutes(
    int? startMinutes,
    int? endMinutes,
  ) {
    if (startMinutes == null && endMinutes == null) return null;
    final start = formatTimeFromMinutes(startMinutes);
    final end = formatTimeFromMinutes(endMinutes);
    if (start != null && end != null) return '$start — $end';
    return start ?? end;
  }
}
