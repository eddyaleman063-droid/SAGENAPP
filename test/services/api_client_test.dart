import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/services/api_client.dart';

void main() {
  group('ApiException', () {
    test('stores type and message', () {
      const e = ApiException(ApiErrorType.timeout, 'timed out');
      expect(e.type, ApiErrorType.timeout);
      expect(e.message, 'timed out');
    });

    test('stores optional statusCode and host', () {
      const e = ApiException(ApiErrorType.server, 'error', statusCode: 500, host: 'example.com');
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
      const response = ApiResponse(statusCode: 200, body: '', headers: {'content-type': 'application/json'});
      expect(response.headers['content-type'], 'application/json');
    });
  });

  group('ApiClient singleton', () {
    tearDown(() {
      try { ApiClient.instance.dispose(); } catch (_) {}
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
      try { ApiClient.instance.dispose(); } catch (_) {}
    });

    test('rejects HTTP (non-HTTPS) requests', () async {
      final request = ApiRequest(
        method: 'GET',
        uri: Uri.parse('http://example.com'),
      );
      expect(
        () => ApiClient.instance.send(request),
        throwsA(isA<ApiException>().having((e) => e.type, 'type', ApiErrorType.validation)),
      );
    });

    test('rejects requests with empty host', () async {
      final request = ApiRequest(
        method: 'GET',
        uri: Uri.parse('https:///path'),
      );
      expect(
        () => ApiClient.instance.send(request),
        throwsA(isA<ApiException>().having((e) => e.type, 'type', ApiErrorType.validation)),
      );
    });

    test('rejects unsupported method', () async {
      final request = ApiRequest(
        method: 'DELETE',
        uri: Uri.parse('https://api.example.com'),
      );
      expect(
        () => ApiClient.instance.send(request),
        throwsA(isA<ApiException>().having((e) => e.type, 'type', ApiErrorType.validation)),
      );
    });
  });
}
