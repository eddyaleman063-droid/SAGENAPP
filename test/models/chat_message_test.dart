import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/models/chat_message.dart';

void main() {
  test('constructs a message with role and text', () {
    final message = ChatMessage(
      role: ChatRole.user,
      text: 'Hola Sage',
      time: DateTime(2026, 1, 1),
    );
    expect(message.role, ChatRole.user);
    expect(message.text, 'Hola Sage');
    expect(message.time, DateTime(2026, 1, 1));
  });

  test('fromJson parses role, text and time', () {
    final message = ChatMessage.fromJson({
      'role': 'assistant',
      'text': '¡Hola!',
      'time': '2026-01-02T10:30:00.000',
    });
    expect(message.role, ChatRole.assistant);
    expect(message.text, '¡Hola!');
    expect(message.time, DateTime(2026, 1, 2, 10, 30));
  });

  test('copyWith overrides fields', () {
    final message = ChatMessage(
      role: ChatRole.user,
      text: 'a',
      time: DateTime(2026, 1, 1),
    );
    final updated = message.copyWith(role: ChatRole.assistant, text: 'b');
    expect(updated.role, ChatRole.assistant);
    expect(updated.text, 'b');
    expect(updated.time, DateTime(2026, 1, 1));
  });

  test('messages with equal fields are equal', () {
    final a = ChatMessage(
      role: ChatRole.user,
      text: 'x',
      time: DateTime(2026, 1, 1),
    );
    final b = ChatMessage(
      role: ChatRole.user,
      text: 'x',
      time: DateTime(2026, 1, 1),
    );
    expect(a, b);
    expect(a.hashCode, b.hashCode);
  });

  test('messages with different fields are not equal', () {
    final a = ChatMessage(
      role: ChatRole.user,
      text: 'x',
      time: DateTime(2026, 1, 1),
    );
    final b = ChatMessage(
      role: ChatRole.user,
      text: 'y',
      time: DateTime(2026, 1, 1),
    );
    expect(a, isNot(b));
  });
}
