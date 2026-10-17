import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/author_profile_model.dart';
import '../../providers/app_providers.dart';
import '../theme/app_theme.dart';

class AuthorProfileScreen extends ConsumerStatefulWidget {
  final String? novelId;
  const AuthorProfileScreen({super.key, this.novelId});

  @override
  ConsumerState<AuthorProfileScreen> createState() => _AuthorProfileScreenState();
}

class _AuthorProfileScreenState extends ConsumerState<AuthorProfileScreen> {
  final _nameController = TextEditingController();
  final _customStyleController = TextEditingController();
  final _freeFormController = TextEditingController();
  final _targetWordController = TextEditingController(text: '2000');

  late AuthorProfileModel _profile;
  final _styles = <WritingStyle>{};
  POV _pov = POV.thirdPersonLimited;
  Tense _tense = Tense.past;
  int _paragraphLength = 3;
  int _dialogDensity = 3;
  int _descriptionIntensity = 3;
  int _pacing = 3;
  int _emotionDepth = 3;
  int _vocabComplexity = 3;
  String? _primaryLanguage = 'Indonesia';
  String? _dialogLanguage = 'Indonesia';
  bool _useForeignTerms = false;
  String? _openingStyle;
  String? _closingStyle;
  double _styleConsistency = 0.8;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final repo = ref.read(authorProfileRepositoryProvider);
    final existing = widget.novelId != null
        ? repo.getForNovel(widget.novelId!)
        : repo.all.isNotEmpty ? repo.all.first : null;
    if (existing != null) {
      _profile = existing;
      _nameController.text = existing.name;
      _customStyleController.text = existing.customStyle;
      _freeFormController.text = existing.freeFormInstructions;
      _targetWordController.text = existing.targetWordCountPerChapter.toString();
      _styles.addAll(existing.styles);
      _pov = existing.pointOfView;
      _tense = existing.tense;
      _paragraphLength = existing.paragraphLength;
      _dialogDensity = existing.dialogDensity;
      _descriptionIntensity = existing.descriptionIntensity;
      _pacing = existing.pacing;
      _emotionDepth = existing.emotionDepth;
      _vocabComplexity = existing.vocabularyComplexity;
      _primaryLanguage = existing.primaryLanguage;
      _dialogLanguage = existing.dialogLanguage;
      _useForeignTerms = existing.useForeignTerms;
      _openingStyle = existing.openingStyle;
      _closingStyle = existing.closingStyle;
      _styleConsistency = existing.styleConsistency;
    } else {
      _profile = widget.novelId != null
          ? AuthorProfileModel.createForNovel(novelId: widget.novelId!, name: 'Profil Saya')
          : AuthorProfileModel.createGlobal(name: 'Profil Global');
    }
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _customStyleController.dispose();
    _freeFormController.dispose();
    _targetWordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Kepribadian Penulisan AI', style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: _save,
            tooltip: 'Simpan Profil',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profil Penulisan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Atur gaya penulisan yang menjadi pedoman AI',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),

            // Nama Profil
            _buildTextField(
              controller: _nameController,
              label: 'Nama Profil',
              hint: 'Contoh: Profil Fantasi, Profil Romansa',
              icon: Icons.label_outlined,
              required: true,
            ),
            const SizedBox(height: 20),

            // Gaya Bahasa
            _buildSectionTitle('Gaya Bahasa'),
            const SizedBox(height: 12),
            Text(
              'Pilih satu atau lebih gaya yang Anda sukai',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: WritingStyle.values.map((s) {
                final selected = _styles.contains(s);
                return FilterChip(
                  label: Text(_styleLabel(s), style: TextStyle(fontSize: 12)),
                  selected: selected,
                  onSelected: (v) => setState(() {
                    if (v) _styles.add(s); else _styles.remove(s);
                  }),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                );
              }).toList(),
            ),
            if (_styles.contains(WritingStyle.custom)) ...[
              const SizedBox(height: 12),
              _buildTextField(
                controller: _customStyleController,
                label: 'Gaya Khusus',
                hint: 'Deskripsikan gaya penulisan Anda',
                icon: Icons.edit_outlined,
              ),
            ],
            const SizedBox(height: 20),

            // Instruksi Khusus
            _buildSectionTitle('Instruksi Khusus'),
            const SizedBox(height: 12),
            Text(
              'Contoh: Tulis dengan bahasa Indonesia yang natural, dialog tidak kaku, deskripsi secukupnya',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _freeFormController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Masukkan instruksi bebas untuk AI',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),

            // Parameter Penulisan
            _buildSectionTitle('Parameter Penulisan'),
            const SizedBox(height: 12),
            _buildParamCard(
              title: 'Sudut Pandang',
              child: DropdownButtonFormField<POV>(
                value: _pov,
                items: POV.values.map((p) => DropdownMenuItem(
                  value: p,
                  child: Text(_povLabel(p), style: TextStyle(fontSize: 14)),
                )).toList(),
                onChanged: (v) => setState(() => _pov = v!),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            _buildParamCard(
              title: 'Waktu Penceritaan',
              child: DropdownButtonFormField<Tense>(
                value: _tense,
                items: Tense.values.map((t) => DropdownMenuItem(
                  value: t,
                  child: Text(_tenseLabel(t), style: TextStyle(fontSize: 14)),
                )).toList(),
                onChanged: (v) => setState(() => _tense = v!),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            _buildSliderCard('Panjang Paragraf', _paragraphLength, (v) => setState(() => _paragraphLength = v.round())),
            _buildSliderCard('Kepadatan Dialog', _dialogDensity, (v) => setState(() => _dialogDensity = v.round())),
            _buildSliderCard('Intensitas Deskripsi', _descriptionIntensity, (v) => setState(() => _descriptionIntensity = v.round())),
            _buildSliderCard('Kecepatan Alur', _pacing, (v) => setState(() => _pacing = v.round())),
            _buildSliderCard('Kedalaman Emosi', _emotionDepth, (v) => setState(() => _emotionDepth = v.round())),
            _buildSliderCard('Kompleksitas Kosakata', _vocabComplexity, (v) => setState(() => _vocabComplexity = v.round())),
            _buildSliderCard('Konsistensi Gaya', (_styleConsistency * 10).round(), (v) => setState(() => _styleConsistency = v / 10)),
            _buildParamCard(
              title: 'Target Kata per Bab',
              child: TextField(
                controller: _targetWordController,
                decoration: const InputDecoration(
                  hintText: '2000',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildParamCard({required String title, required Widget child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildSliderCard(String title, int value, void Function(int) onChanged) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                Text('$value/5', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            Slider(
              value: value.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              onChanged: (v) => onChanged(v.round()),
            ),
          ],
        ),
      ),
    );
  }

  String _styleLabel(WritingStyle s) {
    const labels = {
      WritingStyle.formal: 'Formal', WritingStyle.casual: 'Santai',
      WritingStyle.literary: 'Sastra', WritingStyle.poetic: 'Puitis',
      WritingStyle.realistic: 'Realistis', WritingStyle.cinematic: 'Sinematik',
      WritingStyle.descriptive: 'Deskriptif', WritingStyle.minimalist: 'Minimalis',
      WritingStyle.darkMysterious: 'Gelap dan misterius', WritingStyle.comedy: 'Komedi',
      WritingStyle.romantic: 'Romantis', WritingStyle.adventure: 'Petualangan',
      WritingStyle.custom: 'Khusus',
    };
    return labels[s] ?? 'Lainnya';
  }

  String _povLabel(POV p) {
    const labels = {
      POV.firstPerson: 'Orang pertama',
      POV.thirdPersonLimited: 'Orang ketiga terbatas',
      POV.thirdPersonOmniscient: 'Orang ketiga serbatahu',
    };
    return labels[p] ?? 'Orang ketiga';
  }

  String _tenseLabel(Tense t) => t == Tense.past ? 'Lampau' : 'Sekarang';

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (required ? ' *' : ''),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nama profil wajib diisi', style: TextStyle()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final profile = AuthorProfileModel(
      id: _profile.id,
      novelId: widget.novelId,
      name: _nameController.text.trim(),
      styles: _styles.toList(),
      customStyle: _customStyleController.text,
      customInstructions: _freeFormController.text.split('\n').where((e) => e.isNotEmpty).toList(),
      pointOfView: _pov,
      tense: _tense,
      paragraphLength: _paragraphLength,
      dialogDensity: _dialogDensity,
      descriptionIntensity: _descriptionIntensity,
      pacing: _pacing,
      emotionDepth: _emotionDepth,
      vocabularyComplexity: _vocabComplexity,
      targetWordCountPerChapter: int.tryParse(_targetWordController.text) ?? 2000,
      primaryLanguage: _primaryLanguage,
      dialogLanguage: _dialogLanguage,
      useForeignTerms: _useForeignTerms,
      openingStyle: _openingStyle,
      closingStyle: _closingStyle,
      styleConsistency: _styleConsistency,
      freeFormInstructions: _freeFormController.text,
      createdAt: _profile.createdAt,
      updatedAt: DateTime.now(),
    );

    await ref.read(authorProfileRepositoryProvider).save(profile);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil penulis disimpan', style: TextStyle()),
          backgroundColor: Colors.green.shade700,
        ),
      );
      Navigator.pop(context);
    }
  }
}
