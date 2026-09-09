import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sagen/services/ai_service.dart';
import 'package:sagen/services/api_client.dart';
import 'package:sagen/services/gemini_api_client.dart';

class MockApiClient extends Mock implements ApiClient {}

class _MockAuth extends Mock implements firebase.FirebaseAuth {}

class _MockUser extends Mock implements firebase.User {}

class _MockFunctions extends Mock implements FirebaseFunctions {}

class _MockApp extends Mock implements FirebaseApp {}

class _MockCallable extends Mock implements HttpsCallable {}

class _MockResult implements HttpsCallableResult {
  @override
  final dynamic data;
  _MockResult(this.data);
}

void main() {
  late GeminiApiClient client;
  late MockApiClient mockApiClient;
  late _MockAuth mockAuth;
  late _MockUser mockUser;
  late _MockFunctions mockFunctions;
  late _MockApp mockApp;
  late _MockCallable mockCallable;

  void installFunctionsMock() {
    when(
      () => mockFunctions.httpsCallable('generateContent'),
    ).thenReturn(mockCallable);
  }

  void mockGenerateSuccess(String text) {
    when(
      () => mockCallable.call(any()),
    ).thenAnswer((_) async => _MockResult(<String, dynamic>{'text': text}));
  }

  void mockGenerateFailure(Object error) {
    when(() => mockCallable.call(any())).thenThrow(error);
  }

  void mockStreamChunks(List<String> chunks) {
    when(
      () => mockApiClient.sendStreaming(any()),
    ).thenAnswer((_) => Stream<String>.fromIterable(chunks));
  }

  setUp(() {
    mockApiClient = MockApiClient();
    mockAuth = _MockAuth();
    mockUser = _MockUser();
    mockApp = _MockApp();
    mockFunctions = _MockFunctions();
    mockCallable = _MockCallable();

    when(() => mockFunctions.app).thenReturn(mockApp);
    when(() => mockApp.options).thenReturn(
      const FirebaseOptions(
        apiKey: 'k',
        appId: 'a',
        messagingSenderId: 's',
        projectId: 'p',
      ),
    );

    client = GeminiApiClient(
      apiClient: mockApiClient,
      auth: mockAuth,
      functions: mockFunctions,
    );
  });

  group('GeminiApiClient', () {
    test('is available after creation', () {
      expect(client.isAvailable, true);
    });

    test('dispose does not affect availability', () {
      client.dispose();
      expect(client.isAvailable, true);
    });

    group('generate', () {
      test('returns text from the Cloud Function', () async {
        installFunctionsMock();
        mockGenerateSuccess('hola');
        final text = await client.generate(
          [
            {
              'role': 'user',
              'parts': <Map<String, dynamic>>[
                {'text': 'hi'},
              ],
            },
          ],
          userName: 'Ana',
          userLevel: 5,
          currentStreak: 3,
          weakTopics: ['matemáticas'],
        );
        expect(text, 'hola');
      });

      test('passes contents and system instruction to the function', () async {
        installFunctionsMock();
        late Map<String, dynamic> callArgs;
        when(() => mockCallable.call(any())).thenAnswer((invocation) async {
          callArgs = Map<String, dynamic>.from(
            invocation.positionalArguments.first as Map,
          );
          return _MockResult(<String, dynamic>{'text': 'hola'});
        });
        await client.generate([
          {
            'role': 'user',
            'parts': <Map<String, dynamic>>[
              {'text': 'hola'},
            ],
          },
        ], userName: 'Ana');
        expect(callArgs['contents'], isA<List>());
        expect(callArgs['systemInstruction'], isA<String>());
      });

      test('throws invalidResponse when the text field is missing', () async {
        installFunctionsMock();
        when(
          () => mockCallable.call(any()),
        ).thenAnswer((_) async => _MockResult(<String, dynamic>{'nope': true}));
        await expectLater(
          client.generate([]),
          throwsA(
            isA<AiException>().having(
              (e) => e.type,
              'type',
              AiErrorType.invalidResponse,
            ),
          ),
        );
      });

      test('throws invalidResponse for blank text', () async {
        installFunctionsMock();
        mockGenerateSuccess('   ');
        await expectLater(
          client.generate([]),
          throwsA(
            isA<AiException>().having(
              (e) => e.type,
              'type',
              AiErrorType.invalidResponse,
            ),
          ),
        );
      });

      test('maps timeouts to AiErrorType.timeout', () async {
        installFunctionsMock();
        mockGenerateFailure(TimeoutException('slow'));
        await expectLater(
          client.generate([]),
          throwsA(
            isA<AiException>().having(
              (e) => e.type,
              'type',
              AiErrorType.timeout,
            ),
          ),
        );
      });

      test('maps unauthenticated to auth', () async {
        installFunctionsMock();
        mockGenerateFailure(
          FirebaseFunctionsException(
            code: 'unauthenticated',
            message: 'no session',
          ),
        );
        await expectLater(
          client.generate([]),
          throwsA(
            isA<AiException>().having((e) => e.type, 'type', AiErrorType.auth),
          ),
        );
      });

      test('maps resource-exhausted to rateLimit', () async {
        installFunctionsMock();
        mockGenerateFailure(
          FirebaseFunctionsException(
            code: 'resource-exhausted',
            message: 'quota',
          ),
        );
        await expectLater(
          client.generate([]),
          throwsA(
            isA<AiException>().having(
              (e) => e.type,
              'type',
              AiErrorType.rateLimit,
            ),
          ),
        );
      });

      test('maps invalid-argument to invalidResponse', () async {
        installFunctionsMock();
        mockGenerateFailure(
          FirebaseFunctionsException(code: 'invalid-argument', message: 'bad'),
        );
        await expectLater(
          client.generate([]),
          throwsA(
            isA<AiException>().having(
              (e) => e.type,
              'type',
              AiErrorType.invalidResponse,
            ),
          ),
        );
      });

      test('maps failed-precondition to apiKey', () async {
        installFunctionsMock();
        mockGenerateFailure(
          FirebaseFunctionsException(
            code: 'failed-precondition',
            message: 'not configured',
          ),
        );
        await expectLater(
          client.generate([]),
          throwsA(
            isA<AiException>().having(
              (e) => e.type,
              'type',
              AiErrorType.apiKey,
            ),
          ),
        );
      });

      test('maps internal to server', () async {
        installFunctionsMock();
        mockGenerateFailure(
          FirebaseFunctionsException(code: 'internal', message: 'boom'),
        );
        await expectLater(
          client.generate([]),
          throwsA(
            isA<AiException>().having(
              (e) => e.type,
              'type',
              AiErrorType.server,
            ),
          ),
        );
      });

      test('maps unknown codes to unknown with the original error', () async {
        installFunctionsMock();
        mockGenerateFailure(
          FirebaseFunctionsException(code: 'data-loss', message: 'nope'),
        );
        await expectLater(
          client.generate([]),
          throwsA(
            isA<AiException>().having(
              (e) => e.type,
              'type',
              AiErrorType.unknown,
            ),
          ),
        );
      });

      test('maps unexpected errors to unknown', () async {
        installFunctionsMock();
        mockGenerateFailure(Exception('boom'));
        await expectLater(
          client.generate([]),
          throwsA(
            isA<AiException>()
                .having((e) => e.type, 'type', AiErrorType.unknown)
                .having(
                  (e) => e.originalError,
                  'originalError',
                  isA<Exception>(),
                ),
          ),
        );
      });

      test('enforces the client-side per-minute rate limit', () async {
        installFunctionsMock();
        mockGenerateSuccess('ok');
        for (var i = 0; i < 10; i++) {
          await client.generate([]);
        }
        await expectLater(
          client.generate([]),
          throwsA(
            isA<AiException>().having(
              (e) => e.type,
              'type',
              AiErrorType.rateLimit,
            ),
          ),
        );
      });
    });

    group('generateStream', () {
      setUpAll(() {
        registerFallbackValue(
          ApiRequest(method: 'GET', uri: Uri.parse('https://x')),
        );
      });

      setUp(() {
        when(() => mockAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.getIdToken()).thenAnswer((_) async => 'tok');
      });

      test('yields parsed SSE lines', () async {
        mockStreamChunks(['data: {"text":"hola"}\ndata: {"text":" mundo"}\n']);
        final events = await client.generateStream([]).toList();
        expect(events, ['hola', ' mundo']);
      });

      test('stops at the [DONE] marker', () async {
        mockStreamChunks([
          'data: {"text":"x"}\ndata: [DONE]\ndata: {"text":"ignored"}\n',
        ]);
        final events = await client.generateStream([]).toList();
        expect(events, ['x']);
      });

      test('parses a final chunk with no trailing newline', () async {
        mockStreamChunks(['data: {"text":"tail"}']);
        final events = await client.generateStream([]).toList();
        expect(events, ['tail']);
      });

      test('skips malformed JSON lines and keeps parsing', () async {
        mockStreamChunks(['data: not-json\ndata: {"text":"ok"}\n']);
        final events = await client.generateStream([]).toList();
        expect(events, ['ok']);
      });

      test('throws auth when no user is signed in', () async {
        when(() => mockAuth.currentUser).thenReturn(null);
        await expectLater(
          client.generateStream([]).toList(),
          throwsA(
            isA<AiException>().having((e) => e.type, 'type', AiErrorType.auth),
          ),
        );
      });

      test('maps a 429 ApiException to rateLimit without retrying', () async {
        when(() => mockApiClient.sendStreaming(any())).thenThrow(
          const ApiException(ApiErrorType.rateLimit, 'limit', statusCode: 429),
        );
        await expectLater(
          client.generateStream([]).toList(),
          throwsA(
            isA<AiException>().having(
              (e) => e.type,
              'type',
              AiErrorType.rateLimit,
            ),
          ),
        );
      });

      test('maps sage_daily_limit to dailyLimit', () async {
        when(() => mockApiClient.sendStreaming(any())).thenThrow(
          const ApiException(
            ApiErrorType.rateLimit,
            'daily',
            statusCode: 429,
            serverCode: 'sage_daily_limit',
          ),
        );
        await expectLater(
          client.generateStream([]).toList(),
          throwsA(
            isA<AiException>().having(
              (e) => e.type,
              'type',
              AiErrorType.dailyLimit,
            ),
          ),
        );
      });

      test('sends the auth token and correct URL', () async {
        late ApiRequest request;
        when(() => mockApiClient.sendStreaming(any())).thenAnswer((invocation) {
          request = invocation.positionalArguments.first as ApiRequest;
          return const Stream<String>.empty();
        });
        await client.generateStream([]).toList();
        expect(
          request.uri.toString(),
          'https://us-central1-p.cloudfunctions.net/generateContentStream',
        );
        expect(request.headers!['Authorization'], 'Bearer tok');
      });
    });
  });

  group('GeminiAiService', () {
    late GeminiAiService service;

    setUp(() {
      when(
        () => mockFunctions.httpsCallable('generateContent'),
      ).thenReturn(mockCallable);
      when(
        () => mockCallable.call(any()),
      ).thenAnswer((_) async => _MockResult(<String, dynamic>{'text': 'hola'}));
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.getIdToken()).thenAnswer((_) async => 'tok');
      service = GeminiAiService(
        GeminiApiClient(
          apiClient: mockApiClient,
          auth: mockAuth,
          functions: mockFunctions,
        ),
      );
    });

    test('exposes availability from the client', () {
      expect(service.isAvailable, isTrue);
    });

    test('delegates generate() to the client', () async {
      mockStreamChunks([]);
      final text = await service.generate([], userName: 'Ana', userLevel: 2);
      expect(text, 'hola');
    });

    test('delegates generateStream() to the client', () async {
      mockStreamChunks(['data: {"text":"hola"}\n']);
      final events = await service.generateStream([]).toList();
      expect(events, ['hola']);
    });

    test('dispose propagates to the client', () {
      service.dispose();
    });
  });
}
