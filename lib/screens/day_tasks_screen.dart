import 'package:flutter/material.dart';
import 'package:task_bell/utils/date_formatter.dart';
import 'package:task_bell/widgets/task_card.dart';
import 'package:task_bell/widgets/birthday_card.dart';
import 'package:task_bell/screens/add_task_screen.dart';
import 'package:task_bell/services/task_service.dart';
import 'package:task_bell/services/birthday_service.dart';
import 'package:task_bell/services/recurrence_completion_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_bell/database/hive_service.dart';
import 'package:task_bell/localization/app_strings.dart';

class DayTasksScreen extends StatelessWidget {
  final DateTime selectedDate;

  const DayTasksScreen({
    super.key,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final taskService = TaskService();
     final birthdayService = BirthdayService();
    final formattedDate = DateFormatter.formatFullDate(selectedDate, Localizations.localeOf(context));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          formattedDate,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: HiveService.birthdaysBox.listenable(),
        builder: (context, birthdaysBox, _) {
          final birthdays =
              birthdayService.getBirthdaysForDate(selectedDate);
          return ValueListenableBuilder(
            valueListenable: HiveService.tasksBox.listenable(),
            builder: (context, tasksBox, _) {
              return ValueListenableBuilder(
                valueListenable: HiveService.recurrenceCompletionsBox.listenable(),
                builder: (context, completionsBox, _) {
                  final tasks = taskService.getTasksForDate(selectedDate);

                  if (tasks.isEmpty && birthdays.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_note,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppStrings.of(context).noScheduleForDay,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.only(bottom: 80),
                    children: [
                      for (final b in birthdays)
                        BirthdayCard(
                          name: b.name,
                          note: b.note,
                          onHide: () async {
                            await birthdayService.hideForYear(
                              b,
                              selectedDate.year,
                            );
                          },
                          onNoteChanged: (text) async {
                            await birthdayService.updateBirthday(
                              b.copyWith(note: text.isEmpty ? null : text),
                            );
                          },
                        ),
                      for (final task in tasks)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Dismissible(
                              key: Key(task.id),
                              direction: DismissDirection.endToStart,
                              background: const SizedBox.expand(),
                            onDismissed: (_) =>
                                taskService.deleteTask(task.id),
                            child: TaskCard(
                              margin: EdgeInsets.zero,
                            subject: task.subject,
                            description: task.description,
                            homework: task.homework ?? '',
                            isDone: RecurrenceCompletionService.isDoneForDate(task, selectedDate),
                            timeText: DateFormatter.formatTimeRangeFromMinutes(
                              task.timeMinutes,
                              task.endTimeMinutes,
                            ),
                            onToggleDone: () async {
                              final nowDone = RecurrenceCompletionService.isDoneForDate(task, selectedDate);
                              await RecurrenceCompletionService.setDoneForDate(
                                task,
                                selectedDate,
                                !nowDone,
                                updateTask: taskService.updateTask,
                              );
                            },
                            onHomeworkChanged: (text) async {
                              final updated = task.copyWith(homework: text);
                              await taskService.updateTask(updated);
                            },
                            onEdit: () async {
                              final result = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddTaskScreen(
                                    selectedDate: selectedDate,
                                    existingTask: task,
                                  ),
                                ),
                              );
                              if (result == true && context.mounted) {}
                            },
                          ),
                        ),
                        ),
                        ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => AddTaskScreen(selectedDate: selectedDate),
            ),
          );
          if (result == true && context.mounted) {
            // Обновление произойдет автоматически через ValueListenableBuilder
          }
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
