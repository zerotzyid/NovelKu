import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/story_bible_model.dart';
import '../../models/author_profile_model.dart';
import '../../providers/app_providers.dart';
import '../theme/app_theme.dart';
import 'author_profile_screen.dart';

class StoryBibleScreen extends ConsumerStatefulWidget {
  final String novelId;
  const StoryBibleScreen({super.key, required this.novelId});

  @override
  ConsumerState<StoryBibleScreen> createState() => _StoryBibleScreenState();
}

class _StoryBibleScreenState extends ConsumerState<StoryBibleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _worldNameController = TextEditingController();
  final _worldPeriodController = TextEditingController();
  final _premiseController = TextEditingController();
  final _conflictController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _worldNameController.dispose();
    _worldPeriodController.dispose();
    _premiseController.dispose();
    _conflictController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Story Bible', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colorScheme.primary,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          tabs: const [
            Tab(text: 'Dunia Cerita'),
            Tab(text: 'Karakter'),
            Tab(text: 'Alur Cerita'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWorldTab(),
          _buildCharactersTab(),
          _buildPlotTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Tambah Karakter'),
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
        _buildTextField(
          controller: _worldNameController,
          label: 'Nama Dunia',
          hint: 'Nama dunia cerita',
          icon: Icons.location_city_outlined,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _worldPeriodController,
          label: 'Periode Waktu',
          hint: 'Misal: Abad ke-21, Masa Depan, Era Fantasi',
          icon: Icons.access_time_outlined,
        ),
        const SizedBox(height: 16),
        _buildSection('Sistem Sosial & Budaya', 'Deskripsi sistem sosial dan budaya dunia'),
        const SizedBox(height: 16),
        _buildSection('Aturan Dunia', 'Aturan yang berlaku di dunia cerita'),
        const SizedBox(height: 16),
        _buildSection('Sihir / Teknologi', 'Sistem sihir atau teknologi yang ada'),
        const SizedBox(height: 16),
        _buildSection('Sejarah', 'Sejarah dan peristiwa penting dunia'),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCharactersTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Belum ada karakter', style: TextStyle(fontSize: 16, color: Colors.grey)),
          SizedBox(height: 8),
          Text('Tambah karakter untuk melengkapi Story Bible', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildPlotTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTextField(
          controller: _premiseController,
          label: 'Premis Utama',
          hint: 'Ide inti cerita dalam satu kalimat',
          icon: Icons.lightbulb_outlined,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _conflictController,
          label: 'Konflik Utama',
          hint: 'Konflik sentral yang dihadapi tokoh utama',
          icon: Icons.warning_outlined,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        _buildSection('Subplot', 'Cerita pendukung yang mendukung alur utama'),
        const SizedBox(height: 16),
        _buildSection('Rahasia yang Belum Terungkap', 'Twist dan rahasia dalam cerita'),
        const SizedBox(height: 16),
        _buildSection('Foreshadowing', 'Petunjuk awal tentang peristiwa mendatang'),
        const SizedBox(height: 16),
        _buildSection('Peristiwa yang Sudah Terjadi', 'Riwayat peristiwa dalam cerita'),
        const SizedBox(height: 16),
        _buildSection('Peristiwa yang Direncanakan', 'Peristiwa yang akan terjadi'),
        const SizedBox(height: 16),
        _buildSection('Akhir Cerita yang Dituju', 'Bagaimana cerita berakhir'),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSection(String title, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
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
}
