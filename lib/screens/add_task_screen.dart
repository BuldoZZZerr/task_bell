import 'package:flutter/material.dart';
import 'package:task_bell/models/task.dart';
import 'package:task_bell/services/task_service.dart';
import 'package:task_bell/localization/app_strings.dart';

class AddTaskScreen extends StatefulWidget {
  final DateTime selectedDate;
  final Task? existingTask;

  const AddTaskScreen({
    super.key,
    required this.selectedDate,
    this.existingTask,
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _taskNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _homeworkController = TextEditingController();
  int? _startTimeMinutes;
  int? _endTimeMinutes;
  // 0 - без повтора, 1 - каждый день, 2 - каждую неделю, 3 - раз в месяц, 4 - раз в год
  int _recurrence = 0;

  @override
  void initState() {
    super.initState();
    if (widget.existingTask != null) {
      _taskNameController.text = widget.existingTask!.subject;
      _descriptionController.text = widget.existingTask!.description;
      _homeworkController.text = widget.existingTask!.homework ?? '';
      _startTimeMinutes = widget.existingTask!.timeMinutes;
      _endTimeMinutes = widget.existingTask!.endTimeMinutes;
      _recurrence = widget.existingTask!.recurrence;
    }
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _descriptionController.dispose();
    _homeworkController.dispose();
    super.dispose();
  }

  Future<void> _pickTime({required bool isStart}) async {
    final currentMinutes = isStart ? _startTimeMinutes : _endTimeMinutes;
    final initialTime = currentMinutes != null
        ? TimeOfDay(
            hour: currentMinutes ~/ 60,
            minute: currentMinutes % 60,
          )
        : TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        final minutes = picked.hour * 60 + picked.minute;
        if (isStart) {
          _startTimeMinutes = minutes;
          // если конец раньше, подвинем конец
          if (_endTimeMinutes != null && _endTimeMinutes! < _startTimeMinutes!) {
            _endTimeMinutes = _startTimeMinutes;
          }
        } else {
          _endTimeMinutes = minutes;
          // если конец раньше начала, двигаем начало назад
          if (_startTimeMinutes != null && _endTimeMinutes! < _startTimeMinutes!) {
            _startTimeMinutes = _endTimeMinutes;
          }
        }
      });
    }
  }

  String _formatTime(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  void _saveTask() {
    if (_taskNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.of(context).enterTaskName)),
      );
      return;
    }

    final description = _descriptionController.text.trim();
    final homework = _homeworkController.text.trim();

    final task = widget.existingTask != null
        ? widget.existingTask!.copyWith(
            subject: _taskNameController.text.trim(),
            description: description,
            homework: homework,
            timeMinutes: _startTimeMinutes,
            endTimeMinutes: _endTimeMinutes,
            recurrence: _recurrence,
          )
        : Task(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            subject: _taskNameController.text.trim(),
            description: description,
            homework: homework,
            date: widget.selectedDate,
            timeMinutes: _startTimeMinutes,
            endTimeMinutes: _endTimeMinutes,
            recurrence: _recurrence,
          );

    if (widget.existingTask != null) {
      TaskService().updateTask(task);
    } else {
      TaskService().addTask(task);
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          s.newTask,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  // Task Name Input
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? Colors.white : Colors.black).withValues(alpha: isDark ? 0.08 : 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _taskNameController,
                      decoration: InputDecoration(
                        hintText: s.taskNameHint,
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: colorScheme.surface,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Time Range Picker
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time, color: colorScheme.onSurfaceVariant),
                            const SizedBox(width: 8),
                            Text(
                              s.time,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            if (_startTimeMinutes != null || _endTimeMinutes != null)
                              IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _startTimeMinutes = null;
                                    _endTimeMinutes = null;
                                  });
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _pickTime(isStart: true),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  _startTimeMinutes != null
                                      ? _formatTime(_startTimeMinutes!)
                                      : s.start,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _startTimeMinutes != null
                                        ? colorScheme.onSurface
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _pickTime(isStart: false),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  _endTimeMinutes != null
                                      ? _formatTime(_endTimeMinutes!)
                                      : s.end,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _endTimeMinutes != null
                                        ? colorScheme.onSurface
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Description
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? Colors.white : Colors.black).withValues(alpha: isDark ? 0.08 : 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: s.description,
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: colorScheme.surface,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Homework
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? Colors.white : Colors.black).withValues(alpha: isDark ? 0.08 : 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _homeworkController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: s.note,
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: colorScheme.surface,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Recurrence
                  Text(
                    s.recurrence,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ChoiceChip(
                        label: Text(s.noRepeat),
                        selected: _recurrence == 0,
                        onSelected: (_) {
                          setState(() => _recurrence = 0);
                        },
                      ),
                      ChoiceChip(
                        label: Text(s.everyDay),
                        selected: _recurrence == 1,
                        onSelected: (_) {
                          setState(() => _recurrence = 1);
                        },
                      ),
                      ChoiceChip(
                        label: Text(s.everyWeek),
                        selected: _recurrence == 2,
                        onSelected: (_) {
                          setState(() => _recurrence = 2);
                        },
                      ),
                      ChoiceChip(
                        label: Text(s.everyMonth),
                        selected: _recurrence == 3,
                        onSelected: (_) {
                          setState(() => _recurrence = 3);
                        },
                      ),
                      ChoiceChip(
                        label: Text(s.everyYear),
                        selected: _recurrence == 4,
                        onSelected: (_) {
                          setState(() => _recurrence = 4);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveTask,
        backgroundColor: Colors.green,
        icon: const Icon(Icons.check, color: Colors.white),
        label: Text(
          s.save,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
