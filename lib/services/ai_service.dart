import 'dart:async';
import '../models/chat_message.dart';
import 'gemini_api_client.dart';
import 'sage_prompt_builder.dart';

enum AiErrorType { apiKey, auth, rateLimit, timeout, server, network, invalidResponse, unknown }

/// Exception thrown when AI service encounters an error.
class AiException implements Exception {
  final AiErrorType type;
  final String message;
  final Object? originalError;
  const AiException(this.type, this.message, {this.originalError});

  @override
  String toString() => 'AiException($type): $message';
}

/// Abstract interface for AI text generation services.
abstract class AiService {
  Future<String> generate(
    List<ChatMessage> messages, {
    String userName = '',
    int userLevel = 1,
    int currentStreak = 0,
    List<String> weakTopics = const [],
  });
  Stream<String> generateStream(
    List<ChatMessage> messages, {
    String userName = '',
    int userLevel = 1,
    int currentStreak = 0,
    List<String> weakTopics = const [],
  });
  void dispose();
  bool get isAvailable;
}

/// AI service implementation using Google Gemini API.
class GeminiAiService implements AiService {
  final GeminiApiClient _client;
  final SagePromptBuilder _promptBuilder;

  GeminiAiService([GeminiApiClient? client])
      : _client = client ?? GeminiApiClient(),
        _promptBuilder = SagePromptBuilder() {
    _client.init();
  }

  @override
  bool get isAvailable => _client.isAvailable;

  @override
  void dispose() {
    _client.dispose();
  }

  @override
  Future<String> generate(
    List<ChatMessage> messages, {
    String userName = '',
    int userLevel = 1,
    int currentStreak = 0,
    List<String> weakTopics = const [],
  }) async {
    final contents = _promptBuilder.buildContents(messages);
    return _client.generate(
      contents,
      userName: userName,
      userLevel: userLevel,
      currentStreak: currentStreak,
      weakTopics: weakTopics,
    );
  }

  @override
  Stream<String> generateStream(
    List<ChatMessage> messages, {
    String userName = '',
    int userLevel = 1,
    int currentStreak = 0,
    List<String> weakTopics = const [],
  }) async* {
    final contents = _promptBuilder.buildContents(messages);
    yield* _client.generateStream(
      contents,
      userName: userName,
      userLevel: userLevel,
      currentStreak: currentStreak,
      weakTopics: weakTopics,
    );
  }
}
