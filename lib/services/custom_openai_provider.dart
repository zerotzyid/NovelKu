import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/ai_config_model.dart';
import 'ai_providers.dart';
import 'nvidia_provider.dart';
import 'openrouter_provider.dart';

class CustomOpenAIProvider implements AIProvider {
  @override
  final String providerName = 'Custom OpenAI-compatible';
  @override
  final AIConfigModel config;

  final http.Client _client;

  CustomOpenAIProvider({required this.config, http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<bool> testConnection() async {
    try {
      final base = config.baseUrl.replaceAll(RegExp(r'/+$'), '');
      final endpoint = '$base/chat/completions';
      if (!_isValidUrl(endpoint)) {
        config.copyWith(isConnected: false, lastError: 'URL tidak valid');
        return false;
      }

      final body = jsonEncode({
        'model': config.modelId,
        'messages': [
          {'role': 'user', 'content': 'Connection test'}
        ],
        'max_tokens': 5,
        'temperature': 0.1,
        'stream': false,
      });

      final headers = <String, String>{
        'Authorization': 'Bearer ${config.apiKey}',
        'Content-Type': 'application/json',
      };
      headers.addAll(config.customHeaders);

      final response = await _client
          .post(Uri.parse(endpoint), headers: headers, body: body)
          .timeout(config.timeout);

      if (response.statusCode == 401 || response.statusCode == 403) {
        config.copyWith(isConnected: false, lastError: 'Autentikasi gagal');
        return false;
      }
      if (response.statusCode == 429) {
        config.copyWith(isConnected: false, lastError: 'Rate limit');
        return false;
      }
      if (response.statusCode >= 200 && response.statusCode < 300) {
        config.copyWith(isConnected: true, lastError: null);
        return true;
      }

      config.copyWith(
        isConnected: false,
        lastError: 'Server merespons (${response.statusCode})',
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
      final base = config.baseUrl.replaceAll(RegExp(r'/+$'), '');
      final endpoint = '$base/models';

      final headers = <String, String>{
        'Authorization': 'Bearer ${config.apiKey}',
        'Content-Type': 'application/json',
      };
      headers.addAll(config.customHeaders);

      final response = await _client
          .get(Uri.parse(endpoint), headers: headers)
          .timeout(config.timeout);

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw AIProviderException(message: 'API key tidak valid', isAuthError: true);
      }
      if (response.statusCode >= 400) {
        throw AIProviderException(
          message: 'Gagal mengambil model (${response.statusCode})',
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
    try {
      final base = config.baseUrl.replaceAll(RegExp(r'/+$'), '');
      final endpoint = '$base/chat/completions';
      if (!_isValidUrl(endpoint)) {
        yield AIResponse.error('URL endpoint tidak valid');
        return;
      }

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

      final headers = <String, String>{
        'Authorization': 'Bearer ${config.apiKey}',
        'Content-Type': 'application/json',
      };
      headers.addAll(config.customHeaders);

      final request = http.Request('POST', Uri.parse(endpoint))
        ..headers.addAll(headers)
        ..body = body;

      final streamResponse = await _client.send(request).timeout(config.timeout);

      if (streamResponse.statusCode == 401 || streamResponse.statusCode == 403) {
        yield AIResponse.error('Autentikasi gagal');
        return;
      }
      if (streamResponse.statusCode == 429) {
        yield AIResponse.error('Rate limit tercapai');
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

      yield AIResponse.complete(text: '', inputTokens: null, outputTokens: null);
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
      inputTokens: null,
      outputTokens: null,
    );
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (_) {
      return false;
    }
  }
}

class AIProviderFactory {
  static AIProvider create(AIConfigModel config) {
    switch (config.providerType) {
      case AIProviderType.openRouter:
        return OpenRouterProvider(config: config);
      case AIProviderType.nvidiaNim:
        return NvidiaNimProvider(config: config);
      case AIProviderType.customOpenAI:
        return CustomOpenAIProvider(config: config);
    }
  }
}
