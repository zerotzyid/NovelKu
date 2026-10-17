import 'package:hive_flutter/hive_flutter.dart';
import '../models/story_bible_model.dart';

class StoryBibleRepository {
  static const _boxName = 'story_bibles';

  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  StoryBibleModel? getByNovelId(String novelId) {
    try {
      return _box.values
          .map((e) => StoryBibleModel.fromJson(Map<String, dynamic>.from(e)))
          .firstWhere((b) => b.novelId == novelId);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(StoryBibleModel bible) async {
    await _box.put(bible.id, bible.toJson());
  }

  Future<void> delete(String novelId) async {
    final bible = getByNovelId(novelId);
    if (bible != null) await _box.delete(bible.id);
  }

  Future<void> close() async {
    await _box.close();
  }
}
