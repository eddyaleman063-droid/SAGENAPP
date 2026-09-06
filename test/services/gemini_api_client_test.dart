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
      expect(() => client.generate([]), throwsA(isA<AiException>()));
    });

    test('generateStream throws AiException for empty Content list', () async {
      await expectLater(
        () => client.generateStream([]).first,
        throwsA(isA<AiException>()),
      );
    });

    test(
      'maps a 429 sage_daily_limit server rejection to AiErrorType.dailyLimit',
      () {
        const fromServer = ApiException(
          ApiErrorType.rateLimit,
          'Límite diario de mensajes de Sage alcanzado (50/día)',
          statusCode: 429,
          serverCode: 'sage_daily_limit',
        );

        final mapped = client.dailyLimitException(fromServer);

        expect(mapped, isNotNull);
        expect(mapped!.type, AiErrorType.dailyLimit);
        expect(mapped.originalError, same(fromServer));
      },
    );

    test(
      'does NOT map a generic 429 (no sage_daily_limit code) to dailyLimit',
      () {
        const generic = ApiException(
          ApiErrorType.rateLimit,
          'Demasiadas solicitudes',
          statusCode: 429,
        );
        expect(client.dailyLimitException(generic), isNull);
      },
    );
  });
}
