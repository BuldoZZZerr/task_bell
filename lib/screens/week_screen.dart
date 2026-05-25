import 'package:flutter/material.dart';
import 'package:task_bell/widgets/task_card.dart';
import 'package:task_bell/widgets/date_selector.dart';
import 'package:task_bell/widgets/birthday_card.dart';
import 'package:task_bell/screens/add_task_screen.dart';
import 'package:task_bell/services/task_service.dart';
import 'package:task_bell/services/birthday_service.dart';
import 'package:task_bell/services/recurrence_completion_service.dart';
import 'package:task_bell/utils/date_formatter.dart';
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
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(selectedDate: _selectedDate),
      ),
    );
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
              child: ListenableBuilder(
                listenable: HiveService.tasksBirthdaysCompletionsListenable(),
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
                          onNoteChanged: (text) async {
                            await _birthdayService.updateBirthday(
                              b.copyWith(note: text.isEmpty ? null : text),
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
                              isDone: RecurrenceCompletionService.isDoneForDate(
                                task,
                                _selectedDate,
                              ),
                              timeText:
                                  DateFormatter.formatTimeRangeFromMinutes(
                                task.timeMinutes,
                                task.endTimeMinutes,
                              ),
                              onToggleDone: () async {
                                final nowDone =
                                    RecurrenceCompletionService.isDoneForDate(
                                  task,
                                  _selectedDate,
                                );
                                await RecurrenceCompletionService.setDoneForDate(
                                  task,
                                  _selectedDate,
                                  !nowDone,
                                  updateTask: (t) => _taskService.updateTask(
                                    t,
                                    syncReminder: false,
                                  ),
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
