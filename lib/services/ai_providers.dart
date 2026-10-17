import 'dart:async';
import 'package:http/http.dart' as http;

import '../models/ai_config_model.dart';
import '../models/author_profile_model.dart';
import '../models/chapter_model.dart';
import '../models/generation_history_model.dart';
import '../models/story_bible_model.dart';

enum AIRequestStatus { idle, loading, streaming, success, error }

class AIResponse {
  final String text;
  final bool isComplete;
  final int? inputTokens;
  final int? outputTokens;
  final String? error;
  final AIRequestStatus status;

  const AIResponse({
    required this.text,
    required this.isComplete,
    this.inputTokens,
    this.outputTokens,
    this.error,
    this.status = AIRequestStatus.idle,
  });

  factory AIResponse.chunk(String text) => AIResponse(
        text: text, isComplete: false, status: AIRequestStatus.streaming,
      );

  factory AIResponse.complete({
    required String text, int? inputTokens, int? outputTokens,
  }) => AIResponse(
        text: text, isComplete: true,
        inputTokens: inputTokens, outputTokens: outputTokens,
        status: AIRequestStatus.success,
      );

  factory AIResponse.error(String message) => AIResponse(
        text: '', isComplete: true, error: message,
        status: AIRequestStatus.error,
      );
}

abstract class AIProvider {
  String get providerName;
  AIConfigModel get config;

  Future<bool> testConnection();
  Future<List<String>> listModels();

  Stream<AIResponse> generateStream({
    required String prompt,
    required String systemPrompt,
    double temperature = 0.7,
    double topP = 1.0,
    int maxTokens = 4096,
  });

  Future<AIResponse> generate({
    required String prompt,
    required String systemPrompt,
    double temperature = 0.7,
    double topP = 1.0,
    int maxTokens = 4096,
  });
}

class AIProviderException implements Exception {
  final String message;
  final int? statusCode;
  final bool isAuthError;
  final bool isRateLimit;

  AIProviderException({
    required this.message,
    this.statusCode,
    this.isAuthError = false,
    this.isRateLimit = false,
  }) : super(message);

  @override
  String toString() => 'AIProviderException: $message';
}

class AIContextData {
  final String novelPremise;
  final String globalOutline;
  final String? chapterOutline;
  final String previousChapterContent;
  final String latestStorySummary;
  final List<String> relevantCharacters;
  final List<String> relevantWorldRules;
  final AuthorProfileModel authorProfile;
  final String? chapterSpecificInstructions;

  const AIContextData({
    required this.novelPremise,
    required this.globalOutline,
    this.chapterOutline,
    required this.previousChapterContent,
    required this.latestStorySummary,
    required this.relevantCharacters,
    required this.relevantWorldRules,
    required this.authorProfile,
    this.chapterSpecificInstructions,
  });
}

abstract class ContextBuilder {
  String buildSystemPrompt(AuthorProfileModel profile);
  String buildUserPrompt({
    required AIContextData context,
    required String chapterNumber,
    required String chapterTitle,
    required String chapterGoal,
    required List<String> requiredEvents,
    required List<String> charactersInvolved,
    required int targetWordCount,
    required String emotionalTone,
    required String endingApproach,
    required String? additionalInstructions,
  });
}

class DefaultContextBuilder implements ContextBuilder {
  @override
  String buildSystemPrompt(AuthorProfileModel profile) {
    final styles = profile.styles.map((s) => _styleLabel(s)).join(', ');
    final custom = profile.customStyle.isNotEmpty
        ? 'Gaya khusus: ${profile.customStyle}. ' : '';
    final instructions = profile.freeFormInstructions.isNotEmpty
        ? 'Instruksi khusus: ${profile.freeFormInstructions}. ' : '';

    return '''
Anda adalah asisten penulis novel profesional. Tugas Anda membantu pengguna menulis novel berdasarkan konteks cerita yang diberikan.

PROFIL PENULIS:
- Gaya bahasa: $styles $custom
- Sudut pandang: ${_povLabel(profile.pointOfView)}
- Waktu penceritaan: ${_tenseLabel(profile.tense)}
- Panjang paragraf: ${profile.paragraphLength}/5
- Kepadatan dialog: ${profile.dialogDensity}/5
- Intensitas deskripsi: ${profile.descriptionIntensity}/5
- Kecepatan alur: ${profile.pacing}/5
- Kedalaman emosi: ${profile.emotionDepth}/5
- Kompleksitas kosakata: ${profile.vocabularyComplexity}/5
- Target kata per bab: ${profile.targetWordCountPerChapter}
- Bahasa utama: ${profile.primaryLanguage ?? 'Indonesia'}
- Bahasa dialog: ${profile.dialogLanguage ?? 'Indonesia'}
- Konsistensi gaya: ${(profile.styleConsistency * 100).toInt()}%

$custom$instructions

ATURAN KONTINUITAS:
- Gunakan nama dan fakta karakter yang sudah ditentukan.
- Hormati peristiwa dari bab sebelumnya.
- Jangan menghidupkan kembali karakter yang sudah meninggal tanpa alasan cerita.
- Jangan mengubah hubungan karakter secara mendadak.
- Jangan mengubah aturan dunia secara sembarangan.
- Jangan mengulang adegan penting tanpa tujuan naratif.
- Jangan mengungkap rahasia terlalu cepat.
- Jika informasi penting bertentangan atau belum tersedia, minta klarifikasi atau sebutkan asumsi.

Tuliskan dalam bahasa Indonesia yang natural. Jangan pernah mengklaim target kata terpenuhi jika hasilnya belum mencukupi.
''';
  }

  @override
  String buildUserPrompt({
    required AIContextData context,
    required String chapterNumber,
    required String chapterTitle,
    required String chapterGoal,
    required List<String> requiredEvents,
    required List<String> charactersInvolved,
    required int targetWordCount,
    required String emotionalTone,
    required String endingApproach,
    required String? additionalInstructions,
  }) {
    final events = requiredEvents.isNotEmpty
        ? requiredEvents.map((e) => '- $e').join('\n') : '- (tidak ada)';
    final chars = charactersInvolved.isNotEmpty
        ? charactersInvolved.join(', ') : '- (tidak ada)';

    return '''
TULIS BAB NOVEL

Konteks Novel:
- Premis: ${context.novelPremise}
- Outline global: ${context.globalOutline}
- Ringkasan cerita terbaru: ${context.latestStorySummary}

Bab:
- Nomor: $chapterNumber
- Judul: $chapterTitle
- Tujuan: $chapterGoal
- Karakter terlibat: $chars
- Target jumlah kata: $targetWordCount
- Nuansa emosional: $emotionalTone
- Cara mengakhiri: $endingApproach

Peristiwa wajib terjadi:
$events

Isi bab sebelumnya (konteks):
${context.previousChapterContent}

Profil karakter terkait:
${context.relevantCharacters.join('\n')}

Aturan dunia relevan:
${context.relevantWorldRules.join('\n')}

${context.chapterOutline != null ? 'Outline bab:\n${context.chapterOutline}\n' : ''}

${additionalInstructions != null && additionalInstructions.isNotEmpty
    ? 'Instruksi tambahan:\n$additionalInstructions\n' : ''}

Hasilkan teks bab lengkap sesuai semua spesifikasi di atas.
''';
  }

  String _styleLabel(WritingStyle s) {
    const labels = {
      WritingStyle.formal: 'Formal',
      WritingStyle.casual: 'Santai',
      WritingStyle.literary: 'Sastra',
      WritingStyle.poetic: 'Puitis',
      WritingStyle.realistic: 'Realistis',
      WritingStyle.cinematic: 'Sinematik',
      WritingStyle.descriptive: 'Deskriptif',
      WritingStyle.minimalist: 'Minimalis',
      WritingStyle.darkMysterious: 'Gelap dan misterius',
      WritingStyle.comedy: 'Komedi',
      WritingStyle.romantic: 'Romantis',
      WritingStyle.adventure: 'Petualangan',
      WritingStyle.custom: 'Khusus',
    };
    return labels[s] ?? 'Lainnya';
  }

  String _povLabel(POV p) {
    const labels = {
      POV.firstPerson: 'Orang pertama',
      POV.thirdPersonLimited: 'Orang ketiga terbatas',
      POV.thirdPersonOmniscient: 'Orang ketiga serbatahu',
    };
    return labels[p] ?? 'Orang ketiga';
  }

  String _tenseLabel(Tense t) {
    return t == Tense.past ? 'Lampau' : 'Sekarang';
  }
}

class ChapterGenerator {
  final AIProvider provider;
  final ContextBuilder contextBuilder;

  ChapterGenerator({required this.provider, ContextBuilder? contextBuilder})
      : contextBuilder = contextBuilder ?? DefaultContextBuilder();

  Stream<AIResponse> generateChapterStream({
    required AIContextData context,
    required String chapterNumber,
    required String chapterTitle,
    required String chapterGoal,
    required List<String> requiredEvents,
    required List<String> charactersInvolved,
    required int targetWordCount,
    required String emotionalTone,
    required String endingApproach,
    required String? additionalInstructions,
  }) async* {
    final systemPrompt = contextBuilder.buildSystemPrompt(context.authorProfile);
    final userPrompt = contextBuilder.buildUserPrompt(
      context: context,
      chapterNumber: chapterNumber,
      chapterTitle: chapterTitle,
      chapterGoal: chapterGoal,
      requiredEvents: requiredEvents,
      charactersInvolved: charactersInvolved,
      targetWordCount: targetWordCount,
      emotionalTone: emotionalTone,
      endingApproach: endingApproach,
      additionalInstructions: additionalInstructions,
    );

    yield* provider.generateStream(
      prompt: userPrompt,
      systemPrompt: systemPrompt,
      temperature: context.authorProfile.temperatureEquivalent,
      maxTokens: targetWordCount ~/ 3 + 500,
    );
  }

  Future<AIResponse> generateChapter({
    required AIContextData context,
    required String chapterNumber,
    required String chapterTitle,
    required String chapterGoal,
    required List<String> requiredEvents,
    required List<String> charactersInvolved,
    required int targetWordCount,
    required String emotionalTone,
    required String endingApproach,
    required String? additionalInstructions,
  }) async {
    final systemPrompt = contextBuilder.buildSystemPrompt(context.authorProfile);
    final userPrompt = contextBuilder.buildUserPrompt(
      context: context,
      chapterNumber: chapterNumber,
      chapterTitle: chapterTitle,
      chapterGoal: chapterGoal,
      requiredEvents: requiredEvents,
      charactersInvolved: charactersInvolved,
      targetWordCount: targetWordCount,
      emotionalTone: emotionalTone,
      endingApproach: endingApproach,
      additionalInstructions: additionalInstructions,
    );

    return provider.generate(
      prompt: userPrompt,
      systemPrompt: systemPrompt,
      temperature: context.authorProfile.temperatureEquivalent,
      maxTokens: targetWordCount ~/ 3 + 500,
    );
  }
}

extension on AuthorProfileModel {
  double get temperatureEquivalent {
    final consistency = styleConsistency.clamp(0.0, 1.0);
    return 0.3 + (1.0 - consistency) * 0.7;
  }
}

class ChapterRevisionService {
  final AIProvider provider;

  ChapterRevisionService({required this.provider});

  Stream<AIResponse> reviseSelectionStream({
    required String selectedText,
    required String instruction,
    required AuthorProfileModel profile,
  }) async* {
    final systemPrompt = '''
Anda adalah editor novel. Revisikan teks yang dipilih berdasarkan instruksi pengguna.
Pertahankan gaya dan kontinousti cerita. Jangan mengubah makna inti kecuali diminta.
Gaya penulis: ${profile.styles.map((s) => _styleLabel(s)).join(', ')}.
''';
    final userPrompt = '''
Teks yang akan direvisi:
$selectedText

Instruksi revisi:
$instruction

Hasilkan versi yang direvisi.
''';
    yield* provider.generateStream(
      prompt: userPrompt,
      systemPrompt: systemPrompt,
      temperature: profile.temperatureEquivalent,
      maxTokens: selectedText.length ~/ 2 + 300,
    );
  }

  Future<AIResponse> fixDialog({
    required String dialog,
    required AuthorProfileModel profile,
  }) async {
    final systemPrompt = '''
Anda adalah editor dialog novel. Perbaiki dialog agar lebih natural, tidak kaku,
dan sesuai kepribadian karakter. Pertahankan makna asli.
''';
    final userPrompt = 'Dialog:\n$dialog\n\nPerbaiki dialog ini.';
    return provider.generate(
      prompt: userPrompt,
      systemPrompt: systemPrompt,
      temperature: profile.temperatureEquivalent,
      maxTokens: dialog.length ~/ 2 + 200,
    );
  }

  Future<AIResponse> fixGrammar({
    required String text,
    required AuthorProfileModel profile,
  }) async {
    final systemPrompt = '''
Anda adalah editor bahasa. Perbaiki tata bahasa dan ejaan teks berikut
tanpa mengubah gaya penulis atau alur cerita.
''';
    final userPrompt = 'Teks:\n$text\n\nPerbaiki tata bahasa.';
    return provider.generate(
      prompt: userPrompt,
      systemPrompt: systemPrompt,
      temperature: 0.3,
      maxTokens: text.length ~/ 2 + 200,
    );
  }

  Future<AIResponse> addDescription({
    required String text,
    required AuthorProfileModel profile,
  }) async {
    final systemPrompt = '''
Anda adalah penulis deskriptif. Tambahkan deskripsi yang kaya namun tidak berlebih
pada teks berikut. Pertahankan alur dan dialog asli.
''';
    final userPrompt = 'Teks:\n$text\n\nTambahkan deskripsi.';
    return provider.generate(
      prompt: userPrompt,
      systemPrompt: systemPrompt,
      temperature: profile.temperatureEquivalent,
      maxTokens: text.length ~/ 2 + 300,
    );
  }

  String _styleLabel(WritingStyle s) {
    const labels = {
      WritingStyle.formal: 'Formal', WritingStyle.casual: 'Santai',
      WritingStyle.literary: 'Sastra', WritingStyle.poetic: 'Puitis',
      WritingStyle.realistic: 'Realistis', WritingStyle.cinematic: 'Sinematik',
      WritingStyle.descriptive: 'Deskriptif', WritingStyle.minimalist: 'Minimalis',
      WritingStyle.darkMysterious: 'Gelap dan misterius', WritingStyle.comedy: 'Komedi',
      WritingStyle.romantic: 'Romantis', WritingStyle.adventure: 'Petualangan',
      WritingStyle.custom: 'Khusus',
    };
    return labels[s] ?? 'Lainnya';
  }
}

class ContinuityChecker {
  final StoryBibleModel storyBible;

  ContinuityChecker({required this.storyBible});

  List<String> checkConflicts(String content) {
    final conflicts = <String>[];
    final lower = content.toLowerCase();

    for (final char in storyBible.characters) {
      if (!char.isAlive && lower.contains(char.fullName.toLowerCase())) {
        conflicts.add(
          'Karakter "${char.fullName}" telah meninggal sesuai Story Bible, '
          'namun muncul dalam konten ini tanpa alasan yang ditetapkan.',
        );
      }
    }

    return conflicts;
  }

  List<String> extractMentionedCharacters(String content) {
    final mentioned = <String>[];
    for (final char in storyBible.characters) {
      if (content.contains(char.fullName)) {
        mentioned.add(char.fullName);
      }
    }
    return mentioned;
  }
}

class TokenUsageService {
  final List<TokenUsageModel> _usages = [];

  void record(TokenUsageModel usage) {
    _usages.add(usage);
  }

  List<TokenUsageModel> get usages => List.unmodifiable(_usages);

  int get totalInputTokens =>
      _usages.fold(0, (sum, u) => sum + u.inputTokens);

  int get totalOutputTokens =>
      _usages.fold(0, (sum, u) => sum + u.outputTokens);

  double get totalEstimatedCost =>
      _usages.fold(0.0, (sum, u) => sum + u.estimatedCost);

  List<TokenUsageModel> usagesForNovel(String novelId) =>
      _usages.where((u) => u.novelId == novelId).toList();
}

class GenerationHistoryService {
  final List<GenerationHistoryModel> _history = [];

  void add(GenerationHistoryModel item) {
    _history.insert(0, item);
  }

  List<GenerationHistoryModel> get history => List.unmodifiable(_history);

  List<GenerationHistoryModel> forNovel(String novelId) =>
      _history.where((h) => h.novelId == novelId).toList();

  GenerationHistoryModel? find(String id) =>
      _history.firstWhere((h) => h.id == id, orElse: () => throw StateError('not found'));

  void update(String id, GenerationHistoryModel updated) {
    final idx = _history.indexWhere((h) => h.id == id);
    if (idx != -1) _history[idx] = updated;
  }
}
