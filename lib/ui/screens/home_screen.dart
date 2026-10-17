import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/novel_model.dart';
import '../../providers/app_providers.dart';
import 'novel_detail_screen.dart';
import 'ai_settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final novels = ref.watch(novelNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novelku'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AISettingsScreen()),
            ),
          ),
        ],
      ),
      body: novels.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.library_books, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Belum ada novel', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('Buat novel baru untuk memulai menulis', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: novels.length,
              itemBuilder: (context, index) {
                final novel = novels[index];
                return ListTile(
                  leading: const Icon(Icons.book),
                  title: Text(novel.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Diperbarui: ${_formatDate(novel.updatedAt)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteNovel(ref, context, novel),
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => NovelDetailScreen(novel: novel),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _createNovel(context, ref),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _createNovel(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Buat Novel Baru'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Judul novel'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              final novel = NovelModel.create(title: controller.text.trim());
              ref.read(novelNotifierProvider.notifier).add(novel);
              Navigator.pop(context);
            },
            child: const Text('Buat'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteNovel(WidgetRef ref, BuildContext context, NovelModel novel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Novel?'),
        content: Text('Novel "${novel.title}" akan dihapus bersama semua babnya.'),
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
      ref.read(novelNotifierProvider.notifier).remove(novel.id);
    }
  }
}
