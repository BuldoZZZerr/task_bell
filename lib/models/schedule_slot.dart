/// Один урок в шаблоне недельного расписания.
/// weekday: 1 = понедельник, 7 = воскресенье.
class ScheduleSlot {
  final int weekday;
  final int startMinutes;
  final int endMinutes;
  final String subject;

  const ScheduleSlot({
    required this.weekday,
    required this.startMinutes,
    required this.endMinutes,
    required this.subject,
  });

  Map<String, dynamic> toJson() => {
        'weekday': weekday,
        'startMinutes': startMinutes,
        'endMinutes': endMinutes,
        'subject': subject,
      };

  static ScheduleSlot fromJson(Map<String, dynamic> json) {
    return ScheduleSlot(
      weekday: json['weekday'] as int,
      startMinutes: json['startMinutes'] as int,
      endMinutes: json['endMinutes'] as int,
      subject: json['subject'] as String? ?? '',
    );
  }
}
