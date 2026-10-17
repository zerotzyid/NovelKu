import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/ai_config_model.dart';
import '../../providers/app_providers.dart';

class AISettingsScreen extends ConsumerStatefulWidget {
  const AISettingsScreen({super.key});

  @override
  ConsumerState<AISettingsScreen> createState() => _AISettingsScreenState();
}

class _AISettingsScreenState extends ConsumerState<AISettingsScreen> {
  AIProviderType _provider = AIProviderType.openRouter;
  final _apiKeyController = TextEditingController();
  final _baseUrlController = TextEditingController(text: 'https://openrouter.ai/api/v1/chat/completions');
  final _modelController = TextEditingController();
  bool _isTesting = false;
  String? _testResult;
  final _systemPromptController = TextEditingController();
  final _temperatureController = TextEditingController(text: '0.7');
  final _maxTokensController = TextEditingController(text: '4096');

  List<String> _models = const [];
  bool _loadingModels = false;

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
    final config = ref.watch(aiConfigNotifierProvider);
    final notifier = ref.read(aiConfigNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan AI'),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Setup AI', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Konfigurasikan penyedia AI untuk menghasilkan bab novel.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),

            // Step 1: Provider
            _buildProviderSelector(),
            const SizedBox(height: 16),

            // Step 2: API Key
            _buildApiKeyField(),
            const SizedBox(height: 16),

            // Step 3: Model
            _buildModelField(notifier),
            const SizedBox(height: 16),

            // Advanced toggle
            if (_provider == AIProviderType.customOpenAI || _advanced)
              _buildAdvancedSection(),

            const SizedBox(height: 16),

            // Test connection
            _buildTestButton(notifier),
            if (_testResult != null) ...[
              const SizedBox(height: 8),
              Text(_testResult!, style: TextStyle(color: _testResult!.contains('sukses') || _testResult!.contains('Berhasil') ? Colors.green : Colors.red)),
            ],

            const Spacer(),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Simpan Konfigurasi & Mulai Menulis'),
                onPressed: _isTesting ? null : () => _save(config, notifier),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Penyedia AI', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Text('OpenRouter'),
                selected: _provider == AIProviderType.openRouter,
                onSelected: (_) => setState(() => _provider = AIProviderType.openRouter),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                label: const Text('Endpoint Custom'),
                selected: _provider == AIProviderType.customOpenAI,
                onSelected: (_) => setState(() => _provider = AIProviderType.customOpenAI),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildApiKeyField() {
    return TextField(
      controller: _apiKeyController,
      obscureText: true,
      decoration: const InputDecoration(
        labelText: 'API Key',
        hintText: 'Masukkan API key Anda',
        border: OutlineInputBorder(),
        prefixText: 'sk-',
      ),
    );
  }

  Widget _buildModelField(AIConfigNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Model', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'ID Model',
                  hintText: 'Misal: openai/gpt-4o-mini',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: _loadingModels ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.refresh),
              onPressed: _loadingModels ? null : () => _loadModels(notifier),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdvancedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text('Mode Lanjutan', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        if (_provider == AIProviderType.customOpenAI)
          TextField(
            controller: _baseUrlController,
            decoration: const InputDecoration(
              labelText: 'Base URL',
              hintText: 'https://api.endpoint.com/v1',
              border: OutlineInputBorder(),
            ),
          ),
        if (_provider == AIProviderType.customOpenAI) const SizedBox(height: 8),
        TextField(
          controller: _systemPromptController,
          decoration: const InputDecoration(
            labelText: 'System Prompt',
            hintText: 'Instruksi sistem untuk AI',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: TextField(
              controller: _temperatureController,
              decoration: const InputDecoration(labelText: 'Temperature', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            )),
            const SizedBox(width: 8),
            Expanded(child: TextField(
              controller: _maxTokensController,
              decoration: const InputDecoration(labelText: 'Max Tokens', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildTestButton(AIConfigNotifier notifier) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: _isTesting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.wifi),
        label: Text(_isTesting ? 'Menguji...' : 'Tes Koneksi'),
        onPressed: _isTesting ? null : () => _testConnection(notifier),
      ),
    );
  }

  Future<void> _loadModels(AIConfigNotifier notifier) async {
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('API key wajib diisi')));
      return;
    }
    if (_modelController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Model wajib diisi')));
      return;
    }

    final config = AIConfigModel.createOpenRouter(
      apiKey: _apiKeyController.text.trim(),
      modelId: _modelController.text.trim(),
      modelName: _modelController.text.trim(),
    );

    if (_provider == AIProviderType.customOpenAI) {
      config.copyWith(
        providerType: AIProviderType.customOpenAI,
        baseUrl: _baseUrlController.text.trim(),
        customHeaders: const {},
      );
    }

    await notifier.save(config);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konfigurasi AI disimpan')));
      Navigator.pop(context);
    }
  }
}
