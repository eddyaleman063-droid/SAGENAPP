import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/models/chat_message.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/sage_emotion_service.dart';
import 'package:sagen/ui/widgets/common/sage_emotion_widget.dart';
import 'package:sagen/ui/widgets/sage_chat/empty_chat.dart';
import 'package:sagen/ui/widgets/sage_chat/message_bubble.dart';
import 'package:sagen/ui/widgets/sage_chat/message_list.dart';

class _NoPrecacheSageEmotionService extends SageEmotionService {
  @override
  Future<void> ensurePrecached(SageEmotion emotion) async {}
}

class _FakeSageAiNotifier extends SageAiNotifier {
  _FakeSageAiNotifier(this._state);
  final SageAiChatState _state;
  @override
  SageAiChatState build() => _state;
}

List<ChatMessage> _messages(int count) {
  final now = DateTime.now();
  return List.generate(count, (i) {
    return ChatMessage(
      role: i.isEven ? ChatRole.assistant : ChatRole.user,
      text: 'mensaje $i',
      time: now.add(Duration(minutes: i)),
    );
  });
}

Widget _wrap(
  List<ChatMessage> messages, {
  required bool isStreaming,
  required ScrollController ctrl,
  String streamingText = '',
}) {
  return ProviderScope(
    overrides: [
      reduceAnimationsProvider.overrideWithValue(true),
      sageEmotionServiceProvider.overrideWithValue(
        _NoPrecacheSageEmotionService(),
      ),
      sageAiProvider.overrideWith(
        () =>
            _FakeSageAiNotifier(SageAiChatState(streamingText: streamingText)),
      ),
    ],
    child: MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SizedBox(
          height: 300,
          child: MessageList(
            messages: messages,
            isStreaming: isStreaming,
            scrollCtrl: ctrl,
          ),
        ),
      ),
    ),
  );
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  testWidgets('lista vacia muestra EmptyChat', (tester) async {
    final ctrl = ScrollController();
    await tester.pumpWidget(_wrap(const [], isStreaming: false, ctrl: ctrl));
    await _settle(tester);
    expect(find.byType(EmptyChat), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('renderiza burbuja de usuario y assistente', (tester) async {
    final ctrl = ScrollController();
    await tester.pumpWidget(
      _wrap(_messages(2), isStreaming: false, ctrl: ctrl),
    );
    await _settle(tester);
    expect(find.byType(MessageBubble), findsNWidgets(2));
    expect(find.text('mensaje 0'), findsOneWidget);
    expect(find.text('mensaje 1'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('muestra burbuja streaming con texto en curso', (tester) async {
    final ctrl = ScrollController();
    await tester.pumpWidget(
      _wrap(
        _messages(1),
        isStreaming: true,
        ctrl: ctrl,
        streamingText: 'generando respuesta...',
      ),
    );
    await _settle(tester);
    expect(find.text('generando respuesta...'), findsOneWidget);
    expect(find.byType(SageEmotionWidget), findsWidgets);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('isStreaming sin streamingText no agrega burbuja extra', (
    tester,
  ) async {
    final ctrl = ScrollController();
    await tester.pumpWidget(_wrap(_messages(1), isStreaming: true, ctrl: ctrl));
    await _settle(tester);
    expect(find.byType(MessageBubble), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('al crecer la lista cerca del borde programa scroll', (
    tester,
  ) async {
    final ctrl = ScrollController();
    await tester.pumpWidget(
      _wrap(_messages(9), isStreaming: false, ctrl: ctrl),
    );
    await tester.pump();
    ctrl.jumpTo(ctrl.position.maxScrollExtent);
    await tester.pump();

    await tester.pumpWidget(
      _wrap(_messages(11), isStreaming: false, ctrl: ctrl),
    );
    await tester.pump(const Duration(milliseconds: 150));

    expect(ctrl.position.outOfRange, isFalse);
    expect(ctrl.hasClients, isTrue);
    await _settle(tester);
    await tester.pump(const Duration(seconds: 1));
  });
}
