import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ai_config_model.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';

class AISettingsScreen extends ConsumerStatefulWidget {
  const AISettingsScreen({super.key});

  @override
  ConsumerState<AISettingsScreen> createState() => _AISettingsScreenState();
}

class _AISettingsScreenState extends ConsumerState<AISettingsScreen> {
  AIProviderType _provider = AIProviderType.openRouter;
  final _apiKeyController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _modelController = TextEditingController();
  final _systemPromptController = TextEditingController();
  final _temperatureController = TextEditingController(text: '0.7');
  final _maxTokensController = TextEditingController(text: '4096');
  bool _isTesting = false;
  String? _testResult;
  bool _advanced = false;
  List<String> _models = const [];
  bool _loadingModels = false;

  static const Map<AIProviderType, Map<String, String>> _providerDefaults = {
    AIProviderType.openRouter: {
      'baseUrl': 'https://openrouter.ai/api/v1/chat/completions',
      'placeholder': 'openai/gpt-4o-mini',
    },
    AIProviderType.nvidiaNim: {
      'baseUrl': 'https://integrate.api.nvidia.com/v1/chat/completions',
      'placeholder': 'nvidia/llama-3.1-nemotron-70b-instruct',
    },
    AIProviderType.customOpenAI: {
      'baseUrl': 'https://api.endpoint.com/v1/chat/completions',
      'placeholder': 'model-id',
    },
  };

  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _modelController.dispose();
    _systemPromptController.dispose();
    _temperatureController.dispose();
    _maxTokensController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final config = ref.watch(aiConfigNotifierProvider);
    final notifier = ref.read(aiConfigNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('Pengaturan AI', style: TextStyle(fontWeight: FontWeight.w600)),
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
              'Konfigurasi AI',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pilih penyedia AI untuk menghasilkan bab novel',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Provider Selection
            _buildSectionTitle('Penyedia AI'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildProviderChip(
                    AIProviderType.openRouter,
                    'OpenRouter',
                    Icons.web_outlined,
                    'Model AI terbaik dari berbagai penyedia',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildProviderChip(
                    AIProviderType.nvidiaNim,
                    'NVIDIA NIM',
                    Icons.memory_outlined,
                    'Model NVIDIA Nemotron dan lainnya',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: _buildProviderChip(
                AIProviderType.customOpenAI,
                'Custom LLM API',
                Icons.extension_outlined,
                'Endpoint OpenAI-compatible sendiri',
                fullWidth: true,
              ),
            ),
            const SizedBox(height: 24),

            // API Key
            _buildSectionTitle('API Key'),
            const SizedBox(height: 12),
            TextField(
              controller: _apiKeyController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'API Key',
                hintText: 'Masukkan API key Anda',
                prefixIcon: const Icon(Icons.key_outlined, size: 20),
                suffixText: _provider == AIProviderType.openRouter || _provider == AIProviderType.nvidiaNim
                    ? 'sk-'
                    : null,
              ),
            ),
            const SizedBox(height: 16),

            // Base URL (for custom and NVIDIA)
            if (_provider == AIProviderType.customOpenAI || _provider == AIProviderType.nvidiaNim) ...[
              _buildSectionTitle('Base URL'),
              const SizedBox(height: 12),
              TextField(
                controller: _baseUrlController..text = _baseUrlController.text.isEmpty
                    ? _providerDefaults[_provider]!['baseUrl']!
                    : _baseUrlController.text,
                decoration: InputDecoration(
                  labelText: 'Base URL',
                  hintText: _providerDefaults[_provider]!['baseUrl']!,
                  prefixIcon: const Icon(Icons.link_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Model
            _buildSectionTitle('Model'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _modelController,
                    decoration: InputDecoration(
                      labelText: 'ID Model',
                      hintText: _providerDefaults[_provider]!['placeholder']!,
                      prefixIcon: const Icon(Icons.model_training_outlined, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: _loadingModels
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_outlined),
                  onPressed: _loadingModels ? null : () => _loadModels(notifier),
                  tooltip: 'Muat Daftar Model',
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_models.isNotEmpty)
              Wrap(
                spacing: 8,
                children: _models.take(6).map((m) => ChoiceChip(
                  label: Text(m, style: TextStyle(fontSize: 11)),
                  selected: _modelController.text == m,
                  onSelected: (v) => setState(() => _modelController.text = m),
                )).toList(),
              ),
            const SizedBox(height: 16),

            // Advanced toggle
            InkWell(
              onTap: () => setState(() => _advanced = !_advanced),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pengaturan Lanjutan',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Icon(
                    _advanced ? Icons.expand_less : Icons.expand_more,
                    color: colorScheme.primary,
                  ),
                ],
              ),
            ),
            if (_advanced) ...[
              const SizedBox(height: 12),
              _buildAdvancedSection(colorScheme),
              const SizedBox(height: 16),
            ],

            // Test Connection
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: _isTesting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.wifi_outlined),
                label: Text(_isTesting ? 'Menguji...' : 'Tes Koneksi'),
                onPressed: _isTesting ? null : () => _testConnection(notifier),
              ),
            ),
            if (_testResult != null) ...[
              const SizedBox(height: 8),
              Text(
                _testResult!,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: _testResult!.toLowerCase().contains('berhasil') ||
                          _testResult!.toLowerCase().contains('sukses')
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _isTesting ? null : () => _save(config, notifier),
                child: Text(
                  'Simpan Konfigurasi & Mulai Menulis',
                  style: GoogleFonts.poppins(
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildProviderChip(
    AIProviderType type,
    String label,
    IconData icon, [
    String? subtitle,
    bool fullWidth = false,
  ]) {
    final selected = _provider == type;
    final colorScheme = Theme.of(context).colorScheme;

    return ChoiceChip(
      label: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: selected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: selected ? colorScheme.onPrimary.withOpacity(0.8) : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
      selected: selected,
      onSelected: (v) => setState(() => _provider = type),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      selectedColor: colorScheme.primary,
      labelStyle: TextStyle(fontSize: 12),
    );
  }

  Widget _buildAdvancedSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mode Lanjutan',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        if (_provider == AIProviderType.customOpenAI)
          TextField(
            controller: _baseUrlController..text = _baseUrlController.text.isEmpty
                ? 'https://api.endpoint.com/v1/chat/completions'
                : _baseUrlController.text,
            decoration: InputDecoration(
              labelText: 'Base URL',
              hintText: 'https://api.endpoint.com/v1',
              prefixIcon: const Icon(Icons.link_outlined, size: 20),
            ),
          ),
        if (_provider == AIProviderType.customOpenAI) const SizedBox(height: 12),
        TextField(
          controller: _systemPromptController,
          decoration: InputDecoration(
            labelText: 'System Prompt',
            hintText: 'Instruksi sistem untuk AI',
            prefixIcon: const Icon(Icons.text_fields_outlined, size: 20),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _temperatureController,
                decoration: InputDecoration(
                  labelText: 'Temperature',
                  hintText: '0.7',
                  prefixIcon: const Icon(Icons.tune_outlined, size: 20),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _maxTokensController,
                decoration: InputDecoration(
                  labelText: 'Max Tokens',
                  hintText: '4096',
                  prefixIcon: const Icon(Icons.numbers_outlined, size: 20),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _loadModels(AIConfigNotifier notifier) async {
    if (_apiKeyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('API key wajib diisi terlebih dahulu', style: TextStyle()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    setState(() { _loadingModels = true; });
    try {
      final models = await notifier.listModels();
      setState(() { _models = models; });
      if (_models.isNotEmpty && _modelController.text.isEmpty) {
        _modelController.text = _models.first;
      }
    } catch (e) {
      setState(() { _testResult = 'Gagal memuat model: $e'; });
    } finally {
      setState(() { _loadingModels = false; });
    }
  }

  Future<void> _testConnection(AIConfigNotifier notifier) async {
    setState(() { _isTesting = true; _testResult = null; });
    try {
      final ok = await notifier.testConnection();
      setState(() { _testResult = ok ? 'Koneksi berhasil' : 'Koneksi gagal'; });
    } catch (e) {
      setState(() { _testResult = 'Error: $e'; });
    } finally {
      setState(() { _isTesting = false; });
    }
  }

  Future<void> _save(AIConfigModel? existing, AIConfigNotifier notifier) async {
    if (_apiKeyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('API key wajib diisi', style: TextStyle()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    if (_modelController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Model wajib diisi', style: TextStyle()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final baseUrl = _baseUrlController.text.trim().isEmpty
        ? _providerDefaults[_provider]!['baseUrl']!
        : _baseUrlController.text.trim();

    AIConfigModel config;
    switch (_provider) {
      case AIProviderType.openRouter:
        config = AIConfigModel.createOpenRouter(
          apiKey: _apiKeyController.text.trim(),
          modelId: _modelController.text.trim(),
          modelName: _modelController.text.trim(),
        );
      case AIProviderType.nvidiaNim:
        config = AIConfigModel.createNvidiaNim(
          apiKey: _apiKeyController.text.trim(),
          modelId: _modelController.text.trim(),
          modelName: _modelController.text.trim(),
        );
      case AIProviderType.customOpenAI:
        config = AIConfigModel.createCustom(
          baseUrl: baseUrl,
          apiKey: _apiKeyController.text.trim(),
          modelId: _modelController.text.trim(),
        );
    }

    if (_advanced) {
      config = config.copyWith(
        systemPrompt: _systemPromptController.text.trim().isEmpty
            ? null
            : _systemPromptController.text.trim(),
        temperature: double.tryParse(_temperatureController.text) ?? 0.7,
        maxTokens: int.tryParse(_maxTokensController.text) ?? 4096,
        setupMode: AISetupMode.advanced,
      );
    }

    await notifier.save(config);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Konfigurasi AI disimpan', style: TextStyle()),
          backgroundColor: Colors.green.shade700,
        ),
      );
      Navigator.pop(context);
    }
  }
}
