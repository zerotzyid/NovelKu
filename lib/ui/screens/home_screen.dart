import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/novel_model.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import 'ai_settings_screen.dart';
import 'novel_create_screen.dart';
import 'novel_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final novels = ref.watch(novelNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'NovelKu',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome_outlined),
            tooltip: 'Pengaturan AI',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AISettingsScreen()),
            ),
          ),
        ],
      ),
      body: novels.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.library_books_outlined,
                    size: 80,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Belum ada novel',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Buat novel baru untuk memulai menulis cerita',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Buat Novel Baru'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const NovelCreateScreen()),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: novels.length,
              itemBuilder: (context, index) {
                final novel = novels[index];
                return _NovelCard(
                  novel: novel,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => NovelDetailScreen(novel: novel),
                    ),
                  ),
                  onDelete: () => _deleteNovel(ref, context, novel),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Novel Baru'),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NovelCreateScreen()),
        ),
      ),
    );
  }

  Widget _buildNovelGrid(BuildContext context, List<NovelModel> novels) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: novels.length,
      itemBuilder: (context, index) {
        final novel = novels[index];
        return _NovelCard(
          novel: novel,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => NovelDetailScreen(novel: novel),
            ),
          ),
          onDelete: () => _deleteNovel(ref, context, novel),
        );
      },
    );
  }

  Future<void> _deleteNovel(WidgetRef ref, BuildContext context, NovelModel novel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Hapus "${novel.title}"?', style: GoogleFonts.poppins()),
        content: Text(
          'Novel ini akan dihapus bersama semua babnya.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: GoogleFonts.poppins()),
          ),
          FilledButton.tonal(
            style: FilledButton.tonal.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
            ),
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

class _NovelCard extends StatelessWidget {
  final NovelModel novel;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NovelCard({
    required this.novel,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        novel.title.isNotEmpty ? novel.title[0].toUpperCase() : '?',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: colorScheme.error),
                    onPressed: onDelete,
                    tooltip: 'Hapus Novel',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                novel.title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (novel.genre != null && novel.genre!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Genre: ${novel.genre}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (novel.theme != null && novel.theme!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Tema: ${novel.theme}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const Spacer(),
              Row(
                children: [
                  Text(
                    '${novel.updatedAt.day}/${novel.updatedAt.month}/${novel.updatedAt.year}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
