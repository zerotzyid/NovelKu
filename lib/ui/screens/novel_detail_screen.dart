import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/chapter_model.dart';
import '../../models/novel_model.dart';
import '../../providers/app_providers.dart';
import 'chapter_editor_screen.dart';
import 'ai_settings_screen.dart';

class NovelDetailScreen extends ConsumerWidget {
  final NovelModel novel;
  const NovelDetailScreen({super.key, required this.novel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapters = ref.watch(chapterNotifierProvider(novel.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(novel.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AISettingsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editNovel(context, ref),
          ),
        ],
      ),
      body: chapters.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_note, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Belum ada bab', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('Buat bab pertama untuk memulai', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final chapter = chapters[index];
                return ListTile(
                  leading: CircleAvatar(child: Text('${chapter.number}')),
                  title: Text(chapter.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${chapter.content.length} kata · ${_statusLabel(chapter.status)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteChapter(ref, context, chapter),
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChapterEditorScreen(novelId: novel.id, chapter: chapter),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Bab Baru'),
        onPressed: () => _createChapter(context, ref),
      ),
    );
  }

  String _statusLabel(ChapterStatus s) {
    const labels = {
      ChapterStatus.outline: 'Rangka',
      ChapterStatus.draft: 'Draf',
      ChapterStatus.revised: 'Direvisi',
      ChapterStatus.finalized: 'Final',
    };
    return labels[s] ?? 'Tidak diketahui';
  }

  void _createChapter(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final notifier = ref.read(chapterNotifierProvider(novel.id).notifier);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Buat Bab Baru'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Judul bab'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              final chapter = ChapterModel.create(
                novelId: novel.id,
                number: notifier.nextNumber(novel.id),
                title: controller.text.trim(),
              );
              notifier.add(chapter);
              Navigator.pop(context);
            },
            child: const Text('Buat'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteChapter(WidgetRef ref, BuildContext context, ChapterModel chapter) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Bab?'),
        content: Text('Bab "${chapter.title}" akan dihapus.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(chapterNotifierProvider(novel.id).notifier).remove(chapter.id);
    }
  }

  void _editNovel(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: novel.title);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Judul Novel'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              ref.read(novelNotifierProvider.notifier).update(
                novel.copyWith(title: controller.text.trim(), updatedAt: DateTime.now()),
              );
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
