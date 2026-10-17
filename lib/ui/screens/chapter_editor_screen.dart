import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/author_profile_model.dart';
import '../../models/chapter_model.dart';
import '../../models/story_bible_model.dart';
import '../../providers/app_providers.dart';
import '../../services/ai_providers.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Bab ${widget.chapter.number}: ${widget.chapter.title}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: () => _showAIMenu(context),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'save') _save();
              if (value == 'revision') _showRevisionHistory();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'save', child: Text('Simpan')),
              PopupMenuItem(value: 'revision', child: Text('Riwayat Revisi')),
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
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          if (status == AIRequestStatus.streaming || status == AIRequestStatus.loading)
            const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text('${_contentController.text.split(' ').length} kata'),
                const Spacer(),
                if (generated.isNotEmpty && status != AIRequestStatus.streaming)
                  AIActionButton(
                    label: 'Ganti Teks',
                    onPressed: () => _replaceText(generated),
                    icon: Icons.replace,
                  ),
                if (generated.isNotEmpty && status != AIRequestStatus.streaming)
                  AIActionButton(
                    label: 'Sisipkan',
                    onPressed: () => _insertText(generated),
                    icon: Icons.add,
                  ),
                if (generated.isNotEmpty && status != AIRequestStatus.streaming)
                  AIActionButton(
                    label: 'Salin',
                    onPressed: () => _copyText(generated),
                    icon: Icons.copy,
                  ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
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
      const SnackBar(content: Text('Disimpan')),
    );
  }

  void _showAIMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          ListTile(title: Text('Tulis dengan AI'), leading: Icon(Icons.auto_awesome)),
          ListTile(title: Text('Lanjutkan dari sini'), leading: Icon(Icons.play_arrow)),
          ListTile(title: Text('Tulis ulang pilihan'), leading: Icon(Icons.refresh)),
          ListTile(title: Text('Perbaiki dialog'), leading: Icon(Icons.chat)),
          ListTile(title: Text('Perluas adegan'), leading: Icon(Icons.expand)),
          ListTile(title: Text('Ringkas'), leading: Icon(Icons.summary)),
          ListTile(title: Text('Periksa kontinuitas'), leading: Icon(Icons.verified)),
        ],
      ),
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
    // Clipboard copy would go here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Disalin ke clipboard')),
    );
  }

  void _showRevisionHistory() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Riwayat Revisi'),
        content: const Text('Fitur riwayat revisi akan ditampilkan di sini.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
        ],
      ),
    );
  }
}
