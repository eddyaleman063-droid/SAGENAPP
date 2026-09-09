import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import '../config/app_config.dart';
import '../utils/retry.dart';
import 'app_logger.dart';
import 'certificate_pinning.dart';

export 'package:http/http.dart' show Client;

enum ApiErrorType {
  timeout,
  network,
  auth,
  rateLimit,
  server,
  validation,
  unknown,
}

abstract class ApiSender {
  Future<ApiResponse> send(ApiRequest request);
}

/// Exception for API call failures with type classification.
class ApiException implements Exception {
  final ApiErrorType type;
  final String message;
  final int? statusCode;
  final String? host;

  /// Código estructurado devuelto por el servidor (p.ej. `sage_daily_limit`)
  /// para distinguir un 429 por límite diario de uno por rate limit.
  final String? serverCode;

  const ApiException(
    this.type,
    this.message, {
    this.statusCode,
    this.host,
    this.serverCode,
  });

  @override
  String toString() => 'ApiException($type): $message';
}

/// Encapsulates an HTTP API request with metadata.
class ApiRequest {
  final String method;
  final Uri uri;
  final Map<String, String>? headers;
  final Object? body;
  final Duration? timeout;

  const ApiRequest({
    required this.method,
    required this.uri,
    this.headers,
    this.body,
    this.timeout,
  });

  String get host => uri.host;
}

/// Wraps an HTTP API response with status and body.
class ApiResponse {
  final int statusCode;
  final String body;
  final Map<String, String> headers;

  const ApiResponse({
    required this.statusCode,
    required this.body,
    this.headers = const {},
  });

  Map<String, dynamic>? get jsonMap {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return null;
    } catch (e) {
      AppLogger().warning('[ApiClient] jsonMap error: $e');
      return null;
    }
  }

  List<dynamic>? get jsonList {
    try {
      final decoded = jsonDecode(body);
      if (decoded is List) return List<dynamic>.from(decoded);
      return null;
    } catch (e) {
      AppLogger().warning('[ApiClient] jsonList error: $e');
      return null;
    }
  }
}

/// HTTP client with certificate pinning and retry logic.
class ApiClient implements ApiSender {
  static ApiClient? _instance;

  late final http.Client _client;

  final RetryConfig _defaultRetryConfig;

  ApiClient._({RetryConfig? retryConfig})
    : _defaultRetryConfig =
          retryConfig ??
          const RetryConfig(
            maxRetries: 2,
            baseDelay: Duration(seconds: 1),
            policy: RetryPolicy.exponentialBackoff,
          );

  static Future<ApiClient> init({RetryConfig? retryConfig}) async {
    final pinning = CertificatePinning.instance;

    // Certificate pins for critical hosts.
    // SHA-256 fingerprints of DER-encoded leaf certificates.
    // Generated 2026-07-14 via PowerShell SslStream.
    final hostPins = {
      Uri.parse(AppConfig.mercadopagoFunctionsUrl).host: [
        'sha256/ee54cb11f16cc311b3acbae57f8fbb03f338c1b2a20de72722c3eafd0dae0140',
      ],
      'firestore.googleapis.com': [
        'sha256/928d3c95954ad4eeaf2a683a0e9b7088f33e0f16b5eb5c95b26021fa3f470595',
      ],
      'firebaseinstallations.googleapis.com': [
        'sha256/2b6f09d23f626db060922e8a0c6b48e54361eb5a0725f0aeef8a2e4555ae99a8',
      ],
      'fcmregistrations.googleapis.com': [
        'sha256/2b6f09d23f626db060922e8a0c6b48e54361eb5a0725f0aeef8a2e4555ae99a8',
      ],
      'generativelanguage.googleapis.com': [
        'sha256/2b6f09d23f626db060922e8a0c6b48e54361eb5a0725f0aeef8a2e4555ae99a8',
      ],
    };
    for (final entry in hostPins.entries) {
      pinning.addPins(entry.key, entry.value);
    }

    if (!pinning.validateConfiguration()) {
      AppLogger().error(
        'ApiClient: certificate pinning has placeholder pins. '
        'Real certificates must be configured before production. '
        'See: https://github.com/nicklockwood/iVersion/wiki/Firebase-Certificate-Pins',
      );
      assert(
        pinning.validateConfiguration(),
        'Certificate pinning has placeholder pins. Configure real pins before production release.',
      );
    }

    final ioClient = pinning.createHttpClient();
    final client = ApiClient._(retryConfig: retryConfig);
    client._client = IOClient(ioClient);
    _instance = client;
    return client;
  }

  static ApiClient get instance {
    if (_instance == null) {
      throw StateError(
        'ApiClient not initialized. Call ApiClient.init() first.',
      );
    }
    return _instance!;
  }

  @visibleForTesting
  static ApiClient createForTest(
    http.Client client, {
    RetryConfig? retryConfig,
  }) {
    final apiClient = ApiClient._(retryConfig: retryConfig);
    apiClient._client = client;
    return apiClient;
  }

  @override
  Future<ApiResponse> send(ApiRequest request) async {
    _validateRequest(request);

    // NUEVO-fix (ronda 7): `_execute` devolvía la respuesta sin verificar el
    // status HTTP, así que un 4xx/5xx se entregaba como éxito y el caller
    // dependía de la forma del body. Ahora se lanza ApiException antes. Los
    // únicos callers (MercadoPago) capturan ApiException, CheckHealth ya solo
    // buscaba 2xx, y esto unifica el contrato con sendStreaming.
    final response = await retry(
      () => _execute(request),
      config: RetryConfig(
        maxRetries: _defaultRetryConfig.maxRetries,
        baseDelay: _defaultRetryConfig.baseDelay,
        policy: _defaultRetryConfig.policy,
        shouldRetry: (e) => e is ApiException && _shouldRetry(e),
      ),
    );
    _checkHttpStatus(response.statusCode, responseBody: response.body);
    return response;
  }

  Stream<String> sendStreaming(ApiRequest request) async* {
    _validateRequest(request);

    final effectiveTimeout = request.timeout ?? AppConfig.defaultTimeout;
    final httpReq = http.Request(request.method, request.uri);
    if (request.headers != null) httpReq.headers.addAll(request.headers!);
    if (request.body != null) {
      if (request.body is String) {
        httpReq.body = request.body as String;
      } else if (request.body is Map) {
        httpReq.body = jsonEncode(request.body);
        httpReq.headers['Content-Type'] = 'application/json';
      }
    }

    late http.StreamedResponse response;
    try {
      response = await _client.send(httpReq).timeout(effectiveTimeout);
    } on TimeoutException {
      throw const ApiException(ApiErrorType.timeout, 'Request timed out.');
    } on SocketException {
      throw const ApiException(ApiErrorType.network, 'No internet connection.');
    } on Exception catch (e) {
      throw ApiException(ApiErrorType.network, e.toString());
    }

    if (response.statusCode == 429) {
      // NUEVO-fix: distingue el límite diario de Sage (server-authoritative)
      // del rate limit por minuto; ambos llegan como HTTP 429 pero con
      // `code` distinto en el cuerpo del error.
      var body = '';
      try {
        body = await response.stream.transform(utf8.decoder).join();
      } catch (_) {
        // Sin body utilizable: se trata como rate limit genérico.
      }
      String? serverCode;
      try {
        final parsed = jsonDecode(body);
        if (parsed is Map && parsed['code'] is String) {
          serverCode = parsed['code'] as String;
        }
      } catch (_) {
        // Body no JSON.
      }
      throw ApiException(
        ApiErrorType.rateLimit,
        serverCode == 'sage_daily_limit'
            ? 'Daily limit reached.'
            : 'Too many requests. Wait a few seconds.',
        statusCode: 429,
        serverCode: serverCode,
      );
    }

    _checkHttpStatus(response.statusCode);

    try {
      // NUEVO-fix: el stream no tenía watchdog por chunk: una conexión que
      // recibiera headers y luego se quedara muda colgaba al usuario en
      // "escribiendo" para siempre. Ahora el SSTREAM muere si no llegan datos
      // en `geminiStreamTimeout` (45s). El servidor también aborta tras 60s.
      await for (final chunk
          in response.stream
              .transform(utf8.decoder)
              .timeout(AppConfig.geminiStreamTimeout)) {
        yield chunk;
      }
    } on TimeoutException {
      throw const ApiException(
        ApiErrorType.timeout,
        'Stream timed out (no data).',
      );
    } on Exception catch (e) {
      throw ApiException(ApiErrorType.network, 'Stream error: $e');
    }
  }

  Future<ApiResponse> _execute(ApiRequest request) async {
    final effectiveTimeout = request.timeout ?? AppConfig.defaultTimeout;
    final uri = request.uri;
    final headers = Map<String, String>.from(request.headers ?? {});

    try {
      http.Response response;

      switch (request.method.toUpperCase()) {
        case 'GET':
          response = await _client
              .get(uri, headers: headers)
              .timeout(effectiveTimeout);
          break;
        case 'POST':
          if (request.body is Map && !headers.containsKey('Content-Type')) {
            headers['Content-Type'] = 'application/json';
          }
          final body = request.body is Map
              ? jsonEncode(request.body)
              : (request.body as String? ?? '');
          response = await _client
              .post(uri, headers: headers, body: body)
              .timeout(effectiveTimeout);
          break;
        default:
          throw ApiException(
            ApiErrorType.validation,
            'Unsupported method: ${request.method}',
          );
      }

      return ApiResponse(
        statusCode: response.statusCode,
        body: response.body,
        headers: response.headers,
      );
    } on TimeoutException {
      throw ApiException(
        ApiErrorType.timeout,
        'Request timed out.',
        host: request.host,
      );
    } on SocketException {
      throw ApiException(
        ApiErrorType.network,
        'No internet connection.',
        host: request.host,
      );
    } on http.ClientException catch (e) {
      throw ApiException(ApiErrorType.network, e.message, host: request.host);
    }
  }

  void _validateRequest(ApiRequest request) {
    if (request.uri.scheme != 'https') {
      throw const ApiException(
        ApiErrorType.validation,
        'Only HTTPS connections are allowed.',
      );
    }
    if (request.uri.host.isEmpty) {
      throw const ApiException(ApiErrorType.validation, 'Invalid URL.');
    }
  }

  bool _shouldRetry(ApiException e) {
    switch (e.type) {
      case ApiErrorType.rateLimit:
      case ApiErrorType.server:
      case ApiErrorType.timeout:
      case ApiErrorType.network:
        return true;
      case ApiErrorType.auth:
      case ApiErrorType.validation:
      case ApiErrorType.unknown:
        return false;
    }
  }

  static void _checkHttpStatus(int statusCode, {String? responseBody}) {
    if (statusCode == 401) {
      throw const ApiException(ApiErrorType.auth, 'Authentication error.');
    }
    if (statusCode == 403) {
      // NUEVO-fix (ronda 8): el servidor devuelve códigos accionables en el
      // body (email-not-verified, etc.) que antes se descartaban — el usuario
      // veía un genérico 'Access denied.' sin saber qué corregir.
      throw ApiException(
        ApiErrorType.auth,
        _serverCodeFromBody(responseBody) == 'email-not-verified'
            ? 'Verify your email to continue.'
            : 'Access denied.',
        statusCode: statusCode,
        serverCode: _serverCodeFromBody(responseBody),
      );
    }
    if (statusCode == 429) {
      throw ApiException(
        ApiErrorType.rateLimit,
        'Too many requests. Wait a few seconds.',
        statusCode: statusCode,
      );
    }
    if (statusCode >= 500) {
      throw ApiException(
        ApiErrorType.server,
        'Server error ($statusCode).',
        statusCode: statusCode,
      );
    }
    if (statusCode < 200 || statusCode >= 300) {
      throw ApiException(
        ApiErrorType.unknown,
        'Unexpected error ($statusCode).',
        statusCode: statusCode,
      );
    }
  }

  static String? _serverCodeFromBody(String? body) {
    if (body == null || body.isEmpty) return null;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['error'] is String) {
        return decoded['error'] as String;
      }
      if (decoded is Map && decoded['code'] is String) {
        return decoded['code'] as String;
      }
    } catch (_) {
      // Body no JSON: sin código accionable.
    }
    return null;
  }

  void dispose() {
    _client.close();
    _instance = null;
  }
}
