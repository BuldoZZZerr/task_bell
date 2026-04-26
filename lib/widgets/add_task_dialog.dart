import 'package:flutter/material.dart';
import 'package:task_bell/models/task.dart';
import 'package:task_bell/services/task_service.dart';
import 'package:task_bell/localization/app_strings.dart';

class AddTaskDialog extends StatefulWidget {
  final DateTime selectedDate;
  final Task? existingTask;

  const AddTaskDialog({
    super.key,
    required this.selectedDate,
    this.existingTask,
  });

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingTask != null) {
      _subjectController.text = widget.existingTask!.subject;
      _descriptionController.text = widget.existingTask!.description;
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return AlertDialog(
      title: Text(widget.existingTask == null ? s.addTask : s.editTask),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _subjectController,
            decoration: InputDecoration(
              labelText: s.subject,
              hintText: s.enterSubjectHint,
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: s.description,
              hintText: s.enterDescriptionHint,
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(s.cancel),
        ),
          ElevatedButton(
          onPressed: () {
            if (_subjectController.text.trim().isNotEmpty) {
              Task task;
              if (widget.existingTask != null) {
                task = widget.existingTask!.copyWith(
                  subject: _subjectController.text.trim(),
                  description: _descriptionController.text.trim(),
                );
                TaskService().updateTask(task);
              } else {
                task = Task(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  subject: _subjectController.text.trim(),
                  description: _descriptionController.text.trim(),
                  date: widget.selectedDate,
                );
                TaskService().addTask(task);
              }
              Navigator.of(context).pop(task);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: Text(widget.existingTask == null ? s.add : s.save),
        ),
      ],
    );
  }
}
