import 'package:hive_flutter/hive_flutter.dart';
import '../models/ai_config_model.dart';

class AISettingsRepository {
  static const _boxName = 'ai_settings';
  static const _key = 'ai_config';

  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  AIConfigModel? get config {
    final data = _box.get(_key);
    if (data == null) return null;
    return AIConfigModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> save(AIConfigModel config) async {
    await _box.put(_key, config.toJson());
  }

  Future<void> clearCredentials() async {
    final current = config;
    if (current == null) return;
    await _box.put(_key, current.copyWith(
      apiKey: '',
      isConnected: false,
      lastError: null,
    ).toJson());
  }

  Future<void> delete() async {
    await _box.delete(_key);
  }

  Future<void> close() async {
    await _box.close();
  }
}
