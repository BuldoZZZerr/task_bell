import 'package:hive/hive.dart';

part 'future_idea.g.dart';

/// Категории идей: 0 — фильмы, 1 — музыка, 2 — творчество, 3 — другое.
class IdeaCategory {
  IdeaCategory._();
  static const int movies = 0;
  static const int music = 1;
  static const int creative = 2;
  static const int other = 3;
}

@HiveType(typeId: 2)
class FutureIdea extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String note;

  @HiveField(3)
  final int category;

  @HiveField(4, defaultValue: false)
  final bool isDone;

  @HiveField(5)
  final DateTime createdAt;

  FutureIdea({
    required this.id,
    required this.title,
    this.note = '',
    this.category = IdeaCategory.other,
    this.isDone = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  FutureIdea copyWith({
    String? id,
    String? title,
    String? note,
    int? category,
    bool? isDone,
    DateTime? createdAt,
  }) {
    return FutureIdea(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      category: category ?? this.category,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
