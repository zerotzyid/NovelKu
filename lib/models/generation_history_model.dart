import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

final _uuid = const Uuid();

enum GenerationType {
  novelOutline, chapterOutline, fullChapter, continueWriting,
  expandScene, rewriteParagraph, fixDialog, fixGrammar,
  addDescription, plotTwist, consistencyCheck, alternateScenes
}

enum GenerationStatus { pending, streaming, completed, failed, cancelled }

class GenerationHistoryModel extends Equatable {
  final String id;
  final String novelId;
  final String? chapterId;
  final GenerationType type;
  final String prompt;
  final String? result;
  final GenerationStatus status;
  final int? inputTokens;
  final int? outputTokens;
  final double? estimatedCost;
  final String? providerType;
  final String? modelId;
  final DateTime createdAt;
  final String? errorMessage;

  const GenerationHistoryModel({
    required this.id, required this.novelId, this.chapterId,
    required this.type, required this.prompt, this.result,
    required this.status, this.inputTokens, this.outputTokens,
    this.estimatedCost, this.providerType, this.modelId,
    required this.createdAt, this.errorMessage,
  });

  factory GenerationHistoryModel.create({
    required String novelId, required GenerationType type,
    required String prompt, String? chapterId,
    String? providerType, String? modelId,
  }) {
    return GenerationHistoryModel(
      id: _uuid.v4(), novelId: novelId, chapterId: chapterId,
      type: type, prompt: prompt, status: GenerationStatus.pending,
      providerType: providerType, modelId: modelId,
      createdAt: DateTime.now(),
    );
  }

  GenerationHistoryModel copyWith({
    String? id, String? novelId, String? chapterId, GenerationType? type,
    String? prompt, String? result, GenerationStatus? status,
    int? inputTokens, int? outputTokens, double? estimatedCost,
    String? providerType, String? modelId, DateTime? createdAt,
    String? errorMessage,
  }) => GenerationHistoryModel(
    id: id ?? this.id, novelId: novelId ?? this.novelId,
    chapterId: chapterId ?? this.chapterId, type: type ?? this.type,
    prompt: prompt ?? this.prompt, result: result ?? this.result,
    status: status ?? this.status,
    inputTokens: inputTokens ?? this.inputTokens,
    outputTokens: outputTokens ?? this.outputTokens,
    estimatedCost: estimatedCost ?? this.estimatedCost,
    providerType: providerType ?? this.providerType,
    modelId: modelId ?? this.modelId,
    createdAt: createdAt ?? this.createdAt,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'novelId': novelId, 'chapterId': chapterId,
    'type': type.index, 'prompt': prompt, 'result': result,
    'status': status.index, 'inputTokens': inputTokens,
    'outputTokens': outputTokens, 'estimatedCost': estimatedCost,
    'providerType': providerType, 'modelId': modelId,
    'createdAt': createdAt.toIso8601String(),
    'errorMessage': errorMessage,
  };

  factory GenerationHistoryModel.fromJson(Map<String, dynamic> json) =>
      GenerationHistoryModel(
        id: json['id'], novelId: json['novelId'], chapterId: json['chapterId'],
        type: GenerationType.values[json['type'] as int],
        prompt: json['prompt'], result: json['result'],
        status: GenerationStatus.values[json['status'] as int],
        inputTokens: json['inputTokens'], outputTokens: json['outputTokens'],
        estimatedCost: (json['estimatedCost'] as num?)?.toDouble(),
        providerType: json['providerType'], modelId: json['modelId'],
        createdAt: DateTime.parse(json['createdAt']),
        errorMessage: json['errorMessage'],
      );

  @override
  List<Object?> get props => [id, novelId, chapterId, type, prompt, result,
    status, inputTokens, outputTokens, estimatedCost, providerType, modelId,
    createdAt, errorMessage];
}

class TokenUsageModel extends Equatable {
  final String id;
  final String novelId;
  final String providerType;
  final String modelId;
  final int inputTokens;
  final int outputTokens;
  final double estimatedCost;
  final DateTime date;

  const TokenUsageModel({
    required this.id, required this.novelId,
    required this.providerType, required this.modelId,
    required this.inputTokens, required this.outputTokens,
    required this.estimatedCost, required this.date,
  });

  factory TokenUsageModel.create({
    required String novelId, required String providerType,
    required String modelId, required int inputTokens,
    required int outputTokens, required double estimatedCost,
  }) {
    return TokenUsageModel(
      id: const Uuid().v4(), novelId: novelId,
      providerType: providerType, modelId: modelId,
      inputTokens: inputTokens, outputTokens: outputTokens,
      estimatedCost: estimatedCost, date: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, novelId, providerType, modelId,
    inputTokens, outputTokens, estimatedCost, date];
}

class ChapterRevisionModel extends Equatable {
  final String id;
  final String chapterId;
  final String content;
  final String? changeSource;
  final DateTime createdAt;

  const ChapterRevisionModel({
    required this.id, required this.chapterId,
    required this.content, this.changeSource, required this.createdAt,
  });

  factory ChapterRevisionModel.create({
    required String chapterId, required String content, String? changeSource,
  }) {
    return ChapterRevisionModel(
      id: const Uuid().v4(), chapterId: chapterId,
      content: content, changeSource: changeSource,
      createdAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, chapterId, content, changeSource, createdAt];
}
