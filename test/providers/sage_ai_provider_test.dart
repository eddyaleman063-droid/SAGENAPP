import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/models/chat_message.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/ai_service.dart';
import '../helpers/mock_learning_provider.dart';

class MockAiService extends AiService {
  @override
  bool get isAvailable => false;

  @override
  Future<String> generate(
    List<ChatMessage> messages, {
    String userName = '',
    int userLevel = 1,
    int currentStreak = 0,
    List<String> weakTopics = const [],
  }) async => '';

  @override
  Stream<String> generateStream(
    List<ChatMessage> messages, {
    String userName = '',
    int userLevel = 1,
    int currentStreak = 0,
    List<String> weakTopics = const [],
  }) => const Stream.empty();

  @override
  void dispose() {}
}

class MockAiServiceDailyLimit extends AiService {
  @override
  bool get isAvailable => true;

  @override
  Future<String> generate(
    List<ChatMessage> messages, {
    String userName = '',
    int userLevel = 1,
    int currentStreak = 0,
    List<String> weakTopics = const [],
  }) async => '';

  @override
  Stream<String> generateStream(
    List<ChatMessage> messages, {
    String userName = '',
    int userLevel = 1,
    int currentStreak = 0,
    List<String> weakTopics = const [],
  }) =>
      Stream.error(const AiException(AiErrorType.dailyLimit, 'límite diario'));

  @override
  void dispose() {}
}

class MockAiServiceStream extends AiService {
  @override
  bool get isAvailable => true;

  @override
  Future<String> generate(
    List<ChatMessage> messages, {
    String userName = '',
    int userLevel = 1,
    int currentStreak = 0,
    List<String> weakTopics = const [],
  }) async => 'hola sage';

  @override
  Stream<String> generateStream(
    List<ChatMessage> messages, {
    String userName = '',
    int userLevel = 1,
    int currentStreak = 0,
    List<String> weakTopics = const [],
  }) => Stream.fromIterable(['hola ', 'sage']);

  @override
  void dispose() {}
}

class MockReviewNotifier extends ReviewNotifier {
  @override
  ReviewState build() => const ReviewState();
}

class _RecordingAiService extends AiService {
  final List<List<ChatMessage>> captured = [];

  @override
  bool get isAvailable => true;

  @override
  Future<String> generate(
    List<ChatMessage> messages, {
    String userName = '',
    int userLevel = 1,
    int currentStreak = 0,
    List<String> weakTopics = const [],
  }) async => 'ok';

  @override
  Stream<String> generateStream(
    List<ChatMessage> messages, {
    String userName = '',
    int userLevel = 1,
    int currentStreak = 0,
    List<String> weakTopics = const [],
  }) {
    captured.add(List<ChatMessage>.from(messages));
    return Stream.value('ok');
  }

  @override
  void dispose() {}
}

void main() {
  group('SageAiProvider', () {
    late ProviderContainer container;
    late MockLearningNotifier mockLearning;

    setUp(() {
      mockLearning = MockLearningNotifier();
      container = ProviderContainer(
        overrides: [
          learningProvider.overrideWith(() => mockLearning),
          aiServiceProvider.overrideWithValue(MockAiService()),
          reviewProvider.overrideWith(() => MockReviewNotifier()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is idle with no loading or streaming', () {
      final state = container.read(sageAiProvider);
      expect(state.status, SageAiChatStatus.idle);
      expect(state.isLoading, false);
      expect(state.isStreaming, false);
      expect(state.isBusy, false);
    });

    test('isLocked returns true when lessonsCompleted < 5', () {
      container.read(learningProvider);
      mockLearning.lessonsCompleted = 4;
      final state = container.read(sageAiProvider);
      expect(state.isLocked, true);
    });

    test('isLocked returns false when lessonsCompleted >= 10', () {
      container.read(learningProvider);
      mockLearning.lessonsCompleted = 10;
      final state = container.read(sageAiProvider);
      expect(state.isLocked, false);
    });

    test('clearMessages resets state correctly', () {
      final notifier = container.read(sageAiProvider.notifier);
      notifier.clearMessages();
      final state = container.read(sageAiProvider);
      expect(state.messages, isEmpty);
      expect(state.status, SageAiChatStatus.idle);
      expect(state.errorMessage, isNull);
      expect(state.streamingText, '');
    });

    test(
      'enters the daily-limit state WITHOUT local fallback when the server caps the quota',
      () async {
        SageAiNotifier.resetRateLimits();
        final mock = MockLearningNotifier();
        final container2 = ProviderContainer(
          overrides: [
            learningProvider.overrideWith(() => mock),
            aiServiceProvider.overrideWithValue(MockAiServiceDailyLimit()),
            reviewProvider.overrideWith(() => MockReviewNotifier()),
          ],
        );
        addTearDown(container2.dispose);
        container2.read(learningProvider);
        mock.lessonsCompleted = 10;
        container2.listen(sageAiProvider, (_, _) {});

        final notifier = container2.read(sageAiProvider.notifier);
        final sent = await notifier.sendMessage('hola');
        expect(sent, isTrue);
        await pumpEventQueue();

        final state = container2.read(sageAiProvider);
        expect(state.lastError, 'daily_limit');
        expect(state.status, SageAiChatStatus.idle);
        expect(state.isBusy, isFalse);
        // El assistant vacío se retira y NUNCA se aplicó el fallback local
        // (que habría añadido un mensaje de texto haciéndose pasar por Sage).
        final last = state.messages.last;
        expect(last.role, ChatRole.user);
      },
    );

    test(
      'blocks a second send on the same day after the server capped the quota',
      () async {
        SageAiNotifier.resetRateLimits();
        final mock = MockLearningNotifier();
        final container2 = ProviderContainer(
          overrides: [
            learningProvider.overrideWith(() => mock),
            aiServiceProvider.overrideWithValue(MockAiServiceDailyLimit()),
            reviewProvider.overrideWith(() => MockReviewNotifier()),
          ],
        );
        addTearDown(container2.dispose);
        container2.read(learningProvider);
        mock.lessonsCompleted = 10;
        container2.listen(sageAiProvider, (_, _) {});

        final notifier = container2.read(sageAiProvider.notifier);
        await notifier.sendMessage('uno');
        await pumpEventQueue();

        SageAiNotifier.resetRateLimits();
        final second = await notifier.sendMessage('dos');
        expect(second, isFalse);
        expect(container2.read(sageAiProvider).lastError, 'daily_limit');
      },
    );

    test('records a real Sage talk only on successful delivery', () async {
      SageAiNotifier.resetRateLimits();
      final mock = MockLearningNotifier();
      final container2 = ProviderContainer(
        overrides: [
          learningProvider.overrideWith(() => mock),
          aiServiceProvider.overrideWithValue(MockAiServiceStream()),
          reviewProvider.overrideWith(() => MockReviewNotifier()),
        ],
      );
      addTearDown(container2.dispose);
      container2.read(learningProvider);
      mock.lessonsCompleted = 10;
      container2.listen(sageAiProvider, (_, _) {});

      final notifier = container2.read(sageAiProvider.notifier);
      final sent = await notifier.sendMessage('hola');
      expect(sent, isTrue);
      await pumpEventQueue();

      final state = container2.read(sageAiProvider);
      expect(mock.state.sageTalks, 1);
      final last = state.messages.last;
      expect(last.role, ChatRole.assistant);
      expect(last.text, contains('hola sage'));
    });

    test(
      'NUEVO-fix: la ventana de contexto no excede el cap del servidor de 20 parts',
      () async {
        SageAiNotifier.resetRateLimits();
        final mock = MockLearningNotifier();
        final rec = _RecordingAiService();
        final container2 = ProviderContainer(
          overrides: [
            learningProvider.overrideWith(() => mock),
            aiServiceProvider.overrideWithValue(rec),
            reviewProvider.overrideWith(() => MockReviewNotifier()),
          ],
        );
        addTearDown(container2.dispose);
        container2.read(learningProvider);
        mock.lessonsCompleted = 10;
        container2.listen(sageAiProvider, (_, _) {});

        final notifier = container2.read(sageAiProvider.notifier);
        for (int i = 0; i < 12; i++) {
          final sent = await notifier.sendMessage('msg $i');
          expect(sent, isTrue);
          await pumpEventQueue();
          SageAiNotifier.resetRateLimits();
        }

        final last = rec.captured.last;
        // 19 históricos + 1 actual = 20 parts (el servidor rechaza >20).
        expect(last.length, equals(20));
        // La ventana se desliza: se descartan los 2 intercambios más viejos.
        expect(last.first.text, 'ok');
        expect(last.last.text, 'msg 11');
      },
    );
  });
}
