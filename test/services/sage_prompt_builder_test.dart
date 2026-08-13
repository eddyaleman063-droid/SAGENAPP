import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/models/chat_message.dart';
import 'package:sagen/services/sage_prompt_builder.dart';

void main() {
  late SagePromptBuilder builder;

  setUp(() {
    builder = SagePromptBuilder();
  });

  group('SagePromptBuilder', () {
    test('buildContents maps user message to user role', () {
      final messages = [
        ChatMessage(role: ChatRole.user, text: 'Hello', time: DateTime.now()),
      ];
      final contents = builder.buildContents(messages);
      expect(contents.length, 1);
      expect(contents[0]['role'], 'user');
      expect(contents[0]['parts'], hasLength(1));
      expect(contents[0]['parts'][0]['text'], 'Hello');
    });

    test('buildContents maps assistant message to model role', () {
      final messages = [
        ChatMessage(
          role: ChatRole.assistant,
          text: 'Hi there',
          time: DateTime.now(),
        ),
      ];
      final contents = builder.buildContents(messages);
      expect(contents[0]['role'], 'model');
      expect(contents[0]['parts'][0]['text'], 'Hi there');
    });

    test('buildContents preserves message order', () {
      final messages = [
        ChatMessage(role: ChatRole.user, text: 'Q1', time: DateTime.now()),
        ChatMessage(role: ChatRole.assistant, text: 'A1', time: DateTime.now()),
        ChatMessage(role: ChatRole.user, text: 'Q2', time: DateTime.now()),
      ];
      final contents = builder.buildContents(messages);
      expect(contents.length, 3);
      expect(contents[0]['role'], 'user');
      expect(contents[0]['parts'][0]['text'], 'Q1');
      expect(contents[1]['role'], 'model');
      expect(contents[2]['role'], 'user');
    });

    test('buildContents handles empty list', () {
      final contents = builder.buildContents([]);
      expect(contents, isEmpty);
    });

    test('buildSystemInstruction returns string with Sage system prompt', () {
      final instruction = builder.buildSystemInstruction();
      expect(instruction, isA<String>());
      expect(instruction, contains('Sage'));
      expect(instruction, contains('SAGEN'));
    });
  });
}
