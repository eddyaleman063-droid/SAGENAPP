import 'dart:async';
import 'dart:convert';
import 'dart:io';
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

  const ApiException(this.type, this.message, {this.statusCode, this.host});

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

  @override
  Future<ApiResponse> send(ApiRequest request) async {
    _validateRequest(request);

    return retry(
      () => _execute(request),
      config: RetryConfig(
        maxRetries: _defaultRetryConfig.maxRetries,
        baseDelay: _defaultRetryConfig.baseDelay,
        policy: _defaultRetryConfig.policy,
        shouldRetry: (e) => e is ApiException && _shouldRetry(e),
      ),
    );
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

    _checkHttpStatus(response.statusCode);

    try {
      await for (final chunk in response.stream.transform(utf8.decoder)) {
        yield chunk;
      }
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

  static void _checkHttpStatus(int statusCode) {
    if (statusCode == 401) {
      throw const ApiException(ApiErrorType.auth, 'Authentication error.');
    }
    if (statusCode == 403) {
      throw const ApiException(ApiErrorType.auth, 'Access denied.');
    }
    if (statusCode == 429) {
      throw const ApiException(
        ApiErrorType.rateLimit,
        'Too many requests. Wait a few seconds.',
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

  void dispose() {
    _client.close();
    _instance = null;
  }
}
