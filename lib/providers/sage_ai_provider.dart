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
  final String? lastError;
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
    this.lastError,
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
    String? Function()? lastError,
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
      lastError: lastError != null ? lastError() : this.lastError,
      userName: userName ?? this.userName,
      userLevel: userLevel ?? this.userLevel,
      currentStreak: currentStreak ?? this.currentStreak,
      lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
      weakTopics: weakTopics ?? this.weakTopics,
    );
  }

  bool get isLocked => lessonsCompleted < 10;
  int get lessonsRequired => 10;
  double get progress => (lessonsCompleted / lessonsRequired).clamp(0.0, 1.0);
  bool get isLoading => status == SageAiChatStatus.loading;
  bool get isStreaming => status == SageAiChatStatus.streaming;
  bool get isBusy =>
      status == SageAiChatStatus.loading ||
      status == SageAiChatStatus.streaming;
}

class SageAiNotifier extends AutoDisposeNotifier<SageAiChatState> {
  late final AiService _primaryService;
  late final LocalFallbackService _fallbackService;
  StreamSubscription<String>? _streamSub;
  Timer? _streamFlushTimer;

  static DateTime _lastSendTime = DateTime.now().subtract(
    const Duration(seconds: 5),
  );
  static const Duration _throttleDuration = Duration(seconds: 2);
  static const int _maxMessagesPerDay = 50;
  static int _messagesSentToday = 0;
  static DateTime _dayStart = DateTime.now();

  // Se preserva a través de rebuilds para no perder la conversación.
  List<ChatMessage> _messages = const [];

  @override
  SageAiChatState build() {
    _primaryService = ref.read(aiServiceProvider);
    _fallbackService = LocalFallbackService();
    // Contexto leído al construir; se refresca al enviar mensajes. No se
    // observan learning/review aquí para que completar una lección no
    // reinicie la conversación en curso.
    final learning = ref.read(learningProvider);
    final reviewState = ref.read(reviewProvider);
    final weakTopics = reviewState.topicScores.entries
        .where((e) => e.value > 3)
        .map((e) => e.key)
        .toList();
    ref.onDispose(() {
      _streamSub?.cancel();
      _streamFlushTimer?.cancel();
    });
    return SageAiChatState(
      messages: _messages,
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

  Future<bool> sendMessage(String text, {bool isRetry = false}) async {
    if (state.isLocked || text.trim().isEmpty || state.isBusy) return false;
    if (!isRetry &&
        DateTime.now().difference(_lastSendTime) < _throttleDuration) {
      return false;
    }

    // Daily rate limiting
    final now = DateTime.now();
    if (now.day != _dayStart.day ||
        now.month != _dayStart.month ||
        now.year != _dayStart.year) {
      _messagesSentToday = 0;
      _dayStart = now;
    }
    if (_messagesSentToday >= _maxMessagesPerDay) {
      state = state.copyWith(lastError: () => 'daily_limit');
      return false;
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

    final messages = [..._messages, userMsg, assistantMsg];
    const maxMessages = 100;
    if (messages.length > maxMessages) {
      messages.removeRange(0, messages.length - maxMessages);
    }
    _messages = messages;

    state = state.copyWith(
      messages: () => messages,
      status: SageAiChatStatus.loading,
      streamingText: '',
      errorMessage: () => null,
      lastError: () => null,
    );

    ref.read(emotionEventBusProvider).fire(EmotionEventType.chatSent);

    final contextMessages = _buildContextMessages(text);
    final service = _primaryService.isAvailable
        ? _primaryService
        : _fallbackService;

    await _streamSub?.cancel();
    _streamFlushTimer?.cancel();
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
            _scheduleStreamFlush(buffer);
          },
          onDone: () {
            _streamFlushTimer?.cancel();
            _streamFlushTimer = null;
            state = state.copyWith(streamingText: buffer.toString());
            _finalizeResponse(text);
          },
          onError: (Object e) {
            _streamFlushTimer?.cancel();
            _streamFlushTimer = null;
            AppLogger().error('SageAiProvider stream error', e);
            ref.read(emotionEventBusProvider).fire(EmotionEventType.chatError);
            _fallbackResponse(text);
          },
        );
    return true;
  }

  void _scheduleStreamFlush(StringBuffer buffer) {
    if (_streamFlushTimer != null && _streamFlushTimer!.isActive) return;
    _streamFlushTimer = Timer(const Duration(milliseconds: 50), () {
      final text = buffer.toString();
      if (text != state.streamingText) {
        state = state.copyWith(streamingText: text);
      }
    });
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
    _streamFlushTimer?.cancel();
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
            _scheduleStreamFlush(buffer);
          },
          onDone: () {
            _streamFlushTimer?.cancel();
            _streamFlushTimer = null;
            final finalText = buffer.toString().trim();
            _applyAssistantMessage(finalText);
          },
          onError: (e) {
            AppLogger().error('SageAiProvider fallback stream error', e);
            _streamFlushTimer?.cancel();
            _streamFlushTimer = null;
            _showConnectionWeak();
          },
        );
  }

  void _showConnectionWeak() {
    _streamSub?.cancel();
    _streamSub = null;
    final messages = List<ChatMessage>.from(_messages);
    final idx = messages.length - 1;
    if (idx >= 0 &&
        messages[idx].role == ChatRole.assistant &&
        messages[idx].text.isEmpty) {
      messages.removeAt(idx);
    }
    _messages = messages;
    state = state.copyWith(
      messages: () => messages,
      streamingText: '',
      lastError: () => 'connection_weak',
      status: SageAiChatStatus.idle,
    );
  }

  void _applyAssistantMessage(String text) {
    _streamSub?.cancel();
    _streamSub = null;
    final messages = List<ChatMessage>.from(_messages);
    final idx = messages.length - 1;
    if (idx >= 0 && messages[idx].role == ChatRole.assistant) {
      messages[idx] = ChatMessage(
        role: ChatRole.assistant,
        text: text,
        time: messages[idx].time,
      );
    }
    _messages = messages;
    state = state.copyWith(
      messages: () => messages,
      streamingText: '',
      errorMessage: () => null,
      lastError: () => null,
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
    for (int i = start; i < state.messages.length - 2; i++) {
      recent.add(state.messages[i]);
    }
    recent.add(userMsg);
    return recent;
  }

  void cancelStream() {
    _streamSub?.cancel();
    _streamFlushTimer?.cancel();
    _streamSub = null;
    _streamFlushTimer = null;
    final text = state.streamingText.trim();
    if (text.isNotEmpty) {
      _applyAssistantMessage(text);
    } else {
      state = state.copyWith(streamingText: '', status: SageAiChatStatus.idle);
    }
  }

  void clearError() {
    state = state.copyWith(lastError: () => null, errorMessage: () => null);
  }

  void clearMessages() {
    _streamSub?.cancel();
    _streamSub = null;
    _messages = const [];
    state = state.copyWith(
      messages: () => [],
      streamingText: '',
      errorMessage: () => null,
      lastError: () => null,
      status: SageAiChatStatus.idle,
    );
  }

  static void resetRateLimits() {
    _messagesSentToday = 0;
    _dayStart = DateTime.now();
    _lastSendTime = DateTime.now().subtract(const Duration(seconds: 5));
  }
}
