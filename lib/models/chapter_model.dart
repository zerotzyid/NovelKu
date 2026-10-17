import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

final _uuid = const Uuid();

enum ChapterStatus { outline, draft, revised, finalized }

class ChapterModel extends Equatable {
  final String id;
  final String novelId;
  final int number;
  final String title;
  final String? goal;
  final List<String> requiredEvents;
  final List<String> charactersInvolved;
  final int targetWordCount;
  final String emotionalTone;
  final String? endingApproach;
  final String? additionalInstructions;
  final String content;
  final ChapterStatus status;
  final String? summary;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChapterModel({
    required this.id,
    required this.novelId,
    required this.number,
    required this.title,
    this.goal,
    this.requiredEvents = const [],
    this.charactersInvolved = const [],
    this.targetWordCount = 2000,
    this.emotionalTone = 'neutral',
    this.endingApproach,
    this.additionalInstructions,
    this.content = '',
    this.status = ChapterStatus.outline,
    this.summary,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChapterModel.create({
    required String novelId,
    required int number,
    required String title,
    String? goal,
    List<String>? requiredEvents,
    List<String>? charactersInvolved,
    int? targetWordCount,
    String? emotionalTone,
  }) {
    final now = DateTime.now();
    return ChapterModel(
      id: _uuid.v4(),
      novelId: novelId,
      number: number,
      title: title,
      goal: goal,
      requiredEvents: requiredEvents ?? const [],
      charactersInvolved: charactersInvolved ?? const [],
      targetWordCount: targetWordCount ?? 2000,
      emotionalTone: emotionalTone ?? 'neutral',
      content: '',
      status: ChapterStatus.outline,
      createdAt: now,
      updatedAt: now,
    );
  }

  ChapterModel copyWith({
    String? id,
    String? novelId,
    int? number,
    String? title,
    String? goal,
    List<String>? requiredEvents,
    List<String>? charactersInvolved,
    int? targetWordCount,
    String? emotionalTone,
    String? endingApproach,
    String? additionalInstructions,
    String? content,
    ChapterStatus? status,
    String? summary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChapterModel(
      id: id ?? this.id,
      novelId: novelId ?? this.novelId,
      number: number ?? this.number,
      title: title ?? this.title,
      goal: goal ?? this.goal,
      requiredEvents: requiredEvents ?? this.requiredEvents,
      charactersInvolved: charactersInvolved ?? this.charactersInvolved,
      targetWordCount: targetWordCount ?? this.targetWordCount,
      emotionalTone: emotionalTone ?? this.emotionalTone,
      endingApproach: endingApproach ?? this.endingApproach,
      additionalInstructions: additionalInstructions ?? this.additionalInstructions,
      content: content ?? this.content,
      status: status ?? this.status,
      summary: summary ?? this.summary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'novelId': novelId,
        'number': number,
        'title': title,
        'goal': goal,
        'requiredEvents': requiredEvents,
        'charactersInvolved': charactersInvolved,
        'targetWordCount': targetWordCount,
        'emotionalTone': emotionalTone,
        'endingApproach': endingApproach,
        'additionalInstructions': additionalInstructions,
        'content': content,
        'status': status.index,
        'summary': summary,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ChapterModel.fromJson(Map<String, dynamic> json) => ChapterModel(
        id: json['id'] as String,
        novelId: json['novelId'] as String,
        number: json['number'] as int,
        title: json['title'] as String,
        goal: json['goal'] as String?,
        requiredEvents: List<String>.from(json['requiredEvents'] ?? const []),
        charactersInvolved: List<String>.from(json['charactersInvolved'] ?? const []),
        targetWordCount: json['targetWordCount'] as int,
        emotionalTone: json['emotionalTone'] as String,
        endingApproach: json['endingApproach'] as String?,
        additionalInstructions: json['additionalInstructions'] as String?,
        content: json['content'] as String,
        status: ChapterStatus.values[json['status'] as int],
        summary: json['summary'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  @override
  List<Object?> get props => [
        id, novelId, number, title, goal, requiredEvents, charactersInvolved,
        targetWordCount, emotionalTone, endingApproach, additionalInstructions,
        content, status, summary, createdAt, updatedAt,
      ];
}
