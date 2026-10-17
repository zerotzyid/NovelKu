import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/chapter_model.dart';
import '../../providers/app_providers.dart';
import '../../services/ai_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_action_button.dart';

class ChapterEditorScreen extends ConsumerStatefulWidget {
  final String novelId;
  final ChapterModel chapter;
  const ChapterEditorScreen({
    super.key, required this.novelId, required this.chapter,
  });

  @override
  ConsumerState<ChapterEditorScreen> createState() => _ChapterEditorScreenState();
}

class _ChapterEditorScreenState extends ConsumerState<ChapterEditorScreen> {
  late TextEditingController _contentController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.chapter.content);
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(generationStatusProvider);
    final generated = ref.watch(generatedTextProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bab ${widget.chapter.number}: ${widget.chapter.title}',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome_outlined),
            tooltip: 'Tulis dengan AI',
            onPressed: () => _showAIMenu(context),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'save') _save();
              if (value == 'revision') _showRevisionHistory();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'save',
                child: Row(
                  children: [
                    const Icon(Icons.save_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text('Simpan', style: TextStyle()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'revision',
                child: Row(
                  children: [
                    const Icon(Icons.history_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text('Riwayat Revisi', style: TextStyle()),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                enabled: _isEditing,
                decoration: InputDecoration(
                  hintText: 'Mulai menulis bab di sini...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          if (status == AIRequestStatus.streaming || status == AIRequestStatus.loading)
            const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${_contentController.text.split(' ').length} kata',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    if (generated.isNotEmpty && status != AIRequestStatus.streaming)
                      AIActionButton(
                        label: 'Ganti Teks',
                        onPressed: () => _replaceText(generated),
                        icon: Icons.refresh_outlined,
                      ),
                    if (generated.isNotEmpty && status != AIRequestStatus.streaming)
                      AIActionButton(
                        label: 'Sisipkan',
                        onPressed: () => _insertText(generated),
                        icon: Icons.add_outlined,
                      ),
                    if (generated.isNotEmpty && status != AIRequestStatus.streaming)
                      AIActionButton(
                        label: 'Salin',
                        onPressed: () => _copyText(generated),
                        icon: Icons.content_copy_outlined,
                      ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      icon: Icon(_isEditing ? Icons.check_outlined : Icons.edit_outlined),
                      label: Text(_isEditing ? 'Selesai' : 'Edit'),
                      onPressed: () {
                        if (!_isEditing) {
                          setState(() => _isEditing = true);
                        } else {
                          _save();
                          setState(() => _isEditing = false);
                        }
                      },
                    ),
                  ],
                ),
                if (generated.isNotEmpty && status != AIRequestStatus.streaming) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      border: Border.all(color: Colors.green.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Hasil AI siap diterapkan',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    ref.read(chapterNotifierProvider(widget.novelId).notifier).update(
      widget.chapter.copyWith(
        content: _contentController.text,
        status: _contentController.text.isNotEmpty
            ? ChapterStatus.draft
            : ChapterStatus.outline,
        updatedAt: DateTime.now(),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Disimpan', style: TextStyle()),
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAIMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tulis dengan AI',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _buildAIListTile(
              context,
              icon: Icons.auto_awesome_outlined,
              title: 'Generate Bab Lengkap',
              subtitle: 'Buat bab baru dari outline dan Story Bible',
            ),
            _buildAIListTile(
              context,
              icon: Icons.play_arrow_outlined,
              title: 'Lanjutkan dari Sini',
              subtitle: 'Lanjutkan tulisan dari posisi kursor',
            ),
            _buildAIListTile(
              context,
              icon: Icons.refresh_outlined,
              title: 'Tulis Ulang Pilihan',
              subtitle: 'Revisikan teks yang dipilih',
            ),
            _buildAIListTile(
              context,
              icon: Icons.chat_outlined,
              title: 'Perbaiki Dialog',
              subtitle: 'Buat dialog lebih natural',
            ),
            _buildAIListTile(
              context,
              icon: Icons.expand_outlined,
              title: 'Perluas Adegan',
              subtitle: 'Tambahkan deskripsi dan detail',
            ),
            _buildAIListTile(
              context,
              icon: Icons.description_outlined,
              title: 'Ringkas',
              subtitle: 'Buat ringkasan bab',
            ),
            _buildAIListTile(
              context,
              icon: Icons.verified_outlined,
              title: 'Periksa Kontinuitas',
              subtitle: 'Validasi konsistensi cerita',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAIListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12)),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }

  void _replaceText(String text) {
    _contentController.text = text;
    _save();
  }

  void _insertText(String text) {
    final pos = _contentController.selection.baseOffset;
    final current = _contentController.text;
    _contentController.text = current.replaceRange(pos, pos, '\n$text\n');
  }

  void _copyText(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Disalin ke clipboard', style: TextStyle()),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showRevisionHistory() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Riwayat Revisi', style: TextStyle()),
        content: Text(
          'Fitur riwayat revisi akan ditampilkan di sini.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup', style: TextStyle()),
          ),
        ],
      ),
    );
  }
}
