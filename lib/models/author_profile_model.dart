import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

final _uuid = const Uuid();

enum WritingStyle {
  formal, casual, literary, poetic, realistic, cinematic,
  descriptive, minimalist, darkMysterious, comedy, romantic, adventure, custom
}

enum POV { firstPerson, thirdPersonLimited, thirdPersonOmniscient }
enum Tense { past, present }

class AuthorProfileModel extends Equatable {
  final String id;
  final String? novelId; // null = global profile
  final String name;
  final List<WritingStyle> styles;
  final String customStyle;
  final List<String> customInstructions;
  final POV pointOfView;
  final Tense tense;
  final int paragraphLength; // 1-5
  final int dialogDensity; // 1-5
  final int descriptionIntensity; // 1-5
  final int pacing; // 1-5
  final int emotionDepth; // 1-5
  final int vocabularyComplexity; // 1-5
  final int targetWordCountPerChapter;
  final String? primaryLanguage;
  final String? dialogLanguage;
  final bool useForeignTerms;
  final String? openingStyle;
  final String? closingStyle;
  final double styleConsistency; // 0-1
  final String freeFormInstructions;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AuthorProfileModel({
    required this.id,
    this.novelId,
    required this.name,
    required this.styles,
    this.customStyle = '',
    this.customInstructions = const [],
    required this.pointOfView,
    required this.tense,
    this.paragraphLength = 3,
    this.dialogDensity = 3,
    this.descriptionIntensity = 3,
    this.pacing = 3,
    this.emotionDepth = 3,
    this.vocabularyComplexity = 3,
    this.targetWordCountPerChapter = 2000,
    this.primaryLanguage,
    this.dialogLanguage,
    this.useForeignTerms = false,
    this.openingStyle,
    this.closingStyle,
    this.styleConsistency = 0.8,
    this.freeFormInstructions = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory AuthorProfileModel.createGlobal({required String name}) {
    final now = DateTime.now();
    return AuthorProfileModel(
      id: _uuid.v4(), name: name,
      pointOfView: POV.thirdPersonLimited, tense: Tense.past,
      createdAt: now, updatedAt: now,
    );
  }

  factory AuthorProfileModel.createForNovel({
    required String novelId, required String name,
  }) {
    final now = DateTime.now();
    return AuthorProfileModel(
      id: _uuid.v4(), novelId: novelId, name: name,
      pointOfView: POV.thirdPersonLimited, tense: Tense.past,
      createdAt: now, updatedAt: now,
    );
  }

  AuthorProfileModel copyWith({
    String? id, String? novelId, String? name,
    List<WritingStyle>? styles, String? customStyle,
    List<String>? customInstructions, POV? pointOfView, Tense? tense,
    int? paragraphLength, int? dialogDensity, int? descriptionIntensity,
    int? pacing, int? emotionDepth, int? vocabularyComplexity,
    int? targetWordCountPerChapter, String? primaryLanguage,
    String? dialogLanguage, bool? useForeignTerms,
    String? openingStyle, String? closingStyle, double? styleConsistency,
    String? freeFormInstructions, DateTime? createdAt, DateTime? updatedAt,
  }) => AuthorProfileModel(
    id: id ?? this.id, novelId: novelId ?? this.novelId,
    name: name ?? this.name, styles: styles ?? this.styles,
    customStyle: customStyle ?? this.customStyle,
    customInstructions: customInstructions ?? this.customInstructions,
    pointOfView: pointOfView ?? this.pointOfView,
    tense: tense ?? this.tense,
    paragraphLength: paragraphLength ?? this.paragraphLength,
    dialogDensity: dialogDensity ?? this.dialogDensity,
    descriptionIntensity: descriptionIntensity ?? this.descriptionIntensity,
    pacing: pacing ?? this.pacing,
    emotionDepth: emotionDepth ?? this.emotionDepth,
    vocabularyComplexity: vocabularyComplexity ?? this.vocabularyComplexity,
    targetWordCountPerChapter:
        targetWordCountPerChapter ?? this.targetWordCountPerChapter,
    primaryLanguage: primaryLanguage ?? this.primaryLanguage,
    dialogLanguage: dialogLanguage ?? this.dialogLanguage,
    useForeignTerms: useForeignTerms ?? this.useForeignTerms,
    openingStyle: openingStyle ?? this.openingStyle,
    closingStyle: closingStyle ?? this.closingStyle,
    styleConsistency: styleConsistency ?? this.styleConsistency,
    freeFormInstructions: freeFormInstructions ?? this.freeFormInstructions,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'novelId': novelId, 'name': name,
    'styles': styles.map((e) => e.index).toList(),
    'customStyle': customStyle,
    'customInstructions': customInstructions,
    'pointOfView': pointOfView.index,
    'tense': tense.index,
    'paragraphLength': paragraphLength,
    'dialogDensity': dialogDensity,
    'descriptionIntensity': descriptionIntensity,
    'pacing': pacing,
    'emotionDepth': emotionDepth,
    'vocabularyComplexity': vocabularyComplexity,
    'targetWordCountPerChapter': targetWordCountPerChapter,
    'primaryLanguage': primaryLanguage,
    'dialogLanguage': dialogLanguage,
    'useForeignTerms': useForeignTerms,
    'openingStyle': openingStyle,
    'closingStyle': closingStyle,
    'styleConsistency': styleConsistency,
    'freeFormInstructions': freeFormInstructions,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory AuthorProfileModel.fromJson(Map<String, dynamic> json) =>
      AuthorProfileModel(
        id: json['id'], novelId: json['novelId'], name: json['name'],
        styles: (json['styles'] as List)
            .map((e) => WritingStyle.values[e as int]).toList(),
        customStyle: json['customStyle'] ?? '',
        customInstructions: List<String>.from(json['customInstructions'] ?? const []),
        pointOfView: POV.values[json['pointOfView'] as int],
        tense: Tense.values[json['tense'] as int],
        paragraphLength: json['paragraphLength'] as int,
        dialogDensity: json['dialogDensity'] as int,
        descriptionIntensity: json['descriptionIntensity'] as int,
        pacing: json['pacing'] as int,
        emotionDepth: json['emotionDepth'] as int,
        vocabularyComplexity: json['vocabularyComplexity'] as int,
        targetWordCountPerChapter: json['targetWordCountPerChapter'] as int,
        primaryLanguage: json['primaryLanguage'],
        dialogLanguage: json['dialogLanguage'],
        useForeignTerms: json['useForeignTerms'] as bool? ?? false,
        openingStyle: json['openingStyle'],
        closingStyle: json['closingStyle'],
        styleConsistency: (json['styleConsistency'] as num).toDouble(),
        freeFormInstructions: json['freeFormInstructions'] ?? '',
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );

  @override
  List<Object?> get props => [id, novelId, name, styles, customStyle,
    customInstructions, pointOfView, tense, paragraphLength, dialogDensity,
    descriptionIntensity, pacing, emotionDepth, vocabularyComplexity,
    targetWordCountPerChapter, primaryLanguage, dialogLanguage,
    useForeignTerms, openingStyle, closingStyle, styleConsistency,
    freeFormInstructions, createdAt, updatedAt];
}
