import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_bell/database/hive_service.dart';
import 'package:task_bell/models/birthday.dart';
import 'package:task_bell/localization/app_strings.dart';

class BirthdaysScreen extends StatefulWidget {
  const BirthdaysScreen({super.key});

  @override
  State<BirthdaysScreen> createState() => _BirthdaysScreenState();
}

class _BirthdaysScreenState extends State<BirthdaysScreen> {
  Future<void> _showAddBirthdayDialog() async {
    final nameController = TextEditingController();
    final noteController = TextEditingController();
    DateTime? selectedDate;
    final s = AppStrings.of(context);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(s.addBirthday),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: s.name,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedDate != null
                            ? '${selectedDate!.day.toString().padLeft(2, '0')}.${selectedDate!.month.toString().padLeft(2, '0')}.${selectedDate!.year}'
                            : s.selectDate,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? now,
                          firstDate: DateTime(1900),
                          lastDate: DateTime(now.year + 50),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Text(s.date),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: s.note,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(s.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty || selectedDate == null) {
                  return;
                }
                final birthday = Birthday(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  date: selectedDate!,
                  note: noteController.text.trim().isEmpty
                      ? null
                      : noteController.text.trim(),
                );
                await HiveService.birthdaysBox.put(birthday.id, birthday);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: Text(s.save),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          s.birthdays,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: HiveService.birthdaysBox.listenable(),
          builder: (context, Box<Birthday> box, _) {
            final birthdays = box.values.toList()
              ..sort((a, b) {
                // сортировка по месяцу и дню
                final am = a.date.month;
                final bm = b.date.month;
                if (am != bm) return am.compareTo(bm);
                return a.date.day.compareTo(b.date.day);
              });

            if (birthdays.isEmpty) {
              return Center(
                child: Text(
                  AppStrings.of(context).addBirthdaysHint,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: birthdays.length,
              itemBuilder: (context, index) {
                final b = birthdays[index];
                final dateStr =
                    '${b.date.day.toString().padLeft(2, '0')}.${b.date.month.toString().padLeft(2, '0')}';
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(b.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.of(context).dateLabel(dateStr)),
                        if (b.note != null && b.note!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              b.note!,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () async {
                        await box.delete(b.id);
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddBirthdayDialog,
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          AppStrings.of(context).add,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

