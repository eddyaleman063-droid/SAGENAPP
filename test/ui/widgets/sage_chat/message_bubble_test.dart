import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/models/chat_message.dart';
import 'package:sagen/ui/widgets/sage_chat/message_bubble.dart';

Widget _wrap({required ChatMessage message, required bool isUser}) {
  return MaterialApp(
    home: Scaffold(
      body: MessageBubble(message: message, isUser: isUser),
    ),
  );
}

void main() {
  testWidgets('renders user message aligned to the end', (tester) async {
    final message = ChatMessage(
      role: ChatRole.user,
      text: 'Hola Sage',
      time: DateTime.now(),
    );
    await tester.pumpWidget(_wrap(message: message, isUser: true));
    expect(find.text('Hola Sage'), findsOneWidget);
  });

  testWidgets('renders assistant message with avatar', (tester) async {
    final message = ChatMessage(
      role: ChatRole.assistant,
      text: 'Hola, ¿en qué te ayudo?',
      time: DateTime.now(),
    );
    await tester.pumpWidget(_wrap(message: message, isUser: false));
    expect(find.text('Hola, ¿en qué te ayudo?'), findsOneWidget);
    expect(find.byIcon(Icons.auto_awesome_rounded), findsOneWidget);
  });

  testWidgets('renders markdown formatting for assistant text', (tester) async {
    final message = ChatMessage(
      role: ChatRole.assistant,
      text: 'Usa **XP** para desbloquear cosas',
      time: DateTime.now(),
    );
    await tester.pumpWidget(_wrap(message: message, isUser: false));
    expect(find.textContaining('XP'), findsOneWidget);
  });
}
