import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

final _uuid = const Uuid();

enum AIProviderType { openRouter, nvidiaNim, customOpenAI }

enum AISetupMode { simple, advanced }

class AIConfigModel extends Equatable {
  final String id;
  final AIProviderType providerType;
  final String apiKey;
  final String baseUrl;
  final String modelId;
  final String? modelName;
  final String? modelCapabilities;
  final AISetupMode setupMode;
  final Map<String, String> customHeaders;
  final double temperature;
  final double topP;
  final int maxTokens;
  final String? systemPrompt;
  final Duration timeout;
  final bool isConnected;
  final DateTime? lastTestedAt;
  final String? lastError;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AIConfigModel({
    required this.id,
    required this.providerType,
    required this.apiKey,
    required this.baseUrl,
    required this.modelId,
    this.modelName,
    this.modelCapabilities,
    required this.setupMode,
    this.customHeaders = const {},
    this.temperature = 0.7,
    this.topP = 1.0,
    this.maxTokens = 4096,
    this.systemPrompt,
    this.timeout = const Duration(seconds: 60),
    this.isConnected = false,
    this.lastTestedAt,
    this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AIConfigModel.createOpenRouter({
    required String apiKey,
    required String modelId,
    String? modelName,
  }) {
    final now = DateTime.now();
    return AIConfigModel(
      id: _uuid.v4(),
      providerType: AIProviderType.openRouter,
      apiKey: apiKey,
      baseUrl: 'https://openrouter.ai/api/v1/chat/completions',
      modelId: modelId,
      modelName: modelName,
      setupMode: AISetupMode.simple,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory AIConfigModel.createNvidiaNim({
    required String apiKey,
    required String modelId,
    String? modelName,
  }) {
    final now = DateTime.now();
    return AIConfigModel(
      id: _uuid.v4(),
      providerType: AIProviderType.nvidiaNim,
      apiKey: apiKey,
      baseUrl: 'https://integrate.api.nvidia.com/v1/chat/completions',
      modelId: modelId,
      modelName: modelName,
      customHeaders: {
        'Authorization': 'Bearer $apiKey',
      },
      setupMode: AISetupMode.simple,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory AIConfigModel.createCustom({
    required String baseUrl,
    required String apiKey,
    required String modelId,
    Map<String, String>? customHeaders,
  }) {
    final now = DateTime.now();
    return AIConfigModel(
      id: _uuid.v4(),
      providerType: AIProviderType.customOpenAI,
      apiKey: apiKey,
      baseUrl: baseUrl,
      modelId: modelId,
      customHeaders: customHeaders ?? const {},
      setupMode: AISetupMode.advanced,
      createdAt: now,
      updatedAt: now,
    );
  }

  AIConfigModel copyWith({
    String? id,
    AIProviderType? providerType,
    String? apiKey,
    String? baseUrl,
    String? modelId,
    String? modelName,
    String? modelCapabilities,
    AISetupMode? setupMode,
    Map<String, String>? customHeaders,
    double? temperature,
    double? topP,
    int? maxTokens,
    String? systemPrompt,
    Duration? timeout,
    bool? isConnected,
    DateTime? lastTestedAt,
    String? lastError,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => AIConfigModel(
    id: id ?? this.id,
    providerType: providerType ?? this.providerType,
    apiKey: apiKey ?? this.apiKey,
    baseUrl: baseUrl ?? this.baseUrl,
    modelId: modelId ?? this.modelId,
    modelName: modelName ?? this.modelName,
    modelCapabilities: modelCapabilities ?? this.modelCapabilities,
    setupMode: setupMode ?? this.setupMode,
    customHeaders: customHeaders ?? this.customHeaders,
    temperature: temperature ?? this.temperature,
    topP: topP ?? this.topP,
    maxTokens: maxTokens ?? this.maxTokens,
    systemPrompt: systemPrompt ?? this.systemPrompt,
    timeout: timeout ?? this.timeout,
    isConnected: isConnected ?? this.isConnected,
    lastTestedAt: lastTestedAt ?? this.lastTestedAt,
    lastError: lastError ?? this.lastError,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, dynamic> toJson() => {
        'id': id,
        'providerType': providerType.index,
        'apiKey': apiKey,
        'baseUrl': baseUrl,
        'modelId': modelId,
        'modelName': modelName,
        'modelCapabilities': modelCapabilities,
        'setupMode': setupMode.index,
        'customHeaders': customHeaders,
        'temperature': temperature,
        'topP': topP,
        'maxTokens': maxTokens,
        'systemPrompt': systemPrompt,
        'timeout': timeout.inSeconds,
        'isConnected': isConnected,
        'lastTestedAt': lastTestedAt?.toIso8601String(),
        'lastError': lastError,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory AIConfigModel.fromJson(Map<String, dynamic> json) => AIConfigModel(
    id: json['id'],
    providerType: AIProviderType.values[json['providerType'] as int],
    apiKey: json['apiKey'],
    baseUrl: json['baseUrl'],
    modelId: json['modelId'],
    modelName: json['modelName'],
    modelCapabilities: json['modelCapabilities'],
    setupMode: AISetupMode.values[json['setupMode'] as int],
    customHeaders: Map<String, String>.from(json['customHeaders'] ?? const {}),
    temperature: (json['temperature'] as num).toDouble(),
    topP: (json['topP'] as num).toDouble(),
    maxTokens: json['maxTokens'] as int,
    systemPrompt: json['systemPrompt'],
    timeout: Duration(seconds: json['timeout'] as int),
    isConnected: json['isConnected'] as bool? ?? false,
    lastTestedAt: json['lastTestedAt'] != null
        ? DateTime.parse(json['lastTestedAt']) : null,
    lastError: json['lastError'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );

  String get maskedApiKey {
    if (apiKey.isEmpty) return '';
    if (apiKey.length <= 8) return '****';
    return '${apiKey.substring(0, 4)}****${apiKey.substring(apiKey.length - 4)}';
  }

  String get providerLabel {
    switch (providerType) {
      case AIProviderType.openRouter:
        return 'OpenRouter';
      case AIProviderType.nvidiaNim:
        return 'NVIDIA NIM';
      case AIProviderType.customOpenAI:
        return 'Custom LLM API';
    }
  }

  @override
  List<Object?> get props => [id, providerType, apiKey, baseUrl, modelId,
    modelName, modelCapabilities, setupMode, customHeaders, temperature,
    topP, maxTokens, systemPrompt, timeout, isConnected, lastTestedAt,
    lastError, createdAt, updatedAt];
}
