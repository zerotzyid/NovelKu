import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/author_profile_model.dart';
import '../../providers/app_providers.dart';

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
    final repo = ref.read(authorProfileRepositoryProvider.notifier);
    // Load existing or create new
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kepribadian Penulisan AI'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _save),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Profil Penulisan', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama profil', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            // Gaya bahasa
            const Text('Gaya Bahasa', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: WritingStyle.values.map((s) {
                final selected = _styles.contains(s);
                return FilterChip(
                  label: Text(_styleLabel(s)),
                  selected: selected,
                  onSelected: (v) => setState(() {
                    if (v) _styles.add(s); else _styles.remove(s);
                  }),
                );
              }).toList(),
            ),
            if (_styles.contains(WritingStyle.custom)) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _customStyleController,
                decoration: const InputDecoration(labelText: 'Gaya khusus', border: OutlineInputBorder()),
              ),
            ],
            const SizedBox(height: 16),

            // Custom instructions
            const Text('Instruksi Khusus', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
            const SizedBox(height: 8),
            TextField(
              controller: _freeFormController,
              decoration: const InputDecoration(
                labelText: 'Instruksi bebas',
                hintText: 'Contoh: Tulis dengan bahasa Indonesia yang natural, dialog tidak kaku...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Parameter penulisan (kartu)
            const Text('Parameter Penulisan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
            const SizedBox(height: 8),
            _buildParamCard(
              title: 'Sudut Pandang',
              child: DropdownButtonFormField<POV>(
                value: _pov,
                items: POV.values.map((p) => DropdownMenuItem(
                  value: p,
                  child: Text(_povLabel(p)),
                )).toList(),
                onChanged: (v) => setState(() => _pov = v!),
              ),
            ),
            _buildParamCard(
              title: 'Waktu Penceritaan',
              child: DropdownButtonFormField<Tense>(
                value: _tense,
                items: Tense.values.map((t) => DropdownMenuItem(
                  value: t,
                  child: Text(_tenseLabel(t)),
                )).toList(),
                onChanged: (v) => setState(() => _tense = v!),
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
                decoration: const InputDecoration(hintText: '2000', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildParamCard({required String title, required Widget child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text('$value/5', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            Slider(value: value.toDouble(), min: 1, max: 5, divisions: 4, onChanged: (v) => onChanged(v.round())),
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

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama profil wajib diisi')));
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

    await ref.read(authorProfileRepositoryProvider.notifier).save(profile);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil penulis disimpan')));
      Navigator.pop(context);
    }
  }
}
