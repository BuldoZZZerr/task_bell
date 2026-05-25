import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_bell/models/task.dart';
import 'package:task_bell/models/birthday.dart';
import 'package:task_bell/models/future_idea.dart';

class HiveService {
  static const String _tasksBoxName = 'tasks';
  static const String _birthdaysBoxName = 'birthdays';
  static const String _ideasBoxName = 'future_ideas';
  static const String _settingsBoxName = 'settings';
  static const String _recurrenceCompletionsBoxName = 'recurrence_completions';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Регистрация адаптера Task
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskAdapter());
    }

    // Регистрация адаптера Birthday
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(BirthdayAdapter());
    }

    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(FutureIdeaAdapter());
    }
    
    // Открытие бокса для задач
    await Hive.openBox<Task>(_tasksBoxName);
    // Открытие бокса для дней рождения
    await Hive.openBox<Birthday>(_birthdaysBoxName);
    await Hive.openBox<FutureIdea>(_ideasBoxName);
    // Бокс настроек (тема и т.д.)
    await Hive.openBox(_settingsBoxName);
    // Выполненность повторяющихся задач по датам: ключ "taskId_yyyy-MM-dd"
    await Hive.openBox(_recurrenceCompletionsBoxName);
  }

  static Box<Task> get tasksBox => Hive.box<Task>(_tasksBoxName);

  static Box<Birthday> get birthdaysBox => Hive.box<Birthday>(_birthdaysBoxName);

  static Box<FutureIdea> get ideasBox => Hive.box<FutureIdea>(_ideasBoxName);

  static Box get settingsBox => Hive.box(_settingsBoxName);

  static Box get recurrenceCompletionsBox => Hive.box(_recurrenceCompletionsBoxName);

  /// Один listener вместо нескольких вложенных ValueListenableBuilder.
  static Listenable tasksAndBirthdaysListenable() => Listenable.merge([
        tasksBox.listenable(),
        birthdaysBox.listenable(),
      ]);

  static Listenable tasksBirthdaysCompletionsListenable() => Listenable.merge([
        tasksBox.listenable(),
        birthdaysBox.listenable(),
        recurrenceCompletionsBox.listenable(),
      ]);

  static Future<void> close() async {
    await Hive.close();
  }
}
