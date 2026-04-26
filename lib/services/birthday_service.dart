import 'package:hive/hive.dart';
import 'package:task_bell/database/hive_service.dart';
import 'package:task_bell/models/birthday.dart';

class BirthdayService {
  static final BirthdayService _instance = BirthdayService._internal();
  factory BirthdayService() => _instance;
  BirthdayService._internal();

  Box<Birthday> get _box => HiveService.birthdaysBox;

  /// Дни рождения для конкретной даты (с учётом скрытия на год).
  List<Birthday> getBirthdaysForDate(DateTime date) {
    return _box.values.where((b) {
      if (b.lastHiddenYear != null && b.lastHiddenYear == date.year) {
        return false;
      }
      return b.date.day == date.day && b.date.month == date.month;
    }).toList();
  }

  Future<void> hideForYear(Birthday birthday, int year) async {
    final updated = birthday.copyWith(lastHiddenYear: year);
    await _box.put(updated.id, updated);
  }

  Future<void> updateBirthday(Birthday birthday) async {
    await _box.put(birthday.id, birthday);
  }
}

