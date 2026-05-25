/// Один урок в шаблоне недельного расписания.
/// weekday: 1 = понедельник, 7 = воскресенье.
class ScheduleSlot {
  final int weekday;
  final int startMinutes;
  final int endMinutes;
  final String subject;
  final bool reminderEnabled;
  /// 0 — за N минут до начала, 1 — в указанное время.
  final int reminderMode;
  final int reminderOffsetMinutes;
  final int? reminderAtMinutes;

  const ScheduleSlot({
    required this.weekday,
    required this.startMinutes,
    required this.endMinutes,
    required this.subject,
    this.reminderEnabled = false,
    this.reminderMode = 0,
    this.reminderOffsetMinutes = 15,
    this.reminderAtMinutes,
  });

  ScheduleSlot copyWith({
    int? weekday,
    int? startMinutes,
    int? endMinutes,
    String? subject,
    bool? reminderEnabled,
    int? reminderMode,
    int? reminderOffsetMinutes,
    int? reminderAtMinutes,
    bool clearReminderAtMinutes = false,
  }) {
    return ScheduleSlot(
      weekday: weekday ?? this.weekday,
      startMinutes: startMinutes ?? this.startMinutes,
      endMinutes: endMinutes ?? this.endMinutes,
      subject: subject ?? this.subject,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderMode: reminderMode ?? this.reminderMode,
      reminderOffsetMinutes: reminderOffsetMinutes ?? this.reminderOffsetMinutes,
      reminderAtMinutes:
          clearReminderAtMinutes ? null : (reminderAtMinutes ?? this.reminderAtMinutes),
    );
  }

  Map<String, dynamic> toJson() => {
        'weekday': weekday,
        'startMinutes': startMinutes,
        'endMinutes': endMinutes,
        'subject': subject,
        'reminderEnabled': reminderEnabled,
        'reminderMode': reminderMode,
        'reminderOffsetMinutes': reminderOffsetMinutes,
        'reminderAtMinutes': reminderAtMinutes,
      };

  static ScheduleSlot fromJson(Map<String, dynamic> json) {
    return ScheduleSlot(
      weekday: json['weekday'] as int,
      startMinutes: json['startMinutes'] as int,
      endMinutes: json['endMinutes'] as int,
      subject: json['subject'] as String? ?? '',
      reminderEnabled: json['reminderEnabled'] as bool? ?? false,
      reminderMode: json['reminderMode'] as int? ?? 0,
      reminderOffsetMinutes: json['reminderOffsetMinutes'] as int? ?? 15,
      reminderAtMinutes: json['reminderAtMinutes'] as int?,
    );
  }
}
