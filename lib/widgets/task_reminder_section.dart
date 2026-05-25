import 'package:flutter/material.dart';
import 'package:task_bell/localization/app_strings.dart';

/// Блок настройки напоминания: вкл/выкл, «за сколько до» или «во сколько».
class TaskReminderSection extends StatelessWidget {
  const TaskReminderSection({
    super.key,
    required this.enabled,
    required this.mode,
    required this.offsetMinutes,
    required this.atMinutes,
    required this.hasStartTime,
    required this.onEnabledChanged,
    required this.onModeChanged,
    required this.onOffsetChanged,
    required this.onAtTimePick,
  });

  final bool enabled;
  final int mode;
  final int offsetMinutes;
  final int? atMinutes;
  final bool hasStartTime;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<int> onModeChanged;
  final ValueChanged<int> onOffsetChanged;
  final VoidCallback onAtTimePick;

  static const List<int> offsetOptions = [5, 10, 15, 30, 60, 120, 1440];

  String _formatTime(BuildContext context, int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  String _offsetLabel(AppStrings s, int minutes) {
    if (minutes < 60) return s.reminderMinutesBefore(minutes);
    if (minutes == 60) return s.reminderHourBefore;
    if (minutes == 120) return s.reminderHoursBefore(2);
    return s.reminderDayBefore;
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              s.reminder,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              s.reminderSubtitle,
              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
            ),
            value: enabled,
            onChanged: onEnabledChanged,
          ),
          if (enabled) ...[
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: [
                ButtonSegment(value: 0, label: Text(s.reminderModeBefore)),
                ButtonSegment(value: 1, label: Text(s.reminderModeAt)),
              ],
              selected: {mode},
              onSelectionChanged: (set) => onModeChanged(set.first),
            ),
            const SizedBox(height: 12),
            if (mode == 0) ...[
              if (!hasStartTime)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    s.reminderNeedsStartTime,
                    style: TextStyle(color: colorScheme.error, fontSize: 13),
                  ),
                ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: offsetOptions.map((minutes) {
                  return ChoiceChip(
                    label: Text(_offsetLabel(s, minutes)),
                    selected: offsetMinutes == minutes,
                    onSelected: hasStartTime ? (_) => onOffsetChanged(minutes) : null,
                  );
                }).toList(),
              ),
            ] else ...[
              OutlinedButton(
                onPressed: onAtTimePick,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                ),
                child: Text(
                  atMinutes != null
                      ? '${s.reminderAtTime}: ${_formatTime(context, atMinutes!)}'
                      : s.reminderPickTime,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
