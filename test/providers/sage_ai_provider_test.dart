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

class MockReviewNotifier extends ReviewNotifier {
  @override
  ReviewState build() => const ReviewState();
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

    test('suggestionChips returns expected list', () {
      final state = container.read(sageAiProvider);
      expect(state.suggestionChips, [
        'What is phishing?',
        'Create a strong password',
        'Identify a scam',
      ]);
    });
  });
}
