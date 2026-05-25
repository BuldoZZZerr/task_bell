import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:task_bell/database/hive_service.dart';
import 'package:task_bell/models/task.dart';
import 'package:task_bell/services/task_service.dart';
import 'package:task_bell/utils/task_recurrence.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Планирование локальных напоминаний по задачам.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _channelId = 'task_reminders';
  static const _channelName = 'Task reminders';
  static const _lookaheadDays = 14;
  static const _lastRescheduleKey = 'notifications_last_reschedule';

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      tz.setLocalLocation(tz.local);
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: 'Напоминания о задачах и уроках',
            importance: Importance.high,
          ),
        );

    _initialized = true;
  }

  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    final ios =
        _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }
    return true;
  }

  int _notificationId(String taskId, DateTime day) {
    return '${taskId}_${day.year}-${day.month}-${day.day}'.hashCode & 0x7FFFFFFF;
  }

  DateTime? reminderDateTime(Task task, DateTime occurrenceDay) {
    if (!task.reminderEnabled) return null;

    final dayStart = DateTime(occurrenceDay.year, occurrenceDay.month, occurrenceDay.day);

    if (task.reminderMode == 1) {
      final minutes = task.reminderAtMinutes;
      if (minutes == null) return null;
      return dayStart.add(Duration(minutes: minutes));
    }

    final startMinutes = task.timeMinutes;
    if (startMinutes == null) return null;
    final taskStart = dayStart.add(Duration(minutes: startMinutes));
    return taskStart.subtract(Duration(minutes: task.reminderOffsetMinutes));
  }

  Future<void> cancelTaskReminders(String taskId) async {
    final now = DateTime.now();
    final from = now.subtract(const Duration(days: 1));
    final to = now.add(Duration(days: _lookaheadDays + 1));
    var cursor = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);
    while (!cursor.isAfter(end)) {
      await _plugin.cancel(_notificationId(taskId, cursor));
      cursor = cursor.add(const Duration(days: 1));
    }
  }

  Future<void> syncTaskReminder(Task task) async {
    try {
      if (!_initialized) await init();
      await cancelTaskReminders(task.id);
      if (!task.reminderEnabled) return;

      final now = DateTime.now();
      final to = now.add(const Duration(days: _lookaheadDays));
      final days = taskOccurrenceDays(task, now, to);

      final schedules = <Future<void>>[];
      for (final day in days) {
        final fireAt = reminderDateTime(task, day);
        if (fireAt == null || !fireAt.isAfter(now)) continue;

        final id = _notificationId(task.id, day);
        final title = task.subject.isEmpty ? 'Task Bell' : task.subject;
        final body = task.reminderMode == 0 ? 'Скоро начало' : 'Напоминание';

        schedules.add(
          _plugin.zonedSchedule(
            id,
            title,
            body,
            tz.TZDateTime.from(fireAt, tz.local),
            const NotificationDetails(
              android: AndroidNotificationDetails(
                _channelId,
                _channelName,
                importance: Importance.high,
                priority: Priority.high,
              ),
              iOS: DarwinNotificationDetails(),
            ),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          ),
        );
      }
      if (schedules.isNotEmpty) {
        await Future.wait(schedules);
      }
    } catch (e, st) {
      debugPrint('syncTaskReminder failed for ${task.id}: $e\n$st');
    }
  }

  Future<void> rescheduleAll() async {
    if (!_initialized) await init();
    final tasks = TaskService().tasks.where((t) => t.reminderEnabled).toList();
    for (final task in tasks) {
      await syncTaskReminder(task);
    }
    await _markRescheduledToday();
  }

  /// Перепланирует напоминания при старте не чаще одного раза в день.
  Future<void> rescheduleAllIfNeeded() async {
    if (!_initialized) await init();
    final today = _todayKey();
    final last = HiveService.settingsBox.get(_lastRescheduleKey) as String?;
    if (last == today) return;
    await rescheduleAll();
  }

  Future<void> _markRescheduledToday() async {
    await HiveService.settingsBox.put(_lastRescheduleKey, _todayKey());
  }

  String _todayKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month}-${n.day}';
  }
}
