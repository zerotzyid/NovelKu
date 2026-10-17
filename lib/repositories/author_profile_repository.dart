import 'package:hive/hive.dart';
import '../models/author_profile_model.dart';

class AuthorProfileRepository {
  static const _boxName = 'author_profiles';

  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  List<AuthorProfileModel> get all {
    return _box.values
        .map((e) => AuthorProfileModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  AuthorProfileModel? getById(String id) {
    final data = _box.get(id);
    if (data == null) return null;
    return AuthorProfileModel.fromJson(Map<String, dynamic>.from(data));
  }

  AuthorProfileModel? getForNovel(String novelId) {
    try {
      return all.firstWhere((p) => p.novelId == novelId);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(AuthorProfileModel profile) async {
    await _box.put(profile.id, profile.toJson());
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> close() async {
    await _box.close();
  }
}
