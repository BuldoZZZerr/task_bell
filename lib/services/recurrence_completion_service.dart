import 'package:hive/hive.dart';
import 'package:task_bell/database/hive_service.dart';
import 'package:task_bell/models/task.dart';

/// Выполненность повторяющихся задач по конкретным датам.
/// Для обычных (не повторяющихся) задач используется task.isDone.
class RecurrenceCompletionService {
  static String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static Box get _box => HiveService.recurrenceCompletionsBox;

  /// Выполнена ли задача на указанную дату.
  /// Для повторяющихся — по хранилищу по датам, для остальных — task.isDone.
  static bool isDoneForDate(Task task, DateTime date) {
    if (task.recurrence == 0) {
      return task.isDone;
    }
    return _box.get('${task.id}_${_dateKey(date)}') == true;
  }

  /// Отметить/снять выполненность на конкретную дату.
  /// Для повторяющихся — пишем в хранилище по дате, для обычных — обновляем task.isDone.
  static Future<void> setDoneForDate(
    Task task,
    DateTime date,
    bool done, {
    Future<void> Function(Task updated)? updateTask,
  }) async {
    if (task.recurrence == 0) {
      if (updateTask != null) {
        await updateTask(task.copyWith(isDone: done));
      }
      return;
    }
    final key = '${task.id}_${_dateKey(date)}';
    if (done) {
      await _box.put(key, true);
    } else {
      await _box.delete(key);
    }
  }
}
