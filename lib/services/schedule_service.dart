import 'dart:convert';
import 'package:task_bell/database/hive_service.dart';
import 'package:task_bell/models/schedule_slot.dart';
import 'package:task_bell/models/task.dart';
import 'package:task_bell/services/task_service.dart';

class ScheduleService {
  static const String _keyTemplate = 'schedule_template';
  static const String _scheduleTaskIdPrefix = 'schedule_';

  static List<ScheduleSlot> getTemplate() {
    try {
      final json = HiveService.settingsBox.get(_keyTemplate);
      if (json == null) return [];
      final list = json is String ? jsonDecode(json) as List : json as List;
      return list
          .map((e) => ScheduleSlot.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveTemplate(List<ScheduleSlot> slots) async {
    final list = slots.map((e) => e.toJson()).toList();
    await HiveService.settingsBox.put(_keyTemplate, jsonEncode(list));
  }

  /// Удаляет все задачи, созданные из расписания (id начинается с schedule_).
  static Future<void> _removeScheduleTasks() async {
    final box = HiveService.tasksBox;
    final toRemove = box.values
        .where((t) => t.id.startsWith(_scheduleTaskIdPrefix))
        .map((t) => t.id)
        .toList();
    for (final id in toRemove) {
      await box.delete(id);
    }
  }

  /// Понедельник текущей недели (дата без времени).
  static DateTime _mondayOfWeek(DateTime date) {
    final weekday = date.weekday;
    final diff = weekday == 1 ? 0 : weekday - 1;
    return DateTime(date.year, date.month, date.day - diff);
  }

  /// Создаёт еженедельные задачи из шаблона расписания.
  /// Сначала удаляет старые задачи расписания.
  static Future<void> applySchedule() async {
    await _removeScheduleTasks();
    final slots = getTemplate();
    if (slots.isEmpty) return;

    final taskService = TaskService();
    final refMonday = _mondayOfWeek(DateTime.now());

    for (final slot in slots) {
      if (slot.subject.trim().isEmpty) continue;
      final date = refMonday.add(Duration(days: slot.weekday - 1));
      final id = '$_scheduleTaskIdPrefix${slot.weekday}_${slot.startMinutes}_${slot.subject.hashCode.abs()}';
      final task = Task(
        id: id,
        subject: slot.subject.trim(),
        description: '',
        date: date,
        timeMinutes: slot.startMinutes,
        endTimeMinutes: slot.endMinutes,
        recurrence: 2,
        recurrenceWeekdays: [slot.weekday],
      );
      await taskService.addTask(task);
    }
  }

  static bool hasScheduleTasks() {
    return HiveService.tasksBox.values
        .any((t) => t.id.startsWith(_scheduleTaskIdPrefix));
  }
}
