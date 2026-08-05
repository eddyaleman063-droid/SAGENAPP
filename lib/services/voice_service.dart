import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'app_logger.dart';

enum VoiceState { idle, listening, processing, error, denied }

/// Manages voice input via speech-to-text.
class VoiceService {
  final SpeechToText _speech = SpeechToText();
  final AppLogger _logger = AppLogger();
  bool _available = false;
  bool _initialized = false;
  String _lastWords = '';
  VoiceState _state = VoiceState.idle;
  Completer<void>? _resultCompleter;
  bool _isActuallyListening = false;

  bool get available => _available;
  bool get isListening => _isActuallyListening;
  bool get isProcessing => _state == VoiceState.processing;
  String get lastWords => _lastWords;
  VoiceState get state => _state;

  static const _locale = 'es-ES';

  Future<void> init() async {
    if (_initialized) return;
    try {
      _available = await _speech.initialize(
        onError: (e) {
          _state = VoiceState.error;
          _isActuallyListening = false;
        },
        onStatus: (status) {
          if (status == 'denied') {
            _state = VoiceState.denied;
          }
        },
      );
    } catch (e) {
      _logger.warning('VoiceService: init failed: $e');
      _available = false;
    }
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    await init();
    return _available;
  }

  Future<void> startListening({
    required void Function(String text) onResult,
    required VoidCallback onDone,
  }) async {
    if (_isActuallyListening) return;

    await init();
    if (!_available) {
      _state = VoiceState.denied;
      return;
    }

    _state = VoiceState.listening;
    _isActuallyListening = true;
    _lastWords = '';
    _resultCompleter = Completer<void>();

    try {
      await _speech.listen(
        onResult: (SpeechRecognitionResult result) {
          _lastWords = result.recognizedWords;
          onResult(_lastWords);
          if (result.finalResult) {
            _isActuallyListening = false;
            _state = VoiceState.processing;
            if (_resultCompleter != null && !_resultCompleter!.isCompleted) {
              _resultCompleter!.complete();
            }
            onDone();
          }
        },
        listenOptions: SpeechListenOptions(
          cancelOnError: true,
          localeId: _locale,
          listenFor: const Duration(seconds: 15),
        ),
      );
    } catch (e) {
      _logger.warning('VoiceService: startListening failed: $e');
      _state = VoiceState.error;
      _isActuallyListening = false;
      return;
    }
  }

  Future<void> stopListening() async {
    _isActuallyListening = false;
    await _speech.stop();
    if (_resultCompleter != null && !_resultCompleter!.isCompleted) {
      _resultCompleter!.complete();
    }
    _resultCompleter = null;
    _state = VoiceState.idle;
  }

  void cancel() {
    _isActuallyListening = false;
    _speech.cancel();
    _resultCompleter = null;
    _state = VoiceState.idle;
  }

  void resetState() {
    _isActuallyListening = false;
    _state = VoiceState.idle;
    _lastWords = '';
    _resultCompleter = null;
  }

  void dispose() {
    _speech.stop();
  }
}
