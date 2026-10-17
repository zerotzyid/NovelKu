import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/story_bible_model.dart';
import '../../models/author_profile_model.dart';
import '../../providers/app_providers.dart';
import 'author_profile_screen.dart';

class StoryBibleScreen extends ConsumerStatefulWidget {
  final String novelId;
  const StoryBibleScreen({super.key, required this.novelId});

  @override
  ConsumerState<StoryBibleScreen> createState() => _StoryBibleScreenState();
}

class _StoryBibleScreenState extends ConsumerState<StoryBibleScreen> {
  int _tab = 0; // 0=world, 1=characters, 2=plot
  final _worldNameController = TextEditingController();
  final _worldPeriodController = TextEditingController();
  final _premiseController = TextEditingController();
  final _conflictController = TextEditingController();

  @override
  void dispose() {
    _worldNameController.dispose();
    _worldPeriodController.dispose();
    _premiseController.dispose();
    _conflictController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bibleAsync = ref.watch(storyBibleRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Story Bible'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: TabController(length: 3, vsync: const TabController(length: 3, initialIndex: 0)),
            tabs: const [
              Tab(text: 'Dunia Cerita'),
              Tab(text: 'Karakter'),
              Tab(text: 'Alur Cerita'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: TabController(length: 3, vsync: const TabController(length: 3, initialIndex: 0)),
              children: [
                _buildWorldTab(),
                _buildCharactersTab(),
                _buildPlotTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.person_add),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AuthorProfileScreen(novelId: widget.novelId)),
        ),
      ),
    );
  }

  Widget _buildWorldTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(controller: _worldNameController, decoration: const InputDecoration(labelText: 'Nama Dunia', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: _worldPeriodController, decoration: const InputDecoration(labelText: 'Periode Waktu', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        const Text('Sistem Sosial & Budaya', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(decoration: const InputDecoration(labelText: 'Deskripsi...', border: OutlineInputBorder()), maxLines: 3),
        const SizedBox(height: 12),
        const Text('Aturan Dunia', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(decoration: const InputDecoration(labelText: 'Aturan...', border: OutlineInputBorder()), maxLines: 3),
        const SizedBox(height: 12),
        const Text('Sihir / Teknologi', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(decoration: const InputDecoration(labelText: 'Deskripsi...', border: OutlineInputBorder()), maxLines: 3),
        const SizedBox(height: 12),
        const Text('Sejarah', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(decoration: const InputDecoration(labelText: 'Sejarah...', border: OutlineInputBorder()), maxLines: 4),
      ],
    );
  }

  Widget _buildCharactersTab() {
    return const Center(child: Text('Daftar karakter akan ditampilkan di sini'));
  }

  Widget _buildPlotTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(controller: _premiseController, decoration: const InputDecoration(labelText: 'Premis Utama', border: OutlineInputBorder()), maxLines: 3),
        const SizedBox(height: 12),
        TextField(controller: _conflictController, decoration: const InputDecoration(labelText: 'Konflik Utama', border: OutlineInputBorder()), maxLines: 3),
        const SizedBox(height: 12),
        const Text('Subplot', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(decoration: const InputDecoration(labelText: 'Subplot...', border: OutlineInputBorder()), maxLines: 3),
        const SizedBox(height: 12),
        const Text('Akhir Cerita yang Dituju', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(decoration: const InputDecoration(labelText: 'Akhir...', border: OutlineInputBorder()), maxLines: 3),
      ],
    );
  }
}
