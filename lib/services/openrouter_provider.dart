import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/ai_config_model.dart';
import 'ai_providers.dart';

class OpenRouterModelInfo {
  final String id;
  final String? name;
  final String? contextLength;
  final String? pricing;

  OpenRouterModelInfo({
    required this.id, this.name, this.contextLength, this.pricing,
  });
}

class OpenRouterProvider implements AIProvider {
  @override
  final String providerName = 'OpenRouter';
  @override
  final AIConfigModel config;

  final http.Client _client;
  final _controller = StreamController<AIResponse>();

  OpenRouterProvider({required this.config, http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<bool> testConnection() async {
    try {
      final uri = Uri.parse('https://openrouter.ai/api/v1/models');
      final request = http.Request('GET', uri)
        ..headers.addAll({'Authorization': 'Bearer ${config.apiKey}'});

      final response = await _client.send(request).timeout(config.timeout);
      if (response.statusCode == 401 || response.statusCode == 403) {
        config.copyWith(isConnected: false, lastError: 'API key tidak valid');
        return false;
      }
      if (response.statusCode >= 200 && response.statusCode < 300) {
        config.copyWith(isConnected: true, lastError: null);
        return true;
      }
      config.copyWith(
        isConnected: false,
        lastError: 'Gagal terhubung (${response.statusCode})',
      );
      return false;
    } catch (e) {
      config.copyWith(isConnected: false, lastError: e.toString());
      return false;
    }
  }

  @override
  Future<List<String>> listModels() async {
    try {
      final uri = Uri.parse('https://openrouter.ai/api/v1/models');
      final response = await _client
          .get(uri, headers: {'Authorization': 'Bearer ${config.apiKey}'})
          .timeout(config.timeout);

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw AIProviderException(
          message: 'API key OpenRouter tidak valid',
          isAuthError: true,
        );
      }
      if (response.statusCode >= 400) {
        throw AIProviderException(
          message: 'Gagal mengambil daftar model (${response.statusCode})',
          statusCode: response.statusCode,
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final list = data['data'] as List<dynamic>?;
      if (list == null) return const [];

      return list
          .map((e) => (e as Map<String, dynamic>)['id'] as String? ?? '')
          .where((id) => id.isNotEmpty)
          .toList();
    } on AIProviderException {
      rethrow;
    } catch (e) {
      throw AIProviderException(message: 'Gagal memuat model: $e');
    }
  }

  @override
  Stream<AIResponse> generateStream({
    required String prompt,
    required String systemPrompt,
    double temperature = 0.7,
    double topP = 1.0,
    int maxTokens = 4096,
  }) async* {
    _controller.add(const AIResponse(text: '', isComplete: false, status: AIRequestStatus.loading));
    try {
      final body = jsonEncode({
        'model': config.modelId,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': prompt},
        ],
        'temperature': temperature,
        'top_p': topP,
        'max_tokens': maxTokens,
        'stream': true,
      });

      final request = http.Request('POST', Uri.parse(config.baseUrl))
        ..headers.addAll({
          'Authorization': 'Bearer ${config.apiKey}',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://novelku.app',
          'X-Title': 'Novelku',
        })
        ..body = body;

      final streamResponse = await _client.send(request).timeout(config.timeout);

      if (streamResponse.statusCode == 401 || streamResponse.statusCode == 403) {
        yield AIResponse.error('API key OpenRouter tidak valid');
        return;
      }
      if (streamResponse.statusCode == 429) {
        yield AIResponse.error('Rate limit tercapai. Coba lagi nanti.');
        return;
      }
      if (streamResponse.statusCode >= 400) {
        yield AIResponse.error('Gagal generate (${streamResponse.statusCode})');
        return;
      }

      final buffer = StringBuffer();
      await for (final chunk in streamResponse.stream.transform(utf8.decoder)) {
        buffer.write(chunk);
        final lines = buffer.toString().split('\n');
        buffer.clear();

        for (final line in lines) {
          final trimmed = line.trim();
          if (!trimmed.startsWith('data:')) continue;
          final payload = trimmed.substring(5).trim();
          if (payload == '[DONE]') continue;

          try {
            final data = jsonDecode(payload) as Map<String, dynamic>;
            final choices = data['choices'] as List<dynamic>?;
            if (choices == null || choices.isEmpty) continue;
            final delta = choices[0]['delta'] as Map<String, dynamic>?;
            final content = delta?['content'] as String?;
            if (content != null && content.isNotEmpty) {
              yield AIResponse.chunk(content);
            }
          } catch (_) {
            continue;
          }
        }
      }

      yield AIResponse.complete(
        text: '', inputTokens: null, outputTokens: null,
      );
    } on AIProviderException {
      rethrow;
    } catch (e) {
      yield AIResponse.error('Kesalahan jaringan: $e');
    }
  }

  @override
  Future<AIResponse> generate({
    required String prompt,
    required String systemPrompt,
    double temperature = 0.7,
    double topP = 1.0,
    int maxTokens = 4096,
  }) async {
    final fullText = StringBuffer();
    int? inputTokens, outputTokens;

    await for (final chunk in generateStream(
      prompt: prompt,
      systemPrompt: systemPrompt,
      temperature: temperature,
      topP: topP,
      maxTokens: maxTokens,
    )) {
      if (chunk.status == AIRequestStatus.error) {
        return chunk;
      }
      if (chunk.text.isNotEmpty) fullText.write(chunk.text);
    }

    return AIResponse.complete(
      text: fullText.toString(),
      inputTokens: inputTokens,
      outputTokens: outputTokens,
    );
  }

  void dispose() {
    _controller.close();
    _client.close();
  }
}
