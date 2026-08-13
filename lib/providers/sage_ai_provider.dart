import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../models/chat_message.dart';
import '../services/ai_service.dart';
import '../services/app_logger.dart';
import '../services/emotion_event_bus.dart';
import '../services/local_fallback_service.dart';
import 'providers.dart';

enum SageAiChatStatus { idle, loading, streaming, error }

class SageAiChatState {
  final List<ChatMessage> messages;
  final SageAiChatStatus status;
  final String streamingText;
  final String? errorMessage;
  final String userName;
  final int userLevel;
  final int currentStreak;
  final int lessonsCompleted;
  final List<String> weakTopics;

  const SageAiChatState({
    this.messages = const [],
    this.status = SageAiChatStatus.idle,
    this.streamingText = '',
    this.errorMessage,
    this.userName = '',
    this.userLevel = 1,
    this.currentStreak = 0,
    this.lessonsCompleted = 0,
    this.weakTopics = const [],
  });

  SageAiChatState copyWith({
    List<ChatMessage> Function()? messages,
    SageAiChatStatus? status,
    String? streamingText,
    String? Function()? errorMessage,
    String? userName,
    int? userLevel,
    int? currentStreak,
    int? lessonsCompleted,
    List<String>? weakTopics,
  }) {
    return SageAiChatState(
      messages: messages != null ? messages() : this.messages,
      status: status ?? this.status,
      streamingText: streamingText ?? this.streamingText,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      userName: userName ?? this.userName,
      userLevel: userLevel ?? this.userLevel,
      currentStreak: currentStreak ?? this.currentStreak,
      lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
      weakTopics: weakTopics ?? this.weakTopics,
    );
  }

  bool get isLocked => lessonsCompleted < 5;
  int get lessonsRequired => 5;
  double get progress => (lessonsCompleted / lessonsRequired).clamp(0.0, 1.0);
  bool get isLoading => status == SageAiChatStatus.loading;
  bool get isStreaming => status == SageAiChatStatus.streaming;
  bool get isBusy =>
      status == SageAiChatStatus.loading ||
      status == SageAiChatStatus.streaming;

  List<String> get suggestionChips => [
    'What is phishing?',
    'Create a strong password',
    'Identify a scam',
  ];
}

class SageAiNotifier extends AutoDisposeNotifier<SageAiChatState> {
  late final AiService _primaryService;
  late final LocalFallbackService _fallbackService;
  StreamSubscription<String>? _streamSub;

  DateTime _lastSendTime = DateTime.now().subtract(const Duration(seconds: 5));
  static const Duration _throttleDuration = Duration(seconds: 2);
  static const int _maxMessagesPerDay = 50;
  int _messagesSentToday = 0;
  DateTime _dayStart = DateTime.now();

  @override
  SageAiChatState build() {
    _streamSub?.cancel();
    _streamSub = null;
    _primaryService = ref.watch(aiServiceProvider);
    _fallbackService = LocalFallbackService();
    final learning = ref.watch(learningProvider);
    final reviewState = ref.watch(reviewProvider);
    final weakTopics = reviewState.topicScores.entries
        .where((e) => e.value > 3)
        .map((e) => e.key)
        .toList();
    ref.onDispose(() {
      _streamSub?.cancel();
    });
    return SageAiChatState(
      lessonsCompleted: learning.lessonsCompleted,
      userLevel: learning.currentLevel,
      weakTopics: weakTopics,
    );
  }

  void updateContext({
    String userName = '',
    int userLevel = 1,
    int currentStreak = 0,
  }) {
    state = state.copyWith(
      userName: userName,
      userLevel: userLevel,
      currentStreak: currentStreak,
    );
  }

  Future<void> sendMessage(String text) async {
    if (state.isLocked || text.trim().isEmpty || state.isBusy) return;
    if (DateTime.now().difference(_lastSendTime) < _throttleDuration) return;

    // Daily rate limiting
    final now = DateTime.now();
    if (now.day != _dayStart.day ||
        now.month != _dayStart.month ||
        now.year != _dayStart.year) {
      _messagesSentToday = 0;
      _dayStart = now;
    }
    if (_messagesSentToday >= _maxMessagesPerDay) {
      state = state.copyWith(
        errorMessage: () =>
            'You have reached the daily message limit. Try again tomorrow.',
      );
      return;
    }

    _lastSendTime = now;
    _messagesSentToday++;

    final userMsg = ChatMessage(
      role: ChatRole.user,
      text: text,
      time: DateTime.now(),
    );
    final assistantMsg = ChatMessage(
      role: ChatRole.assistant,
      text: '',
      time: DateTime.now(),
    );

    final messages = [...state.messages, userMsg, assistantMsg];
    const maxMessages = 100;
    if (messages.length > maxMessages) {
      messages.removeRange(0, messages.length - maxMessages);
    }

    state = state.copyWith(
      messages: () => messages,
      status: SageAiChatStatus.loading,
      streamingText: '',
      errorMessage: () => null,
    );

    ref.read(emotionEventBusProvider).fire(EmotionEventType.chatSent);

    final contextMessages = _buildContextMessages(text);
    final service = _primaryService.isAvailable
        ? _primaryService
        : _fallbackService;

    await _streamSub?.cancel();
    final buffer = StringBuffer();
    _streamSub = service
        .generateStream(
          contextMessages,
          userName: state.userName,
          userLevel: state.userLevel,
          currentStreak: state.currentStreak,
          weakTopics: state.weakTopics,
        )
        .listen(
          (chunk) {
            if (state.status == SageAiChatStatus.loading) {
              state = state.copyWith(status: SageAiChatStatus.streaming);
            }
            buffer.write(chunk);
            state = state.copyWith(streamingText: buffer.toString());
          },
          onDone: () {
            _finalizeResponse(text);
          },
          onError: (Object e) {
            AppLogger().error('SageAiProvider stream error', e);
            ref.read(emotionEventBusProvider).fire(EmotionEventType.chatError);
            _fallbackResponse(text);
          },
        );
  }

  void _finalizeResponse(String lastQuestion) {
    final finalText = state.streamingText.trim();
    if (finalText.isEmpty && state.messages.length >= 2) {
      _fallbackResponse(lastQuestion);
      return;
    }
    _applyAssistantMessage(finalText);
  }

  void _fallbackResponse(String lastQuestion) {
    _streamSub?.cancel();
    _streamSub = null;

    state = state.copyWith(status: SageAiChatStatus.loading);

    final buffer = StringBuffer();
    _streamSub = _fallbackService
        .generateStream([
          ChatMessage(
            role: ChatRole.user,
            text: lastQuestion,
            time: DateTime.now(),
          ),
        ])
        .listen(
          (chunk) {
            if (state.status == SageAiChatStatus.loading) {
              state = state.copyWith(status: SageAiChatStatus.streaming);
            }
            buffer.write(chunk);
            state = state.copyWith(streamingText: buffer.toString());
          },
          onDone: () {
            _applyAssistantMessage(state.streamingText.trim());
          },
          onError: (_) {
            _applyAssistantMessage(
              'My mental connection is weak right now, but keep practicing and ask me again later.',
            );
          },
        );
  }

  void _applyAssistantMessage(String text) {
    _streamSub?.cancel();
    _streamSub = null;
    final messages = List<ChatMessage>.from(state.messages);
    final idx = messages.length - 1;
    if (idx >= 0 && messages[idx].role == ChatRole.assistant) {
      messages[idx] = ChatMessage(
        role: ChatRole.assistant,
        text: text,
        time: messages[idx].time,
      );
    }
    state = state.copyWith(
      messages: () => messages,
      streamingText: '',
      errorMessage: () => null,
      status: SageAiChatStatus.idle,
    );

    ref.read(emotionEventBusProvider).fire(EmotionEventType.chatReceived);
  }

  List<ChatMessage> _buildContextMessages(String currentText) {
    final userMsg = ChatMessage(
      role: ChatRole.user,
      text: currentText,
      time: DateTime.now(),
    );

    final recent = <ChatMessage>[];
    final start = state.messages.length > AppConfig.maxContextMessages * 2
        ? state.messages.length - AppConfig.maxContextMessages * 2
        : 0;
    for (int i = start; i < state.messages.length - 1; i++) {
      recent.add(state.messages[i]);
    }
    recent.add(userMsg);
    return recent;
  }

  void clearMessages() {
    _streamSub?.cancel();
    _streamSub = null;
    state = state.copyWith(
      messages: () => [],
      streamingText: '',
      errorMessage: () => null,
      status: SageAiChatStatus.idle,
    );
  }
}
