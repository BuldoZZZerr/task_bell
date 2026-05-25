import 'package:hive/hive.dart';
import 'package:task_bell/database/hive_service.dart';
import 'package:task_bell/models/future_idea.dart';

class FutureIdeaService {
  static final FutureIdeaService _instance = FutureIdeaService._internal();
  factory FutureIdeaService() => _instance;
  FutureIdeaService._internal();

  Box<FutureIdea> get _box => HiveService.ideasBox;

  List<FutureIdea> getAll({int? categoryFilter, bool? doneOnly}) {
    var list = _box.values.toList();
    if (categoryFilter != null) {
      list = list.where((i) => i.category == categoryFilter).toList();
    }
    if (doneOnly == true) {
      list = list.where((i) => i.isDone).toList();
    } else if (doneOnly == false) {
      list = list.where((i) => !i.isDone).toList();
    }
    list.sort((a, b) {
      if (a.isDone != b.isDone) return a.isDone ? 1 : -1;
      return b.createdAt.compareTo(a.createdAt);
    });
    return list;
  }

  Future<void> add(FutureIdea idea) => _box.put(idea.id, idea);

  Future<void> update(FutureIdea idea) => _box.put(idea.id, idea);

  Future<void> delete(String id) => _box.delete(id);

  Future<void> toggleDone(FutureIdea idea) =>
      update(idea.copyWith(isDone: !idea.isDone));
}
