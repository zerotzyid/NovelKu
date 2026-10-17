import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ai_config_model.dart';
import '../models/chapter_model.dart';
import '../models/novel_model.dart';
import '../repositories/ai_settings_repository.dart';
import '../repositories/author_profile_repository.dart';
import '../repositories/chapter_repository.dart';
import '../repositories/generation_history_repository.dart';
import '../repositories/story_bible_repository.dart';
import '../services/ai_providers.dart';
import '../services/custom_openai_provider.dart';
import '../services/openrouter_provider.dart';

// ========== Repository Providers ==========

final aiSettingsRepositoryProvider = Provider<AISettingsRepository>((ref) {
  return AISettingsRepository();
});

final authorProfileRepositoryProvider = Provider<AuthorProfileRepository>((ref) {
  return AuthorProfileRepository();
});

final storyBibleRepositoryProvider = Provider<StoryBibleRepository>((ref) {
  return StoryBibleRepository();
});

final novelRepositoryProvider = Provider<NovelRepository>((ref) {
  return NovelRepository();
});

final chapterRepositoryProvider = Provider<ChapterRepository>((ref) {
  return ChapterRepository();
});

final chapterRevisionRepositoryProvider = Provider<ChapterRevisionRepository>((ref) {
  return ChapterRevisionRepository();
});

final generationHistoryRepositoryProvider = Provider<GenerationHistoryRepository>((ref) {
  return GenerationHistoryRepository();
});

// ========== AI Provider ==========

final aiProviderProvider = Provider<AIProvider>((ref) {
  final settings = ref.watch(aiSettingsRepositoryProvider).config;
  if (settings == null) {
    throw StateError('AI konfigurasi belum disiapkan');
  }
  return AIProviderFactory.create(settings);
});

// ========== Notifiers ==========

class AIConfigNotifier extends StateNotifier<AIConfigModel?> {
  final AISettingsRepository _repository;
  AIConfigNotifier(this._repository) : super(null);

  Future<void> load() async {
    state = _repository.config;
  }

  Future<void> save(AIConfigModel config) async {
    await _repository.save(config);
    state = config;
  }

  Future<void> clearCredentials() async {
    await _repository.clearCredentials();
    state = _repository.config;
  }

  Future<bool> testConnection() async {
    final current = state;
    if (current == null) return false;
    final provider = AIProviderFactory.create(current);
    final result = await provider.testConnection();
    state = current.copyWith(isConnected: result);
    return result;
  }

  Future<List<String>> listModels() async {
    if (state == null) return const [];
    final provider = AIProviderFactory.create(state!);
    return provider.listModels();
  }
}

final aiConfigNotifierProvider =
    StateNotifierProvider<AIConfigNotifier, AIConfigModel?>((ref) {
  return AIConfigNotifier(ref.read(aiSettingsRepositoryProvider));
});

class NovelNotifier extends StateNotifier<List<NovelModel>> {
  final NovelRepository _repository;
  NovelNotifier(this._repository) : super(const []);

  Future<void> load() async {
    state = _repository.all;
  }

  Future<void> add(NovelModel novel) async {
    await _repository.save(novel);
    state = [...state, novel]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> update(NovelModel novel) async {
    await _repository.save(novel);
    state = [
      for (final n in state) if (n.id == novel.id) novel else n,
    ]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> remove(String id) async {
    await _repository.delete(id);
    state = state.where((n) => n.id != id).toList();
  }
}

final novelNotifierProvider =
    StateNotifierProvider<NovelNotifier, List<NovelModel>>((ref) {
  return NovelNotifier(ref.read(novelRepositoryProvider));
});

class ChapterNotifier extends StateNotifier<List<ChapterModel>> {
  final ChapterRepository _repository;
  ChapterNotifier(this._repository) : super(const []);

  Future<void> loadForNovel(String novelId) async {
    state = _repository.getAllForNovel(novelId);
  }

  Future<void> add(ChapterModel chapter) async {
    await _repository.save(chapter);
    state = [...state, chapter]..sort((a, b) => a.number.compareTo(b.number));
  }

  Future<void> update(ChapterModel chapter) async {
    await _repository.save(chapter);
    state = [
      for (final c in state) if (c.id == chapter.id) chapter else c,
    ]..sort((a, b) => a.number.compareTo(b.number));
  }

  Future<void> remove(String id) async {
    await _repository.delete(id);
    state = state.where((c) => c.id != id).toList();
  }

  int nextNumber(String novelId) => _repository.getNextChapterNumber(novelId);
}

final chapterNotifierProvider =
    StateNotifierProvider.family<ChapterNotifier, List<ChapterModel>, String>(
  (ref, novelId) {
    final notifier = ChapterNotifier(ref.read(chapterRepositoryProvider));
    notifier.loadForNovel(novelId);
    return notifier;
  },
);

class GenerationStatusNotifier extends StateNotifier<AIRequestStatus> {
  GenerationStatusNotifier() : super(AIRequestStatus.idle);

  void setLoading() => state = AIRequestStatus.loading;
  void setStreaming() => state = AIRequestStatus.streaming;
  void setSuccess() => state = AIRequestStatus.success;
  void setError() => state = AIRequestStatus.error;
  void setIdle() => state = AIRequestStatus.idle;
}

final generationStatusProvider =
    StateNotifierProvider<GenerationStatusNotifier, AIRequestStatus>((ref) {
  return GenerationStatusNotifier();
});

final generatedTextProvider = StateProvider<String>((ref) => '');
