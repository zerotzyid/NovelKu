import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/novel_model.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import 'home_screen.dart';

class NovelCreateScreen extends ConsumerStatefulWidget {
  const NovelCreateScreen({super.key});

  @override
  ConsumerState<NovelCreateScreen> createState() => _NovelCreateScreenState();
}

class _NovelCreateScreenState extends ConsumerState<NovelCreateScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _genreController = TextEditingController();
  final _themeController = TextEditingController();
  final _backgroundController = TextEditingController();
  final _languageController = TextEditingController(text: 'Indonesia');

  String _selectedGenre = 'Fantasi';
  String _selectedTheme = 'Petualangan';
  final List<String> _genres = [
    'Fantasi',
    'Sci-Fi',
    'Misteri',
    'Romansa',
    'Horor',
    'Petualangan',
    'Sejarah',
    'Fiksi Ilmiah',
    'Thriller',
    'Drama',
    'Komedi',
    'Lainnya',
  ];
  final List<String> _themes = [
    'Petualangan',
    'Persahabatan',
    'Cinta',
    'Kebalasan',
    'Kebangkitan',
    'Kehilangan',
    'Penemuan Diri',
    'Keadilan',
    'Kekuasaan',
    'Misteri',
    'Lainnya',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _genreController.dispose();
    _themeController.dispose();
    _backgroundController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Buat Novel Baru', style: TextStyle(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informasi Novel',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _titleController,
              label: 'Judul Novel',
              hint: 'Masukkan judul novel Anda',
              icon: Icons.title_outlined,
              required: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              label: 'Deskripsi Singkat',
              hint: 'Ceritakan tentang novel Anda secara ringkas',
              icon: Icons.description_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'Genre & Tema',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildGenreChipSelector(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildThemeChipSelector(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Latar Belakang Cerita',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _backgroundController,
              label: 'Latar Belakang',
              hint: 'Dunia, periode waktu, dan latar cerita',
              icon: Icons.location_city_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _languageController,
              label: 'Bahasa',
              hint: 'Indonesia',
              icon: Icons.language_outlined,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _createNovel,
                child: Text(
                  'Buat Novel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    bool required = false,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label + (required ? ' *' : ''),
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
      ),
    );
  }

  Widget _buildGenreChipSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Genre', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _genres.map((g) {
            final selected = _selectedGenre == g;
            return FilterChip(
              label: Text(g, style: TextStyle(fontSize: 12)),
              selected: selected,
              onSelected: (v) => setState(() => _selectedGenre = g),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            );
          }).toList(),
        ),
        if (_selectedGenre == 'Lainnya') ...[
          const SizedBox(height: 8),
          _buildTextField(
            controller: _genreController,
            label: 'Genre Khusus',
            hint: 'Masukkan genre',
            icon: Icons.edit_outlined,
          ),
        ],
      ],
    );
  }

  Widget _buildThemeChipSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tema', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _themes.map((t) {
            final selected = _selectedTheme == t;
            return FilterChip(
              label: Text(t, style: TextStyle(fontSize: 12)),
              selected: selected,
              onSelected: (v) => setState(() => _selectedTheme = t),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _createNovel() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Judul novel wajib diisi', style: TextStyle()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final genre = _selectedGenre == 'Lainnya'
        ? (_genreController.text.trim().isEmpty ? _selectedGenre : _genreController.text.trim())
        : _selectedGenre;

    final novel = NovelModel.create(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      genre: genre,
      theme: _selectedTheme == 'Lainnya' ? null : _selectedTheme,
      background: _backgroundController.text.trim().isEmpty
          ? null
          : _backgroundController.text.trim(),
      language: _languageController.text.trim(),
    );

    await ref.read(novelNotifierProvider.notifier).add(novel);

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }
}
