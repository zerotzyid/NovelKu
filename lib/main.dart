import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'models/ai_config_model.dart';
import 'models/author_profile_model.dart';
import 'models/chapter_model.dart';
import 'models/generation_history_model.dart';
import 'models/novel_model.dart';
import 'models/story_bible_model.dart';
import 'ui/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);

  Hive.registerAdapter(NovelModelAdapter());
  Hive.registerAdapter(ChapterModelAdapter());
  Hive.registerAdapter(StoryBibleModelAdapter());
  Hive.registerAdapter(WorldModelAdapter());
  Hive.registerAdapter(CharacterModelAdapter());
  Hive.registerAdapter(PlotModelAdapter());
  Hive.registerAdapter(AIConfigModelAdapter());
  Hive.registerAdapter(AuthorProfileModelAdapter());
  Hive.registerAdapter(GenerationHistoryModelAdapter());

  await Hive.openBox('ai_settings');
  await Hive.openBox('novels');
  await Hive.openBox('chapters');
  await Hive.openBox('author_profiles');
  await Hive.openBox('story_bibles');
  await Hive.openBox('chapter_revisions');
  await Hive.openBox('generation_history');

  runApp(const ProviderScope(child: NovelkuApp()));
}

class NovelkuApp extends StatelessWidget {
  const NovelkuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Novelku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6D4C41)),
      ),
      home: const HomeScreen(),
    );
  }
}

class NovelModelAdapter extends TypeAdapter<NovelModel> {
  @override
  final int typeId = 0;
  @override
  NovelModel read(BinaryReader reader) {
    final map = reader.readMap();
    return NovelModel.fromJson(Map<String, dynamic>.from(map));
  }

  @override
  void write(BinaryWriter writer, NovelModel obj) {
    writer.writeMap(obj.toJson());
  }
}

class ChapterModelAdapter extends TypeAdapter<ChapterModel> {
  @override
  final int typeId = 1;
  @override
  ChapterModel read(BinaryReader reader) {
    final map = reader.readMap();
    return ChapterModel.fromJson(Map<String, dynamic>.from(map));
  }

  @override
  void write(BinaryWriter writer, ChapterModel obj) {
    writer.writeMap(obj.toJson());
  }
}

class StoryBibleModelAdapter extends TypeAdapter<StoryBibleModel> {
  @override
  final int typeId = 2;
  @override
  StoryBibleModel read(BinaryReader reader) {
    final map = reader.readMap();
    return StoryBibleModel.fromJson(Map<String, dynamic>.from(map));
  }

  @override
  void write(BinaryWriter writer, StoryBibleModel obj) {
    writer.writeMap(obj.toJson());
  }
}

class WorldModelAdapter extends TypeAdapter<WorldModel> {
  @override
  final int typeId = 3;
  @override
  WorldModel read(BinaryReader reader) {
    final map = reader.readMap();
    return WorldModel.fromJson(Map<String, dynamic>.from(map));
  }

  @override
  void write(BinaryWriter writer, WorldModel obj) {
    writer.writeMap(obj.toJson());
  }
}

class CharacterModelAdapter extends TypeAdapter<CharacterModel> {
  @override
  final int typeId = 4;
  @override
  CharacterModel read(BinaryReader reader) {
    final map = reader.readMap();
    return CharacterModel.fromJson(Map<String, dynamic>.from(map));
  }

  @override
  void write(BinaryWriter writer, CharacterModel obj) {
    writer.writeMap(obj.toJson());
  }
}

class PlotModelAdapter extends TypeAdapter<PlotModel> {
  @override
  final int typeId = 5;
  @override
  PlotModel read(BinaryReader reader) {
    final map = reader.readMap();
    return PlotModel.fromJson(Map<String, dynamic>.from(map));
  }

  @override
  void write(BinaryWriter writer, PlotModel obj) {
    writer.writeMap(obj.toJson());
  }
}

class AIConfigModelAdapter extends TypeAdapter<AIConfigModel> {
  @override
  final int typeId = 6;
  @override
  AIConfigModel read(BinaryReader reader) {
    final map = reader.readMap();
    return AIConfigModel.fromJson(Map<String, dynamic>.from(map));
  }

  @override
  void write(BinaryWriter writer, AIConfigModel obj) {
    writer.writeMap(obj.toJson());
  }
}

class AuthorProfileModelAdapter extends TypeAdapter<AuthorProfileModel> {
  @override
  final int typeId = 7;
  @override
  AuthorProfileModel read(BinaryReader reader) {
    final map = reader.readMap();
    return AuthorProfileModel.fromJson(Map<String, dynamic>.from(map));
  }

  @override
  void write(BinaryWriter writer, AuthorProfileModel obj) {
    writer.writeMap(obj.toJson());
  }
}

class GenerationHistoryModelAdapter extends TypeAdapter<GenerationHistoryModel> {
  @override
  final int typeId = 8;
  @override
  GenerationHistoryModel read(BinaryReader reader) {
    final map = reader.readMap();
    return GenerationHistoryModel.fromJson(Map<String, dynamic>.from(map));
  }

  @override
  void write(BinaryWriter writer, GenerationHistoryModel obj) {
    writer.writeMap(obj.toJson());
  }
}
