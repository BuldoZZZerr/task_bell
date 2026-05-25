import 'package:flutter/material.dart';
import 'package:task_bell/models/schedule_slot.dart';
import 'package:task_bell/services/notification_service.dart';
import 'package:task_bell/services/schedule_service.dart';
import 'package:task_bell/widgets/task_reminder_section.dart';
import 'package:task_bell/theme/app_theme.dart';
import 'package:task_bell/utils/date_formatter.dart';
import 'package:task_bell/localization/app_strings.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<ScheduleSlot> _slots = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _slots = ScheduleService.getTemplate();
      _slots.sort((a, b) {
        final dayCmp = a.weekday.compareTo(b.weekday);
        if (dayCmp != 0) return dayCmp;
        return a.startMinutes.compareTo(b.startMinutes);
      });
    });
  }

  Future<void> _save() async {
    await ScheduleService.saveTemplate(_slots);
    _load();
  }

  Future<void> _applySchedule() async {
    if (_slots.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.of(context).addOneLesson)),
        );
      }
      return;
    }
    setState(() => _loading = true);
    try {
      await ScheduleService.applySchedule();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.of(context).scheduleApplied)),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Уроки по дням: для каждого дня — список пар (индекс в _slots, слот), отсортированный по времени.
  List<MapEntry<int, ScheduleSlot>> _slotsForDay(int weekday) {
    final list = <MapEntry<int, ScheduleSlot>>[];
    for (var i = 0; i < _slots.length; i++) {
      if (_slots[i].weekday == weekday) list.add(MapEntry(i, _slots[i]));
    }
    list.sort((a, b) => a.value.startMinutes.compareTo(b.value.startMinutes));
    return list;
  }

  /// Добавить урок в выбранный день.
  Future<void> _showAddSlotForDay(int weekday) async {
    final result = await showDialog<ScheduleSlot>(
      context: context,
      builder: (context) => _ScheduleSlotDialog(initial: null, fixedWeekday: weekday),
    );
    if (result == null || !mounted) return;
    setState(() {
      _slots.add(result);
      _slots.sort((a, b) {
        final dayCmp = a.weekday.compareTo(b.weekday);
        if (dayCmp != 0) return dayCmp;
        return a.startMinutes.compareTo(b.startMinutes);
      });
    });
    await _save();
  }

  /// Редактировать урок по индексу в _slots.
  Future<void> _showEditSlot(int index) async {
    if (index < 0 || index >= _slots.length) return;
    final result = await showDialog<ScheduleSlot>(
      context: context,
      builder: (context) => _ScheduleSlotDialog(initial: _slots[index], fixedWeekday: null),
    );
    if (result == null || !mounted) return;
    setState(() {
      _slots[index] = result;
      _slots.sort((a, b) {
        final dayCmp = a.weekday.compareTo(b.weekday);
        if (dayCmp != 0) return dayCmp;
        return a.startMinutes.compareTo(b.startMinutes);
      });
    });
    await _save();
  }

  Future<void> _deleteSlot(int index) async {
    setState(() => _slots.removeAt(index));
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          s.scheduleTitle,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              s.scheduleSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
              children: [
                for (var weekday = 1; weekday <= 7; weekday++) _DaySection(
                  weekday: weekday,
                  dayName: s.weekdayNames[weekday - 1],
                  entries: _slotsForDay(weekday),
                  onAdd: () => _showAddSlotForDay(weekday),
                  onEdit: _showEditSlot,
                  onDelete: _deleteSlot,
                  theme: theme,
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _loading ? null : _applySchedule,
                  icon: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(_loading ? s.applying : s.applySchedule),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  final int weekday;
  final String dayName;
  final List<MapEntry<int, ScheduleSlot>> entries;
  final VoidCallback onAdd;
  final void Function(int index) onEdit;
  final void Function(int index) onDelete;
  final ThemeData theme;

  const _DaySection({
    required this.weekday,
    required this.dayName,
    required this.entries,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    dayName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add, size: 20),
                  label: Text(AppStrings.of(context).addLesson),
                ),
              ],
            ),
          ),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                AppStrings.of(context).noLessons,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            ...entries.map((e) {
              final index = e.key;
              final slot = e.value;
              return _LessonTile(
                slot: slot,
                onEdit: () => onEdit(index),
                onDelete: () => onDelete(index),
                theme: theme,
              );
            }),
        ],
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  final ScheduleSlot slot;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ThemeData theme;

  const _LessonTile({
    required this.slot,
    required this.onEdit,
    required this.onDelete,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormatter.formatTimeRangeFromMinutes(
          slot.startMinutes,
          slot.endMinutes,
        ) ??
        DateFormatter.formatTimeFromMinutes(slot.startMinutes) ??
        '';
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: SizedBox(
        width: 72,
        child: Text(
          timeStr,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
      title: Text(
        slot.subject.isEmpty ? AppStrings.of(context).noTitle : slot.subject,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 22),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 22),
            onPressed: onDelete,
          ),
        ],
      ),
      onTap: onEdit,
    );
  }
}

class _ScheduleSlotDialog extends StatefulWidget {
  final ScheduleSlot? initial;
  final int? fixedWeekday;

  const _ScheduleSlotDialog({this.initial, this.fixedWeekday});

  @override
  State<_ScheduleSlotDialog> createState() => _ScheduleSlotDialogState();
}

class _ScheduleSlotDialogState extends State<_ScheduleSlotDialog> {
  late int _weekday;
  late int _startMinutes;
  late int _endMinutes;
  final _subjectController = TextEditingController();
  bool _reminderEnabled = false;
  int _reminderMode = 0;
  int _reminderOffsetMinutes = 15;
  int? _reminderAtMinutes;

  bool get _dayFixed => widget.fixedWeekday != null;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _weekday = widget.fixedWeekday ?? i?.weekday ?? 1;
    _startMinutes = i?.startMinutes ?? 9 * 60;
    _endMinutes = i?.endMinutes ?? 10 * 60;
    _subjectController.text = i?.subject ?? '';
    _reminderEnabled = i?.reminderEnabled ?? false;
    _reminderMode = i?.reminderMode ?? 0;
    _reminderOffsetMinutes = i?.reminderOffsetMinutes ?? 15;
    _reminderAtMinutes = i?.reminderAtMinutes;
  }

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _pickStartTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _startMinutes ~/ 60, minute: _startMinutes % 60),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (t != null && mounted) {
      setState(() {
        _startMinutes = t.hour * 60 + t.minute;
        if (_endMinutes <= _startMinutes) _endMinutes = _startMinutes + 60;
      });
    }
  }

  Future<void> _pickReminderTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: (_reminderAtMinutes ?? _startMinutes) ~/ 60,
        minute: (_reminderAtMinutes ?? _startMinutes) % 60,
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (t != null && mounted) {
      setState(() => _reminderAtMinutes = t.hour * 60 + t.minute);
    }
  }

  Future<void> _pickEndTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _endMinutes ~/ 60, minute: _endMinutes % 60),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (t != null && mounted) {
      setState(() {
        _endMinutes = t.hour * 60 + t.minute;
        if (_endMinutes <= _startMinutes) _startMinutes = _endMinutes - 60;
      });
    }
  }

  Future<void> _submit() async {
    final s = AppStrings.of(context);
    final subject = _subjectController.text.trim();
    if (subject.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.enterSubjectName)),
      );
      return;
    }
    if (_reminderEnabled) {
      if (_reminderMode == 1 && _reminderAtMinutes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.reminderPickTime)),
        );
        return;
      }
      await NotificationService.instance.init();
      await NotificationService.instance.requestPermission();
    }
    if (!mounted) return;
    Navigator.of(context).pop(ScheduleSlot(
      weekday: _weekday,
      startMinutes: _startMinutes,
      endMinutes: _endMinutes,
      subject: subject,
      reminderEnabled: _reminderEnabled,
      reminderMode: _reminderMode,
      reminderOffsetMinutes: _reminderOffsetMinutes,
      reminderAtMinutes: _reminderAtMinutes,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return AlertDialog(
      title: Text(widget.initial == null ? s.addLesson : s.editLesson),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: s.subject,
                hintText: s.subjectHint,
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            if (_dayFixed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  AppStrings.of(context).weekdayNames[_weekday - 1],
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              )
            else
              DropdownButtonFormField<int>(
                initialValue: _weekday,
                decoration: InputDecoration(labelText: s.weekdayLabel),
                items: List.generate(7, (i) => i + 1).map((w) {
                  return DropdownMenuItem(
                    value: w,
                    child: Text(AppStrings.of(context).weekdayNames[w - 1]),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _weekday = v ?? 1),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickStartTime,
                    child: Text(
                      DateFormatter.formatTimeFromMinutes(_startMinutes) ?? s.start,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickEndTime,
                    child: Text(
                      DateFormatter.formatTimeFromMinutes(_endMinutes) ?? s.end,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TaskReminderSection(
              enabled: _reminderEnabled,
              mode: _reminderMode,
              offsetMinutes: _reminderOffsetMinutes,
              atMinutes: _reminderAtMinutes,
              hasStartTime: true,
              onEnabledChanged: (value) => setState(() => _reminderEnabled = value),
              onModeChanged: (mode) => setState(() => _reminderMode = mode),
              onOffsetChanged: (minutes) =>
                  setState(() => _reminderOffsetMinutes = minutes),
              onAtTimePick: _pickReminderTime,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(s.cancel),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
          ),
          child: Text(s.save),
        ),
      ],
    );
  }
}
