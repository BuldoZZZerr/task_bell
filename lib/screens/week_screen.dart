import 'package:flutter/material.dart';
import 'package:task_bell/widgets/task_card.dart';
import 'package:task_bell/widgets/date_selector.dart';
import 'package:task_bell/widgets/birthday_card.dart';
import 'package:task_bell/screens/add_task_screen.dart';
import 'package:task_bell/services/task_service.dart';
import 'package:task_bell/services/birthday_service.dart';
import 'package:task_bell/services/recurrence_completion_service.dart';
import 'package:task_bell/utils/date_formatter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_bell/database/hive_service.dart';
import 'package:task_bell/localization/app_strings.dart';

class WeekScreen extends StatefulWidget {
  const WeekScreen({super.key});

  @override
  State<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends State<WeekScreen> {
  late DateTime _selectedDate;
  late List<DateTime> _weekDates;
  final TaskService _taskService = TaskService();
  final BirthdayService _birthdayService = BirthdayService();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _weekDates = _generateWeekDates(_selectedDate);
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

  List<DateTime> _generateWeekDates(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _navigateWeek(bool forward) {
    setState(() {
      _selectedDate = forward
          ? _selectedDate.add(const Duration(days: 7))
          : _selectedDate.subtract(const Duration(days: 7));
      _weekDates = _generateWeekDates(_selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthName = DateFormatter.formatMonthYear(_selectedDate, Localizations.localeOf(context));
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Month Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                monthName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            // Date Selector
            DateSelector(
              selectedDate: _selectedDate,
              onDateSelected: _onDateSelected,
              dates: _weekDates,
              onPreviousWeek: () => _navigateWeek(false),
              onNextWeek: () => _navigateWeek(true),
            ),
            // Birthdays + Tasks List
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: HiveService.birthdaysBox.listenable(),
                builder: (context, birthdaysBox, _) {
                  final birthdays =
                      _birthdayService.getBirthdaysForDate(_selectedDate);
                  return ValueListenableBuilder(
                    valueListenable: HiveService.tasksBox.listenable(),
                    builder: (context, tasksBox, _) {
                      return ValueListenableBuilder(
                        valueListenable: HiveService.recurrenceCompletionsBox.listenable(),
                        builder: (context, completionsBox, _) {
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
                                  onNoteChanged: (text) async {
                                    await _birthdayService.updateBirthday(
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
                                        _taskService.deleteTask(task.id),
                                    child: TaskCard(
                                      margin: EdgeInsets.zero,
                                  subject: task.subject,
                                  description: task.description,
                                  homework: task.homework ?? '',
                                  isDone: RecurrenceCompletionService.isDoneForDate(task, _selectedDate),
                                  timeText: DateFormatter.formatTimeRangeFromMinutes(
                                    task.timeMinutes,
                                    task.endTimeMinutes,
                                  ),
                                  onToggleDone: () async {
                                    final nowDone = RecurrenceCompletionService.isDoneForDate(task, _selectedDate);
                                    await RecurrenceCompletionService.setDoneForDate(
                                      task,
                                      _selectedDate,
                                      !nowDone,
                                      updateTask: _taskService.updateTask,
                                    );
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
