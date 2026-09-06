import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import '../config/app_config.dart';
import 'ai_service.dart';
import 'api_client.dart';
import 'app_logger.dart';
import 'sage_prompt_builder.dart';

/// Gemini API client that proxies all requests through a Cloud Function.
/// The API key is NEVER exposed to the client binary.
class GeminiApiClient {
  final AppLogger _logger;
  final ApiClient _apiClient;
  final SagePromptBuilder _promptBuilder = SagePromptBuilder();
  final Random _jitter = Random();
  FirebaseFunctions? _functions;

  // Client-side rate limiting: max 10 requests per minute
  static const int _maxRequestsPerMinute = 10;
  final List<DateTime> _requestTimestamps = [];

  GeminiApiClient({AppLogger? logger, ApiClient? apiClient})
    : _logger = logger ?? AppLogger(),
      _apiClient = apiClient ?? ApiClient.instance;

  bool get isAvailable => true;

  int get _maxRetries => AppConfig.geminiMaxRetries;

  FirebaseFunctions get _getFunctions =>
      _functions ??= FirebaseFunctions.instance;

  void init() {
    _logger.info('GeminiApiClient: initialized via Cloud Function proxy');
  }

  Future<String> generate(
    List<Map<String, dynamic>> contents, {
    String userName = '',
    int userLevel = 1,
    int currentStreak = 0,
    List<String> weakTopics = const [],
  }) async {
    // Client-side rate limiting
    final now = DateTime.now();
    _requestTimestamps.removeWhere((t) => now.difference(t).inMinutes >= 1);
    if (_requestTimestamps.length >= _maxRequestsPerMinute) {
      throw const AiException(
        AiErrorType.rateLimit,
        'Too many requests. Wait a moment before trying again.',
      );
    }
    _requestTimestamps.add(now);

    for (int attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        final systemPrompt = _promptBuilder.buildSystemInstruction(
          userName: userName,
          userLevel: userLevel,
          currentStreak: currentStreak,
          weakTopics: weakTopics,
        );

        final result = await _getFunctions
            .httpsCallable('generateContent')
            .call({'contents': contents, 'systemInstruction': systemPrompt})
            .timeout(AppConfig.geminiTimeout);

        final text = result.data['text'] as String?;
        if (text == null || text.trim().isEmpty) {
          throw const AiException(
            AiErrorType.invalidResponse,
            'Gemini returned an empty response.',
          );
        }
        return text;
      } on TimeoutException {
        throw const AiException(
          AiErrorType.timeout,
          'Gemini took too long to respond.',
        );
      } on AiException {
        rethrow;
      } on FirebaseFunctionsException catch (e) {
        if (attempt < _maxRetries && _shouldRetry(e)) {
          final base = AppConfig.geminiRetryDelay * (attempt + 1);
          final jitter = Duration(milliseconds: _jitter.nextInt(1000));
          await Future.delayed(base + jitter);
          continue;
        }
        throw _mapFunctionsError(e);
      } catch (e) {
        throw AiException(
          AiErrorType.unknown,
          'Unexpected error contacting Gemini.',
          originalError: e,
        );
      }
    }
    throw const AiException(AiErrorType.unknown, 'Gemini: max retries reached');
  }

  Stream<String> generateStream(
    List<Map<String, dynamic>> contents, {
    String userName = '',
    int userLevel = 1,
    int currentStreak = 0,
    List<String> weakTopics = const [],
  }) async* {
    // Client-side rate limiting (same as generate())
    final now = DateTime.now();
    _requestTimestamps.removeWhere((t) => now.difference(t).inMinutes >= 1);
    if (_requestTimestamps.length >= _maxRequestsPerMinute) {
      throw const AiException(
        AiErrorType.rateLimit,
        'Too many requests. Wait a moment before trying again.',
      );
    }
    _requestTimestamps.add(now);

    bool yielded = false;
    for (int attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        final systemPrompt = _promptBuilder.buildSystemInstruction(
          userName: userName,
          userLevel: userLevel,
          currentStreak: currentStreak,
          weakTopics: weakTopics,
        );

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw const AiException(AiErrorType.auth, 'No authenticated user.');
        }
        final token = await user.getIdToken();

        final projectId = FirebaseFunctions.instanceFor(
          region: 'us-central1',
        ).app.options.projectId;
        final url = Uri.parse(
          'https://us-central1-$projectId.cloudfunctions.net/generateContentStream',
        );

        final request = ApiRequest(
          method: 'POST',
          uri: url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'contents': contents,
            'systemInstruction': systemPrompt,
          }),
          timeout: const Duration(seconds: 90),
        );

        String buffer = '';
        await for (final chunk in _apiClient.sendStreaming(request)) {
          buffer += chunk;
          final lines = buffer.split('\n');
          buffer = lines.removeLast();

          for (final line in lines) {
            final cleaned = line.replaceAll('\r', '');
            if (cleaned.startsWith('data: ')) {
              final data = cleaned.substring(6).trim();
              if (data == '[DONE]') return;
              try {
                final parsed = jsonDecode(data) as Map<String, dynamic>;
                final text = parsed['text'] as String?;
                if (text != null && text.isNotEmpty) {
                  yield text;
                  yielded = true;
                }
              } catch (e) {
                _logger.warning(
                  'GeminiApiClient: failed to parse SSE data line: $e',
                );
              }
            }
          }
        }

        if (buffer.trim().isNotEmpty) {
          final cleaned = buffer.replaceAll('\r', '');
          if (cleaned.startsWith('data: ')) {
            final data = cleaned.substring(6).trim();
            if (data != '[DONE]') {
              try {
                final parsed = jsonDecode(data) as Map<String, dynamic>;
                final text = parsed['text'] as String?;
                if (text != null && text.isNotEmpty) {
                  yield text;
                  yielded = true;
                }
              } catch (e) {
                _logger.warning(
                  'GeminiApiClient: failed to parse final SSE buffer: $e',
                );
              }
            }
          }
        }
        return;
      } on TimeoutException {
        throw const AiException(
          AiErrorType.timeout,
          'Gemini took too long to respond.',
        );
      } on AiException {
        rethrow;
      } catch (e) {
        if (yielded) rethrow;
        // NUEVO-fix: el servidor rechaza con HTTP 429 + code
        // 'sage_daily_limit' cuando el usuario agotó su cuota diaria de Sage.
        // Se reenvía como AiErrorType.dailyLimit PARA EL CLIENTE (ÚNICO
        // consumidor legítimo del flujo): el provider lo muestra como
        // 'daily_limit' y NO ejecuta el fallback local (que haría creer que
        // Sage respondió algo real). Sin reintento.
        final dailyLimit = dailyLimitException(e);
        if (dailyLimit != null) throw dailyLimit;
        if (attempt < _maxRetries) {
          final base = AppConfig.geminiRetryDelay * (attempt + 1);
          final jitter = Duration(milliseconds: _jitter.nextInt(1000));
          await Future.delayed(base + jitter);
          continue;
        }
        throw AiException(
          AiErrorType.unknown,
          'Unexpected error contacting Gemini.',
          originalError: e,
        );
      }
    }
    throw const AiException(AiErrorType.unknown, 'Gemini: max retries reached');
  }

  void dispose() {}

  // NUEVO-fix: mapea el 429 server-authoritative de la cuota diaria de Sage
  // (HTTP body code 'sage_daily_limit') a AiErrorType.dailyLimit. Extraído a
  // función pura para poder testearlo sin firebase-mocking.
  @visibleForTesting
  AiException? dailyLimitException(Object error) {
    if (error is ApiException && error.serverCode == 'sage_daily_limit') {
      return AiException(
        AiErrorType.dailyLimit,
        'Has alcanzado el límite diario de mensajes de Sage.',
        originalError: error,
      );
    }
    return null;
  }

  bool _shouldRetry(FirebaseFunctionsException e) {
    return e.code == 'internal' || e.code == 'unavailable';
  }

  AiException _mapFunctionsError(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'unauthenticated':
        return const AiException(AiErrorType.auth, 'Invalid session.');
      case 'resource-exhausted':
        return const AiException(
          AiErrorType.rateLimit,
          'Too many requests. Wait a moment.',
        );
      case 'invalid-argument':
        return const AiException(
          AiErrorType.invalidResponse,
          'Invalid request.',
        );
      case 'failed-precondition':
        return const AiException(
          AiErrorType.apiKey,
          'Gemini is not configured.',
        );
      case 'internal':
        return const AiException(
          AiErrorType.server,
          'Gemini server is unavailable.',
        );
      default:
        return AiException(AiErrorType.unknown, 'Gemini error: ${e.message}');
    }
  }
}
