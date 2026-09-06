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

  // Incremental streaming state to avoid O(n²) whole-buffer copies per flush.
  String _streamText = '';
  int _publishedLen = 0;

  static DateTime _lastSendTime = DateTime.now().subtract(
    const Duration(seconds: 5),
  );
  static const Duration _throttleDuration = Duration(seconds: 2);

  // NUEVO-fix: el límite diario (50/día) ahora es SERVER-AUTHORITATIVE
  // (functions/sage_usage + functions/ai_streaming.js -> checkDailyUsage).
  // Antes el cliente llevaba un static en memoria que se reseteaba reiniciando
  // la app o cerrando sesión, y contaba INTENTOS en vez de entregas.
  // Aquí solo se recuerda CUÁNDO el servidor confirmó el límite para evitar
  // re-martillar el endpoint el mismo día; el autoritativo es siempre el server.
  DateTime? _dailyLimitSetAt;

  bool _isSameLocalDay(DateTime a, DateTime b) =>
      a.day == b.day && a.month == b.month && a.year == b.year;

  bool get _isDailyLimitReached {
    final at = _dailyLimitSetAt;
    if (at == null) return false;
    return _isSameLocalDay(at, DateTime.now());
  }

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
    // Temas débiles canónicos del repaso (excluye temas reservados como
    // 'review'/'lesson' que no son temas de curso).
    final weakTopics = ref.read(reviewProvider.notifier).weakTopics;
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
    // NUEVO-fix: bloqueo local solo-espejo del mismo día. El server decide la
    // verdad; este cortocircuito evita que un usuario en límite re-martille el
    // endpoint HTTP (las respuestas 429 con code sage_daily_limit ya no
    // queman cuota porque el consumo ocurre SOLO sobre entregas reales).
    if (_isDailyLimitReached) {
      state = state.copyWith(lastError: () => 'daily_limit');
      return false;
    }

    _lastSendTime = DateTime.now();

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

    final messages = <ChatMessage>[..._messages];
    if (isRetry && messages.isNotEmpty && messages.last.role == ChatRole.user) {
      // NUEVO-fix: en retry el último mensaje de usuario ya existe y se
      // reutiliza; antes se appendeaba uno nuevo y el transcript (y el
      // contexto enviado) duplicaba el texto.
      messages.add(assistantMsg);
    } else {
      messages
        ..add(userMsg)
        ..add(assistantMsg);
    }
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

    final sentiment = ref
        .read(sageEmotionServiceProvider)
        .resolveUserSentiment(text);
    if (sentiment != null) {
      ref
          .read(emotionEventBusProvider)
          .fireEmotion(EmotionEventType.chatSent, sentiment);
    } else {
      ref.read(emotionEventBusProvider).fire(EmotionEventType.chatSent);
    }

    final contextMessages = _buildContextMessages(text);
    final service = _primaryService.isAvailable
        ? _primaryService
        : _fallbackService;

    await _streamSub?.cancel();
    _streamFlushTimer?.cancel();
    _streamText = '';
    _publishedLen = 0;
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
            _streamText += chunk;
            _scheduleStreamFlush();
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
            if (e is AiException && e.type == AiErrorType.dailyLimit) {
              // NUEVO-fix: el servidor negó la cuota diaria. Se informa el
              // límite SIN ejecutar el fallback local (haría creer que Sage
              // respondió) y SIN consumir cuota extra.
              _handleDailyLimit();
              return;
            }
            AppLogger().error('SageAiProvider stream error', e);
            ref.read(emotionEventBusProvider).fire(EmotionEventType.chatError);
            _fallbackResponse(text);
          },
        );
    return true;
  }

  void _scheduleStreamFlush() {
    if (_streamFlushTimer != null && _streamFlushTimer!.isActive) return;
    _streamFlushTimer = Timer(const Duration(milliseconds: 50), () {
      if (_streamText.length > _publishedLen) {
        final delta = _streamText.substring(_publishedLen);
        _publishedLen = _streamText.length;
        state = state.copyWith(streamingText: state.streamingText + delta);
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
    // NUEVO-fix: si existió el achievement 'sage_talk', nadie lo llamaba
    // porque recordSageTalk() no tenía invocaciones en el flujo de chat.
    // Aquí se cuenta una entrega real de Gemini (no fallback ni vacía).
    ref.read(learningProvider.notifier).recordSageTalk();
  }

  void _fallbackResponse(String lastQuestion) {
    _streamSub?.cancel();
    _streamFlushTimer?.cancel();
    _streamSub = null;

    state = state.copyWith(status: SageAiChatStatus.loading, streamingText: '');
    _streamText = '';
    _publishedLen = 0;

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
            _streamText += chunk;
            _scheduleStreamFlush();
          },
          onDone: () {
            _streamFlushTimer?.cancel();
            _streamFlushTimer = null;
            final finalText = buffer.toString().trim();
            if (finalText.isEmpty) {
              _showConnectionWeak();
            } else {
              _applyAssistantMessage(finalText);
            }
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

  // NUEVO-fix: respuesta al límite diario server-authoritative. El servidor
  // rechazó el mensaje (429 + code sage_daily_limit) sin consumir cuota.
  // El assistant vacío se elimina, el banner muestra el mensaje de límite, y
  // el registro local evita reintentar el mismo día.
  void _handleDailyLimit() {
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
    _dailyLimitSetAt = DateTime.now();
    state = state.copyWith(
      messages: () => messages,
      streamingText: '',
      lastError: () => 'daily_limit',
      status: SageAiChatStatus.idle,
    );
  }

  void _applyAssistantMessage(String text, {bool skipEmotion = false}) {
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
    if (!skipEmotion) {
      ref.read(emotionEventBusProvider).fire(EmotionEventType.chatReceived);
    }
  }

  List<ChatMessage> _buildContextMessages(String currentText) {
    final userMsg = ChatMessage(
      role: ChatRole.user,
      text: currentText,
      time: DateTime.now(),
    );

    // NUEVO-fix: el servidor (ai_streaming.js) rechaza con 400 las peticiones
    // con más de 20 partes de contents. Antes se usaba maxContextMessages*2
    // (hasta 39 envíos), así que las conversaciones con >10 intercambios
    // dejaban de funcionar. Ahora la ventana histórica es maxContextMessages-1
    // y el total nunca supera el cap del servidor.
    const historyCap = AppConfig.maxContextMessages - 1;
    final end = state.messages.length - 2;
    final start = end > historyCap ? end - historyCap : 0;
    final recent = <ChatMessage>[];
    for (int i = start; i < end; i++) {
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
      _applyAssistantMessage(text, skipEmotion: true);
    } else {
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
        status: SageAiChatStatus.idle,
      );
    }
  }

  void clearError() {
    state = state.copyWith(lastError: () => null, errorMessage: () => null);
  }

  void clearMessages() {
    _streamSub?.cancel();
    _streamFlushTimer?.cancel();
    _streamSub = null;
    _streamFlushTimer = null;
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
    _lastSendTime = DateTime.now().subtract(const Duration(seconds: 5));
  }
}
