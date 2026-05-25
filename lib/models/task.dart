import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String subject;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final DateTime date;
  
  @HiveField(4)
  final int priority; // 0 = green, 1 = yellow, 2 = orange, 3 = red
  
  @HiveField(5)
  final List<String> subtasks;

  @HiveField(6)
  final bool isDone;

  @HiveField(7)
  final int? timeMinutes; // 0-1439 (00:00-23:59), null = no time set

  @HiveField(8)
  final String? homework; // домашнее задание (отдельно от description)

  @HiveField(9)
  final int? endTimeMinutes; // окончание урока, минуты с полуночи

  /// Периодичность задачи:
  /// 0 - без повтора
  /// 1 - каждый день
  /// 2 - каждую неделю
  @HiveField(10)
  final int recurrence;

  /// Дни недели, по которым повторяется задача (1-7, как DateTime.weekday).
  /// Используется, когда recurrence == 2 (каждую неделю).
  @HiveField(11)
  final List<int> recurrenceWeekdays;

  /// Включено ли напоминание для задачи.
  @HiveField(12, defaultValue: false)
  final bool reminderEnabled;

  /// 0 — за N минут до начала, 1 — в указанное время.
  @HiveField(13, defaultValue: 0)
  final int reminderMode;

  /// За сколько минут до начала (если reminderMode == 0).
  @HiveField(14, defaultValue: 15)
  final int reminderOffsetMinutes;

  /// Во сколько напомнить, минуты с полуночи (если reminderMode == 1).
  @HiveField(15)
  final int? reminderAtMinutes;

  Task({
    required this.id,
    required this.subject,
    required this.description,
    required this.date,
    this.priority = 0,
    List<String>? subtasks,
    this.isDone = false,
    this.timeMinutes,
    this.endTimeMinutes,
    this.homework,
    this.recurrence = 0,
    List<int>? recurrenceWeekdays,
    this.reminderEnabled = false,
    this.reminderMode = 0,
    this.reminderOffsetMinutes = 15,
    this.reminderAtMinutes,
  })  : subtasks = subtasks ?? [],
        recurrenceWeekdays = recurrenceWeekdays ?? const [];

  static const _omit = Object();

  Task copyWith({
    String? id,
    String? subject,
    String? description,
    DateTime? date,
    int? priority,
    List<String>? subtasks,
    bool? isDone,
    Object? timeMinutes = _omit,
    Object? endTimeMinutes = _omit,
    Object? homework = _omit,
    int? recurrence,
    List<int>? recurrenceWeekdays,
    bool? reminderEnabled,
    int? reminderMode,
    int? reminderOffsetMinutes,
    Object? reminderAtMinutes = _omit,
  }) {
    return Task(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      date: date ?? this.date,
      priority: priority ?? this.priority,
      subtasks: subtasks ?? this.subtasks,
      isDone: isDone ?? this.isDone,
      timeMinutes: timeMinutes == _omit ? this.timeMinutes : timeMinutes as int?,
      endTimeMinutes: endTimeMinutes == _omit ? this.endTimeMinutes : endTimeMinutes as int?,
      homework: homework == _omit ? this.homework : homework as String?,
      recurrence: recurrence ?? this.recurrence,
      recurrenceWeekdays: recurrenceWeekdays ?? this.recurrenceWeekdays,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderMode: reminderMode ?? this.reminderMode,
      reminderOffsetMinutes: reminderOffsetMinutes ?? this.reminderOffsetMinutes,
      reminderAtMinutes: reminderAtMinutes == _omit
          ? this.reminderAtMinutes
          : reminderAtMinutes as int?,
    );
  }
}
