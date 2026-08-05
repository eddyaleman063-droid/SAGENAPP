import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sagen/services/ai_service.dart';
import 'package:sagen/services/api_client.dart';
import 'package:sagen/services/gemini_api_client.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  group('GeminiApiClient', () {
    late GeminiApiClient client;
    late MockApiClient mockApiClient;

    setUp(() {
      mockApiClient = MockApiClient();
      client = GeminiApiClient(apiClient: mockApiClient);
    });

    test('is available after creation', () {
      expect(client.isAvailable, true);
    });

    test('dispose does not affect availability', () {
      client.dispose();
      expect(client.isAvailable, true);
    });

    test('generate throws AiException for empty Content list', () {
      expect(
        () => client.generate([]),
        throwsA(isA<AiException>()),
      );
    });

    test('generateStream throws AiException for empty Content list', () async {
      await expectLater(
        () => client.generateStream([]).first,
        throwsA(isA<AiException>()),
      );
    });
  });
}
