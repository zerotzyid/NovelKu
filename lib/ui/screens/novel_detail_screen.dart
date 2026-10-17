import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/chapter_model.dart';
import '../../models/novel_model.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import 'ai_settings_screen.dart';
import 'chapter_editor_screen.dart';

class NovelDetailScreen extends ConsumerWidget {
  final NovelModel novel;
  const NovelDetailScreen({super.key, required this.novel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapters = ref.watch(chapterNotifierProvider(novel.id));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          novel.title,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome_outlined),
            tooltip: 'Pengaturan AI',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AISettingsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Novel',
            onPressed: () => _editNovel(context, ref),
          ),
        ],
      ),
      body: chapters.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_note_outlined, size: 80, color: colorScheme.onSurfaceVariant),
                  const SizedBox(height: 24),
                  Text(
                    'Belum ada bab',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Buat bab pertama untuk memulai menulis',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Buat Bab Baru'),
                    onPressed: () => _createChapter(context, ref),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final chapter = chapters[index];
                return _buildChapterCard(context, ref, chapter);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Bab Baru'),
        onPressed: () => _createChapter(context, ref),
      ),
    );
  }

  Widget _buildChapterCard(BuildContext context, WidgetRef ref, ChapterModel chapter) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Text(
            '${chapter.number}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        title: Text(
          chapter.title,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${chapter.content.length} kata · ${_statusLabel(chapter.status)}',
          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: colorScheme.error),
          onPressed: () => _deleteChapter(ref, context, chapter),
          tooltip: 'Hapus Bab',
        ),
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
        title: Text('Buat Bab Baru', style: TextStyle()),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Judul bab',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle()),
          ),
          FilledButton(
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
        title: Text('Hapus Bab?', style: TextStyle()),
        content: Text('Bab "${chapter.title}" akan dihapus.', style: TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: TextStyle()),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
            ),
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
        title: Text('Edit Judul Novel', style: TextStyle()),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle()),
          ),
          FilledButton(
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
