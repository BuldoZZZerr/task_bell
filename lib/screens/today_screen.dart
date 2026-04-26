import 'package:flutter/material.dart';
import 'package:task_bell/utils/date_formatter.dart';
import 'package:task_bell/localization/app_strings.dart';
import 'package:task_bell/widgets/task_card.dart';
import 'package:task_bell/widgets/birthday_card.dart';
import 'package:task_bell/screens/add_task_screen.dart';
import 'package:task_bell/services/task_service.dart';
import 'package:task_bell/services/birthday_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(selectedDate: _selectedDate),
      ),
    );

    if (result == true && mounted) {
      setState(() {});
    }
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
              child: ValueListenableBuilder(
                valueListenable: HiveService.birthdaysBox.listenable(),
                builder: (context, _, _) {
                  final birthdays =
                      _birthdayService.getBirthdaysForDate(_selectedDate);
                  return ValueListenableBuilder(
                    valueListenable: HiveService.tasksBox.listenable(),
                    builder: (context, box, _) {
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
                      return ListView(
                        padding: const EdgeInsets.only(bottom: 80),
                        children: [
                          // Birthdays on top
                          for (final b in birthdays)
                            BirthdayCard(
                              name: b.name,
                              note: b.note,
                              onHide: () async {
                                await _birthdayService.hideForYear(
                                  b,
                                  _selectedDate.year,
                                );
                              },
                            ),
                          // Tasks
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
                                    _taskService.deleteTask(task.id),
                                child: TaskCard(
                                  margin: EdgeInsets.zero,
                              subject: task.subject,
                              description: task.description,
                              homework: task.homework ?? '',
                              isDone: task.isDone,
                              timeText: DateFormatter.formatTimeRangeFromMinutes(
                                task.timeMinutes,
                                task.endTimeMinutes,
                              ),
                              onToggleDone: () async {
                                final updated =
                                    task.copyWith(isDone: !task.isDone);
                                await _taskService.updateTask(updated);
                              },
                              onHomeworkChanged: (text) async {
                                final updated =
                                    task.copyWith(homework: text);
                                await _taskService.updateTask(updated);
                              },
                              onEdit: () async {
                                final result = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddTaskScreen(
                                      selectedDate: _selectedDate,
                                      existingTask: task,
                                    ),
                                  ),
                                );
                                if (result == true && mounted) {
                                  setState(() {});
                                }
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
