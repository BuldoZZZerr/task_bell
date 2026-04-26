import 'package:hive/hive.dart';

part 'birthday.g.dart';

@HiveType(typeId: 1)
class Birthday extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  /// Дата рождения (используем только день и месяц для напоминаний)
  @HiveField(2)
  final DateTime date;

  /// Год, в который пользователь скрыл напоминание (чтобы не показывать повторно в этот год)
  @HiveField(3)
  final int? lastHiddenYear;

  /// Заметка к дню рождения (например, что подарить)
  @HiveField(4)
  final String? note;

  Birthday({
    required this.id,
    required this.name,
    required this.date,
    this.lastHiddenYear,
    this.note,
  });

  static const _omit = Object();

  Birthday copyWith({
    String? id,
    String? name,
    DateTime? date,
    int? lastHiddenYear,
    Object? note = _omit,
  }) {
    return Birthday(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      lastHiddenYear: lastHiddenYear ?? this.lastHiddenYear,
      note: note == _omit ? this.note : note as String?,
    );
  }
}

