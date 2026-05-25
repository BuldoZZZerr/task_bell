import 'package:hive/hive.dart';
import 'package:task_bell/models/task.dart';
import 'package:task_bell/database/hive_service.dart';
import 'package:task_bell/services/notification_service.dart';
import 'package:task_bell/utils/task_recurrence.dart';

class TaskService {
  static final TaskService _instance = TaskService._internal();
  factory TaskService() => _instance;
  TaskService._internal();

  Box<Task> get _tasksBox => HiveService.tasksBox;

  List<Task> get tasks => _tasksBox.values.toList();

  Future<void> addTask(Task task, {bool syncReminder = true}) async {
    await _tasksBox.put(task.id, task);
    if (syncReminder) {
      await NotificationService.instance.syncTaskReminder(task);
    }
  }

  Future<void> updateTask(Task updatedTask, {bool syncReminder = true}) async {
    await _tasksBox.put(updatedTask.id, updatedTask);
    if (syncReminder) {
      await NotificationService.instance.syncTaskReminder(updatedTask);
    }
  }

  Future<void> deleteTask(String taskId) async {
    await NotificationService.instance.cancelTaskReminders(taskId);
    await _tasksBox.delete(taskId);
  }

  List<Task> getTasksForDate(DateTime date) {
    final list = <Task>[];
    for (final task in _tasksBox.values) {
      if (taskMatchesDate(task, date)) {
        list.add(task);
      }
    }
    list.sort((a, b) {
      final aTime = a.timeMinutes ?? 9999;
      final bTime = b.timeMinutes ?? 9999;
      return aTime.compareTo(bTime);
    });
    return list;
  }

  List<Task> getTasksForWeek(DateTime weekStart) {
    final weekDays = List.generate(
      7,
      (i) {
        final d = weekStart.add(Duration(days: i));
        return DateTime(d.year, d.month, d.day);
      },
    );
    final result = <Task>[];
    for (final task in _tasksBox.values) {
      for (final day in weekDays) {
        if (taskMatchesDate(task, day)) {
          result.add(task);
          break;
        }
      }
    }
    return result;
  }

  Task? getTaskById(String id) => _tasksBox.get(id);
}
