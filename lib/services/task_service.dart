import 'package:hive/hive.dart';
import 'package:task_bell/models/task.dart';
import 'package:task_bell/utils/date_formatter.dart';
import 'package:task_bell/database/hive_service.dart';

class TaskService {
  static final TaskService _instance = TaskService._internal();
  factory TaskService() => _instance;
  TaskService._internal();

  Box<Task> get _tasksBox => HiveService.tasksBox;

  List<Task> get tasks {
    return _tasksBox.values.toList();
  }

  Future<void> addTask(Task task) async {
    await _tasksBox.put(task.id, task);
  }

  Future<void> updateTask(Task updatedTask) async {
    await _tasksBox.put(updatedTask.id, updatedTask);
  }

  Future<void> deleteTask(String taskId) async {
    await _tasksBox.delete(taskId);
  }

  bool _matchesRecurrence(Task task, DateTime date) {
    // обычная задача на конкретный день
    if (DateFormatter.isSameDay(task.date, date)) {
      return true;
    }

    // повторяющиеся задачи начинаются не позже указанной даты
    if (date.isBefore(DateTime(task.date.year, task.date.month, task.date.day))) {
      return false;
    }

    switch (task.recurrence) {
      case 1: // каждый день, начиная с task.date
        return true;
      case 2: // каждую неделю
        // если явно указаны дни недели — используем их
        if (task.recurrenceWeekdays.isNotEmpty) {
          return task.recurrenceWeekdays.contains(date.weekday);
        }
        // иначе повторяем в тот же день недели, что и стартовая дата
        return date.weekday == task.date.weekday;
      case 3: // раз в месяц, в тот же день месяца
        return date.day == task.date.day;
      case 4: // раз в год, в тот же день и месяц
        return date.day == task.date.day && date.month == task.date.month;
      default:
        return false;
    }
  }

  List<Task> getTasksForDate(DateTime date) {
    final list = _tasksBox.values.where((task) {
      return _matchesRecurrence(task, date);
    }).toList();
    list.sort((a, b) {
      final aTime = a.timeMinutes ?? 9999;
      final bTime = b.timeMinutes ?? 9999;
      return aTime.compareTo(bTime);
    });
    return list;
  }

  List<Task> getTasksForWeek(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    return _tasksBox.values.where((task) {
      // если задача попадает хотя бы в один день недели по дате или повторяемости
      for (int i = 0; i < 7; i++) {
        final day = weekStart.add(Duration(days: i));
        if (day.isAfter(weekEnd)) break;
        if (_matchesRecurrence(task, day)) return true;
      }
      return false;
    }).toList();
  }

  Task? getTaskById(String id) {
    return _tasksBox.get(id);
  }
}

