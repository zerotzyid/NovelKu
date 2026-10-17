import 'package:hive_flutter/hive_flutter.dart';
import '../models/chapter_model.dart';
import '../models/novel_model.dart';

class NovelRepository {
  static const _boxName = 'novels';

  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  List<NovelModel> get all {
    return _box.values
        .map((e) => NovelModel.fromJson(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  NovelModel? getById(String id) {
    final data = _box.get(id);
    if (data == null) return null;
    return NovelModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> save(NovelModel novel) async {
    await _box.put(novel.id, novel.toJson());
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> close() async {
    await _box.close();
  }
}

class ChapterRepository {
  static const _boxName = 'chapters';

  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  List<ChapterModel> getAllForNovel(String novelId) {
    return _box.values
        .map((e) => ChapterModel.fromJson(Map<String, dynamic>.from(e)))
        .where((c) => c.novelId == novelId)
        .toList()
      ..sort((a, b) => a.number.compareTo(b.number));
  }

  ChapterModel? getById(String id) {
    final data = _box.get(id);
    if (data == null) return null;
    return ChapterModel.fromJson(Map<String, dynamic>.from(data));
  }

  ChapterModel? getByNovelAndNumber(String novelId, int number) {
    try {
      return getAllForNovel(novelId).firstWhere((c) => c.number == number);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(ChapterModel chapter) async {
    await _box.put(chapter.id, chapter.toJson());
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> deleteForNovel(String novelId) async {
    final ids = _box.keys
        .where((k) {
          final data = _box.get(k);
          return data != null &&
              (data as Map)[ 'novelId'] == novelId;
        })
        .toList();
    for (final id in ids) await _box.delete(id);
  }

  int getNextChapterNumber(String novelId) {
    final chapters = getAllForNovel(novelId);
    if (chapters.isEmpty) return 1;
    return chapters.map((c) => c.number).reduce((a, b) => a > b ? a : b) + 1;
  }

  Future<void> close() async {
    await _box.close();
  }
}

class ChapterRevisionRepository {
  static const _boxName = 'chapter_revisions';

  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  List<Map<String, dynamic>> getRevisionsForChapter(String chapterId) {
    return _box.values
        .map((e) => Map<String, dynamic>.from(e))
        .where((e) => e['chapterId'] == chapterId)
        .toList()
      ..sort((a, b) => DateTime.parse(b['createdAt'])
          .compareTo(DateTime.parse(a['createdAt'])));
  }

  Future<void> saveRevision({
    required String chapterId,
    required String content,
    String? changeSource,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _box.put(id, {
      'id': id,
      'chapterId': chapterId,
      'content': content,
      'changeSource': changeSource,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> close() async {
    await _box.close();
  }
}
