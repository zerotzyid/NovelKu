import 'package:hive/hive.dart';
import '../models/generation_history_model.dart';

class GenerationHistoryRepository {
  static const _boxName = 'generation_history';

  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  List<GenerationHistoryModel> get all {
    return _box.values
        .map((e) => GenerationHistoryModel.fromJson(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<GenerationHistoryModel> forNovel(String novelId) {
    return all.where((h) => h.novelId == novelId).toList();
  }

  GenerationHistoryModel? getById(String id) {
    final data = _box.get(id);
    if (data == null) return null;
    return GenerationHistoryModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> save(GenerationHistoryModel history) async {
    await _box.put(history.id, history.toJson());
  }

  Future<void> update(GenerationHistoryModel history) async {
    await _box.put(history.id, history.toJson());
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> clearForNovel(String novelId) async {
    final ids = _box.keys.where((k) {
      final data = _box.get(k);
      return data != null && (data as Map)['novelId'] == novelId;
    }).toList();
    for (final id in ids) await _box.delete(id);
  }

  Future<void> close() async {
    await _box.close();
  }
}
