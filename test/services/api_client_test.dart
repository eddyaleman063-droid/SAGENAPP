import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sagen/services/api_client.dart';
import 'package:sagen/utils/retry.dart';

const _fastRetry = RetryConfig(
  maxRetries: 2,
  baseDelay: Duration.zero,
  policy: RetryPolicy.fixed,
);

void main() {
  group('ApiException', () {
    test('stores type and message', () {
      const e = ApiException(ApiErrorType.timeout, 'timed out');
      expect(e.type, ApiErrorType.timeout);
      expect(e.message, 'timed out');
    });

    test('stores optional statusCode and host', () {
      const e = ApiException(
        ApiErrorType.server,
        'error',
        statusCode: 500,
        host: 'example.com',
      );
      expect(e.statusCode, 500);
      expect(e.host, 'example.com');
    });

    test('toString includes type and message', () {
      const e = ApiException(ApiErrorType.network, 'no connection');
      expect(e.toString(), 'ApiException(ApiErrorType.network): no connection');
    });
  });

  group('ApiRequest', () {
    test('stores request fields', () {
      final uri = Uri.parse('https://api.example.com/data');
      final request = ApiRequest(method: 'GET', uri: uri);
      expect(request.method, 'GET');
      expect(request.uri, uri);
    });

    test('host extracts from uri', () {
      final request = ApiRequest(
        method: 'POST',
        uri: Uri.parse('https://api.example.com/v1/test'),
      );
      expect(request.host, 'api.example.com');
    });
  });

  group('ApiResponse', () {
    test('stores statusCode and body', () {
      const response = ApiResponse(statusCode: 200, body: 'ok');
      expect(response.statusCode, 200);
      expect(response.body, 'ok');
    });

    test('jsonMap parses JSON object body', () {
      final body = jsonEncode({'key': 'value', 'num': 42});
      final response = ApiResponse(statusCode: 200, body: body);
      expect(response.jsonMap, isNotNull);
      expect(response.jsonMap!['key'], 'value');
      expect(response.jsonMap!['num'], 42);
    });

    test('jsonMap returns null for invalid JSON', () {
      const response = ApiResponse(statusCode: 200, body: 'not-json');
      expect(response.jsonMap, isNull);
    });

    test('jsonList parses JSON array body', () {
      final body = jsonEncode([1, 2, 3]);
      final response = ApiResponse(statusCode: 200, body: body);
      expect(response.jsonList, isNotNull);
      expect(response.jsonList!.length, 3);
    });

    test('jsonList returns null for object body', () {
      final body = jsonEncode({'a': 1});
      final response = ApiResponse(statusCode: 200, body: body);
      expect(response.jsonList, isNull);
    });

    test('stores headers', () {
      const response = ApiResponse(
        statusCode: 200,
        body: '',
        headers: {'content-type': 'application/json'},
      );
      expect(response.headers['content-type'], 'application/json');
    });
  });

  group('ApiClient singleton', () {
    tearDown(() {
      try {
        ApiClient.instance.dispose();
      } catch (_) {}
    });

    test('throws StateError before init', () {
      expect(() => ApiClient.instance, throwsA(isA<StateError>()));
    });

    test('init creates singleton without pinned hosts', () async {
      final client = await ApiClient.init();
      expect(client, isNotNull);
      expect(ApiClient.instance, same(client));
    });

    test('dispose resets singleton', () async {
      await ApiClient.init();
      ApiClient.instance.dispose();
      expect(() => ApiClient.instance, throwsA(isA<StateError>()));
    });
  });

  group('ApiClient validation', () {
    setUp(() async {
      await ApiClient.init();
    });

    tearDown(() {
      try {
        ApiClient.instance.dispose();
      } catch (_) {}
    });

    test('rejects HTTP (non-HTTPS) requests', () async {
      final request = ApiRequest(
        method: 'GET',
        uri: Uri.parse('http://example.com'),
      );
      expect(
        () => ApiClient.instance.send(request),
        throwsA(
          isA<ApiException>().having(
            (e) => e.type,
            'type',
            ApiErrorType.validation,
          ),
        ),
      );
    });

    test('rejects requests with empty host', () async {
      final request = ApiRequest(
        method: 'GET',
        uri: Uri.parse('https:///path'),
      );
      expect(
        () => ApiClient.instance.send(request),
        throwsA(
          isA<ApiException>().having(
            (e) => e.type,
            'type',
            ApiErrorType.validation,
          ),
        ),
      );
    });

    test('rejects unsupported method', () async {
      final request = ApiRequest(
        method: 'DELETE',
        uri: Uri.parse('https://api.example.com'),
      );
      expect(
        () => ApiClient.instance.send(request),
        throwsA(
          isA<ApiException>().having(
            (e) => e.type,
            'type',
            ApiErrorType.validation,
          ),
        ),
      );
    });
  });

  group('ApiClient.send with mocked http', () {
    late ApiClient client;

    tearDown(() {
      try {
        client.dispose();
      } catch (_) {}
    });

    test('GET returns the response with status and headers', () async {
      client = ApiClient.createForTest(
        MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.toString(), 'https://api.example.com/data');
          return http.Response(
            '{"ok":true}',
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
        retryConfig: _fastRetry,
      );

      final response = await client.send(
        ApiRequest(
          method: 'GET',
          uri: Uri.parse('https://api.example.com/data'),
        ),
      );

      expect(response.statusCode, 200);
      expect(response.jsonMap!['ok'], true);
      expect(response.headers['content-type'], 'application/json');
    });

    test('POST with Map body encodes JSON and sets Content-Type', () async {
      late Map<String, String> capturedHeaders;
      late String capturedBody;
      client = ApiClient.createForTest(
        MockClient((request) async {
          capturedHeaders = request.headers;
          capturedBody = request.body;
          return http.Response('{}', 200);
        }),
        retryConfig: _fastRetry,
      );

      await client.send(
        ApiRequest(
          method: 'POST',
          uri: Uri.parse('https://api.example.com/data'),
          body: {'name': 'alice', 'n': 3},
        ),
      );

      expect(capturedHeaders['Content-Type'], 'application/json');
      expect(jsonDecode(capturedBody), {'name': 'alice', 'n': 3});
    });

    test('POST with String body is sent verbatim', () async {
      late String capturedBody;
      client = ApiClient.createForTest(
        MockClient((request) async {
          capturedBody = request.body;
          return http.Response('{}', 200);
        }),
        retryConfig: _fastRetry,
      );

      await client.send(
        ApiRequest(
          method: 'POST',
          uri: Uri.parse('https://api.example.com/data'),
          body: 'raw-text',
        ),
      );

      expect(capturedBody, 'raw-text');
    });

    test('401 maps to auth error', () async {
      client = ApiClient.createForTest(
        MockClient((_) async => http.Response('denied', 401)),
        retryConfig: _fastRetry,
      );
      await expectLater(
        client.send(
          ApiRequest(method: 'GET', uri: Uri.parse('https://api.example.com')),
        ),
        throwsA(
          isA<ApiException>().having((e) => e.type, 'type', ApiErrorType.auth),
        ),
      );
    });

    test('403 without actionable body maps to generic access denied', () async {
      client = ApiClient.createForTest(
        MockClient((_) async => http.Response('nope', 403)),
        retryConfig: _fastRetry,
      );
      await expectLater(
        client.send(
          ApiRequest(method: 'GET', uri: Uri.parse('https://api.example.com')),
        ),
        throwsA(
          isA<ApiException>()
              .having((e) => e.type, 'type', ApiErrorType.auth)
              .having((e) => e.message, 'message', 'Access denied.')
              .having((e) => e.serverCode, 'serverCode', isNull),
        ),
      );
    });

    test('403 with email-not-verified body explains the action', () async {
      client = ApiClient.createForTest(
        MockClient(
          (_) async =>
              http.Response(jsonEncode({'error': 'email-not-verified'}), 403),
        ),
        retryConfig: _fastRetry,
      );
      await expectLater(
        client.send(
          ApiRequest(method: 'GET', uri: Uri.parse('https://api.example.com')),
        ),
        throwsA(
          isA<ApiException>()
              .having((e) => e.type, 'type', ApiErrorType.auth)
              .having(
                (e) => e.message,
                'message',
                'Verify your email to continue.',
              )
              .having((e) => e.serverCode, 'serverCode', 'email-not-verified'),
        ),
      );
    });

    test('403 reads serverCode from the body code field', () async {
      client = ApiClient.createForTest(
        MockClient(
          (_) async =>
              http.Response(jsonEncode({'code': 'plan-required'}), 403),
        ),
        retryConfig: _fastRetry,
      );
      await expectLater(
        client.send(
          ApiRequest(method: 'GET', uri: Uri.parse('https://api.example.com')),
        ),
        throwsA(
          isA<ApiException>()
              .having((e) => e.type, 'type', ApiErrorType.auth)
              .having((e) => e.serverCode, 'serverCode', 'plan-required'),
        ),
      );
    });

    test('429 maps to rate limit with status code', () async {
      client = ApiClient.createForTest(
        MockClient((_) async => http.Response('slow down', 429)),
        retryConfig: _fastRetry,
      );
      await expectLater(
        client.send(
          ApiRequest(method: 'GET', uri: Uri.parse('https://api.example.com')),
        ),
        throwsA(
          isA<ApiException>()
              .having((e) => e.type, 'type', ApiErrorType.rateLimit)
              .having((e) => e.statusCode, 'statusCode', 429),
        ),
      );
    });

    test('5xx maps to server error', () async {
      client = ApiClient.createForTest(
        MockClient((_) async => http.Response('boom', 500)),
        retryConfig: _fastRetry,
      );
      await expectLater(
        client.send(
          ApiRequest(method: 'GET', uri: Uri.parse('https://api.example.com')),
        ),
        throwsA(
          isA<ApiException>().having(
            (e) => e.type,
            'type',
            ApiErrorType.server,
          ),
        ),
      );
    });

    test('non-2xx 4xx maps to unknown error', () async {
      client = ApiClient.createForTest(
        MockClient((_) async => http.Response('teapot', 418)),
        retryConfig: _fastRetry,
      );
      await expectLater(
        client.send(
          ApiRequest(method: 'GET', uri: Uri.parse('https://api.example.com')),
        ),
        throwsA(
          isA<ApiException>().having(
            (e) => e.type,
            'type',
            ApiErrorType.unknown,
          ),
        ),
      );
    });

    test('204 no content is accepted as success', () async {
      client = ApiClient.createForTest(
        MockClient((_) async => http.Response('', 204)),
        retryConfig: _fastRetry,
      );
      final response = await client.send(
        ApiRequest(method: 'GET', uri: Uri.parse('https://api.example.com')),
      );
      expect(response.statusCode, 204);
    });

    test('network failures map to network error with host', () async {
      client = ApiClient.createForTest(
        MockClient((_) async => throw http.ClientException('conn refused')),
        retryConfig: _fastRetry,
      );
      await expectLater(
        client.send(
          ApiRequest(method: 'GET', uri: Uri.parse('https://api.example.com')),
        ),
        throwsA(
          isA<ApiException>()
              .having((e) => e.type, 'type', ApiErrorType.network)
              .having((e) => e.host, 'host', 'api.example.com'),
        ),
      );
    });

    test('transient network errors retry until success', () async {
      var calls = 0;
      client = ApiClient.createForTest(
        MockClient((_) async {
          calls++;
          if (calls == 1) {
            throw http.ClientException('first attempt failed');
          }
          return http.Response('ok', 200);
        }),
        retryConfig: _fastRetry,
      );

      final response = await client.send(
        ApiRequest(method: 'GET', uri: Uri.parse('https://api.example.com')),
      );
      expect(response.statusCode, 200);
      expect(calls, 2);
    });

    test('timeout maps to timeout error', () async {
      client = ApiClient.createForTest(
        MockClient((_) async {
          await Future.delayed(const Duration(milliseconds: 200));
          return http.Response('late', 200);
        }),
        retryConfig: _fastRetry,
      );
      await expectLater(
        client.send(
          ApiRequest(
            method: 'GET',
            uri: Uri.parse('https://api.example.com'),
            timeout: const Duration(milliseconds: 30),
          ),
        ),
        throwsA(
          isA<ApiException>().having(
            (e) => e.type,
            'type',
            ApiErrorType.timeout,
          ),
        ),
      );
    });
  });

  group('ApiClient.sendStreaming with mocked http', () {
    late ApiClient client;

    tearDown(() {
      try {
        client.dispose();
      } catch (_) {}
    });

    Future<String> collect(Uri uri) async {
      final stream = client.sendStreaming(ApiRequest(method: 'GET', uri: uri));
      final buffer = StringBuffer();
      await for (final chunk in stream) {
        buffer.write(chunk);
      }
      return buffer.toString();
    }

    test('yields decoded chunks from a 200 stream', () async {
      client = ApiClient.createForTest(
        MockClient((_) async => http.Response('hello world', 200)),
        retryConfig: _fastRetry,
      );
      expect(
        await collect(Uri.parse('https://api.example.com/sse')),
        'hello world',
      );
    });

    test('429 with sage_daily_limit code reports daily limit', () async {
      client = ApiClient.createForTest(
        MockClient(
          (_) async =>
              http.Response(jsonEncode({'code': 'sage_daily_limit'}), 429),
        ),
        retryConfig: _fastRetry,
      );
      await expectLater(
        collect(Uri.parse('https://api.example.com/sse')),
        throwsA(
          isA<ApiException>()
              .having((e) => e.type, 'type', ApiErrorType.rateLimit)
              .having((e) => e.message, 'message', 'Daily limit reached.')
              .having((e) => e.serverCode, 'serverCode', 'sage_daily_limit'),
        ),
      );
    });

    test('429 without code reports generic rate limit', () async {
      client = ApiClient.createForTest(
        MockClient((_) async => http.Response('slow', 429)),
        retryConfig: _fastRetry,
      );
      await expectLater(
        collect(Uri.parse('https://api.example.com/sse')),
        throwsA(
          isA<ApiException>()
              .having((e) => e.type, 'type', ApiErrorType.rateLimit)
              .having(
                (e) => e.message,
                'message',
                'Too many requests. Wait a few seconds.',
              )
              .having((e) => e.serverCode, 'serverCode', isNull),
        ),
      );
    });

    test('5xx stream maps to server error', () async {
      client = ApiClient.createForTest(
        MockClient((_) async => http.Response('boom', 503)),
        retryConfig: _fastRetry,
      );
      await expectLater(
        collect(Uri.parse('https://api.example.com/sse')),
        throwsA(
          isA<ApiException>().having(
            (e) => e.type,
            'type',
            ApiErrorType.server,
          ),
        ),
      );
    });

    test('network errors during stream setup map to network error', () async {
      client = ApiClient.createForTest(
        MockClient((_) async => throw http.ClientException('reset')),
        retryConfig: _fastRetry,
      );
      await expectLater(
        collect(Uri.parse('https://api.example.com/sse')),
        throwsA(
          isA<ApiException>().having(
            (e) => e.type,
            'type',
            ApiErrorType.network,
          ),
        ),
      );
    });

    test('establishing the stream times out when the client hangs', () async {
      client = ApiClient.createForTest(
        MockClient((_) async {
          await Future.delayed(const Duration(milliseconds: 200));
          return http.Response('late', 200);
        }),
        retryConfig: _fastRetry,
      );
      final stream = client.sendStreaming(
        ApiRequest(
          method: 'GET',
          uri: Uri.parse('https://api.example.com/sse'),
          timeout: const Duration(milliseconds: 30),
        ),
      );
      await expectLater(
        stream.first,
        throwsA(
          isA<ApiException>().having(
            (e) => e.type,
            'type',
            ApiErrorType.timeout,
          ),
        ),
      );
    });
  });
}
