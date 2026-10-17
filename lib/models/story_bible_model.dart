import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

final _uuid = const Uuid();

class CharacterModel extends Equatable {
  final String id;
  final String novelId;
  final String fullName;
  final int? age;
  final String? appearance;
  final String? personality;
  final String? motivation;
  final String? goal;
  final String? fear;
  final String? background;
  final String? speakingStyle;
  final String? relationship;
  final String? development;
  final bool isAlive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CharacterModel({
    required this.id,
    required this.novelId,
    required this.fullName,
    this.age,
    this.appearance,
    this.personality,
    this.motivation,
    this.goal,
    this.fear,
    this.background,
    this.speakingStyle,
    this.relationship,
    this.development,
    this.isAlive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CharacterModel.create({
    required String novelId,
    required String fullName,
  }) {
    final now = DateTime.now();
    return CharacterModel(
      id: _uuid.v4(),
      novelId: novelId,
      fullName: fullName,
      isAlive: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  CharacterModel copyWith({
    String? id, String? novelId, String? fullName, int? age,
    String? appearance, String? personality, String? motivation,
    String? goal, String? fear, String? background, String? speakingStyle,
    String? relationship, String? development, bool? isAlive,
    DateTime? createdAt, DateTime? updatedAt,
  }) => CharacterModel(
    id: id ?? this.id, novelId: novelId ?? this.novelId,
    fullName: fullName ?? this.fullName, age: age ?? this.age,
    appearance: appearance ?? this.appearance,
    personality: personality ?? this.personality,
    motivation: motivation ?? this.motivation,
    goal: goal ?? this.goal, fear: fear ?? this.fear,
    background: background ?? this.background,
    speakingStyle: speakingStyle ?? this.speakingStyle,
    relationship: relationship ?? this.relationship,
    development: development ?? this.development,
    isAlive: isAlive ?? this.isAlive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'novelId': novelId, 'fullName': fullName, 'age': age,
    'appearance': appearance, 'personality': personality,
    'motivation': motivation, 'goal': goal, 'fear': fear,
    'background': background, 'speakingStyle': speakingStyle,
    'relationship': relationship, 'development': development,
    'isAlive': isAlive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory CharacterModel.fromJson(Map<String, dynamic> json) => CharacterModel(
    id: json['id'], novelId: json['novelId'], fullName: json['fullName'],
    age: json['age'], appearance: json['appearance'],
    personality: json['personality'], motivation: json['motivation'],
    goal: json['goal'], fear: json['fear'], background: json['background'],
    speakingStyle: json['speakingStyle'], relationship: json['relationship'],
    development: json['development'], isAlive: json['isAlive'] ?? true,
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );

  @override
  List<Object?> get props => [id, novelId, fullName, age, appearance, personality,
    motivation, goal, fear, background, speakingStyle, relationship,
    development, isAlive, createdAt, updatedAt];
}

class WorldModel extends Equatable {
  final String id;
  final String novelId;
  final String? name;
  final String? period;
  final String? socialSystem;
  final String? culture;
  final String? worldRules;
  final String? magicOrTechnology;
  final String? history;

  const WorldModel({
    required this.id, required this.novelId,
    this.name, this.period, this.socialSystem, this.culture,
    this.worldRules, this.magicOrTechnology, this.history,
  });

  factory WorldModel.create({required String novelId}) {
    return WorldModel(
      id: const Uuid().v4(), novelId: novelId,
    );
  }

  WorldModel copyWith({
    String? id, String? novelId, String? name, String? period,
    String? socialSystem, String? culture, String? worldRules,
    String? magicOrTechnology, String? history,
  }) => WorldModel(
    id: id ?? this.id, novelId: novelId ?? this.novelId,
    name: name ?? this.name, period: period ?? this.period,
    socialSystem: socialSystem ?? this.socialSystem,
    culture: culture ?? this.culture,
    worldRules: worldRules ?? this.worldRules,
    magicOrTechnology: magicOrTechnology ?? this.magicOrTechnology,
    history: history ?? this.history,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'novelId': novelId, 'name': name, 'period': period,
    'socialSystem': socialSystem, 'culture': culture,
    'worldRules': worldRules, 'magicOrTechnology': magicOrTechnology,
    'history': history,
  };

  factory WorldModel.fromJson(Map<String, dynamic> json) => WorldModel(
    id: json['id'], novelId: json['novelId'], name: json['name'],
    period: json['period'], socialSystem: json['socialSystem'],
    culture: json['culture'], worldRules: json['worldRules'],
    magicOrTechnology: json['magicOrTechnology'], history: json['history'],
  );

  @override
  List<Object?> get props => [id, novelId, name, period, socialSystem, culture,
    worldRules, magicOrTechnology, history];
}

class PlotModel extends Equatable {
  final String id;
  final String novelId;
  final String? premise;
  final String? mainConflict;
  final String? subplot;
  final String? unrevealedSecret;
  final String? foreshadowing;
  final List<String> pastEvents;
  final List<String> plannedEvents;
  final String? intendedEnding;

  const PlotModel({
    required this.id, required this.novelId,
    this.premise, this.mainConflict, this.subplot,
    this.unrevealedSecret, this.foreshadowing,
    this.pastEvents = const [], this.plannedEvents = const [],
    this.intendedEnding,
  });

  factory PlotModel.create({required String novelId}) {
    return PlotModel(id: const Uuid().v4(), novelId: novelId);
  }

  PlotModel copyWith({
    String? id, String? novelId, String? premise, String? mainConflict,
    String? subplot, String? unrevealedSecret, String? foreshadowing,
    List<String>? pastEvents, List<String>? plannedEvents, String? intendedEnding,
  }) => PlotModel(
    id: id ?? this.id, novelId: novelId ?? this.novelId,
    premise: premise ?? this.premise,
    mainConflict: mainConflict ?? this.mainConflict,
    subplot: subplot ?? this.subplot,
    unrevealedSecret: unrevealedSecret ?? this.unrevealedSecret,
    foreshadowing: foreshadowing ?? this.foreshadowing,
    pastEvents: pastEvents ?? this.pastEvents,
    plannedEvents: plannedEvents ?? this.plannedEvents,
    intendedEnding: intendedEnding ?? this.intendedEnding,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'novelId': novelId, 'premise': premise,
    'mainConflict': mainConflict, 'subplot': subplot,
    'unrevealedSecret': unrevealedSecret, 'foreshadowing': foreshadowing,
    'pastEvents': pastEvents, 'plannedEvents': plannedEvents,
    'intendedEnding': intendedEnding,
  };

  factory PlotModel.fromJson(Map<String, dynamic> json) => PlotModel(
    id: json['id'], novelId: json['novelId'], premise: json['premise'],
    mainConflict: json['mainConflict'], subplot: json['subplot'],
    unrevealedSecret: json['unrevealedSecret'], foreshadowing: json['foreshadowing'],
    pastEvents: List<String>.from(json['pastEvents'] ?? const []),
    plannedEvents: List<String>.from(json['plannedEvents'] ?? const []),
    intendedEnding: json['intendedEnding'],
  );

  @override
  List<Object?> get props => [id, novelId, premise, mainConflict, subplot,
    unrevealedSecret, foreshadowing, pastEvents, plannedEvents, intendedEnding];
}

class StoryBibleModel extends Equatable {
  final String id;
  final String novelId;
  final WorldModel world;
  final List<CharacterModel> characters;
  final PlotModel plot;
  final DateTime updatedAt;

  const StoryBibleModel({
    required this.id, required this.novelId,
    required this.world, required this.characters,
    required this.plot, required this.updatedAt,
  });

  factory StoryBibleModel.create({required String novelId}) {
    return StoryBibleModel(
      id: const Uuid().v4(), novelId: novelId,
      world: WorldModel.create(novelId: novelId),
      characters: const [],
      plot: PlotModel.create(novelId: novelId),
      updatedAt: DateTime.now(),
    );
  }

  StoryBibleModel copyWith({
    String? id, String? novelId, WorldModel? world,
    List<CharacterModel>? characters, PlotModel? plot,
    DateTime? updatedAt,
  }) => StoryBibleModel(
    id: id ?? this.id, novelId: novelId ?? this.novelId,
    world: world ?? this.world,
    characters: characters ?? this.characters,
    plot: plot ?? this.plot,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'novelId': novelId, 'world': world.toJson(),
    'characters': characters.map((c) => c.toJson()).toList(),
    'plot': plot.toJson(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory StoryBibleModel.fromJson(Map<String, dynamic> json) => StoryBibleModel(
    id: json['id'], novelId: json['novelId'],
    world: WorldModel.fromJson(json['world']),
    characters: (json['characters'] as List)
        .map((c) => CharacterModel.fromJson(c as Map<String, dynamic>))
        .toList(),
    plot: PlotModel.fromJson(json['plot']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );

  @override
  List<Object?> get props => [id, novelId, world, characters, plot, updatedAt];
}
