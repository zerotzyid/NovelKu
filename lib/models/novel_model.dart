import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

final _uuid = const Uuid();

enum NovelStatus { drafting, completed, archived }

class NovelModel extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? genre;
  final String? theme;
  final String? background;
  final String? language;
  final NovelStatus status;
  final String? aiProfileId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NovelModel({
    required this.id,
    required this.title,
    this.description,
    this.genre,
    this.theme,
    this.background,
    this.language,
    this.status = NovelStatus.drafting,
    this.aiProfileId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NovelModel.create({
    required String title,
    String? description,
    String? genre,
    String? theme,
    String? background,
    String? language,
    String? aiProfileId,
  }) {
    final now = DateTime.now();
    return NovelModel(
      id: _uuid.v4(),
      title: title,
      description: description,
      genre: genre,
      theme: theme,
      background: background,
      language: language,
      status: NovelStatus.drafting,
      aiProfileId: aiProfileId,
      createdAt: now,
      updatedAt: now,
    );
  }

  NovelModel copyWith({
    String? id,
    String? title,
    String? description,
    String? genre,
    String? theme,
    String? background,
    String? language,
    NovelStatus? status,
    String? aiProfileId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NovelModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      genre: genre ?? this.genre,
      theme: theme ?? this.theme,
      background: background ?? this.background,
      language: language ?? this.language,
      status: status ?? this.status,
      aiProfileId: aiProfileId ?? this.aiProfileId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'genre': genre,
        'theme': theme,
        'background': background,
        'language': language,
        'status': status.index,
        'aiProfileId': aiProfileId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory NovelModel.fromJson(Map<String, dynamic> json) => NovelModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        genre: json['genre'] as String?,
        theme: json['theme'] as String?,
        background: json['background'] as String?,
        language: json['language'] as String?,
        status: NovelStatus.values[json['status'] as int],
        aiProfileId: json['aiProfileId'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  @override
  List<Object?> get props =>
      [id, title, description, genre, theme, background, language, status, aiProfileId, createdAt, updatedAt];
}
