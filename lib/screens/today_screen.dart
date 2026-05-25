import 'package:flutter/material.dart';
import 'package:task_bell/utils/date_formatter.dart';
import 'package:task_bell/localization/app_strings.dart';
import 'package:task_bell/widgets/task_card.dart';
import 'package:task_bell/widgets/birthday_card.dart';
import 'package:task_bell/screens/add_task_screen.dart';
import 'package:task_bell/services/task_service.dart';
import 'package:task_bell/services/birthday_service.dart';
import 'package:task_bell/database/hive_service.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  late DateTime _selectedDate;
  final TaskService _taskService = TaskService();
  final BirthdayService _birthdayService = BirthdayService();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  Future<void> _showAddTaskScreen() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(selectedDate: _selectedDate),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                DateFormatter.formatFullDate(_selectedDate, Localizations.localeOf(context)),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            // Birthdays + Tasks List
            Expanded(
              child: ListenableBuilder(
                listenable: HiveService.tasksAndBirthdaysListenable(),
                builder: (context, _) {
                  final birthdays =
                      _birthdayService.getBirthdaysForDate(_selectedDate);
                  final tasks = _taskService.getTasksForDate(_selectedDate);
                  if (tasks.isEmpty && birthdays.isEmpty) {
                    return Center(
                      child: Text(
                        AppStrings.of(context).noScheduleForDay,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    );
                  }
                  final itemCount = birthdays.length + tasks.length;
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      if (index < birthdays.length) {
                        final b = birthdays[index];
                        return BirthdayCard(
                          name: b.name,
                          note: b.note,
                          onHide: () async {
                            await _birthdayService.hideForYear(
                              b,
                              _selectedDate.year,
                            );
                          },
                        );
                      }
                      final task = tasks[index - birthdays.length];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Dismissible(
                            key: Key(task.id),
                            direction: DismissDirection.endToStart,
                            background: const SizedBox.expand(),
                            onDismissed: (_) =>
                                _taskService.deleteTask(task.id),
                            child: TaskCard(
                              margin: EdgeInsets.zero,
                              subject: task.subject,
                              description: task.description,
                              homework: task.homework ?? '',
                              isDone: task.isDone,
                              timeText:
                                  DateFormatter.formatTimeRangeFromMinutes(
                                task.timeMinutes,
                                task.endTimeMinutes,
                              ),
                              onToggleDone: () async {
                                final updated =
                                    task.copyWith(isDone: !task.isDone);
                                await _taskService.updateTask(
                                  updated,
                                  syncReminder: false,
                                );
                              },
                              onHomeworkChanged: (text) async {
                                await _taskService.updateTask(
                                  task.copyWith(homework: text),
                                  syncReminder: false,
                                );
                              },
                              onEdit: () {
                                Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddTaskScreen(
                                      selectedDate: _selectedDate,
                                      existingTask: task,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskScreen,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
