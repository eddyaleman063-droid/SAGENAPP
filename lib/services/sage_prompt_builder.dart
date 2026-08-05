import '../models/chat_message.dart';
import '../models/sage_personality_profile.dart';

/// Builds the system prompt for the Sage AI tutor.
class SagePromptBuilder {
  String buildSystemInstruction({
    String userName = '',
    int userLevel = 1,
    int currentStreak = 0,
    List<String> weakTopics = const [],
  }) {
    return SagePersonalityProfile().getSystemPrompt(
      userName: userName,
      userLevel: userLevel,
      currentStreak: currentStreak,
      weakTopics: weakTopics,
    );
  }

  /// Strips control characters; keeps printable ASCII and common Unicode.
  static String _sanitize(String text) {
    final sanitized = text.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '');
    return sanitized.length > 5000 ? sanitized.substring(0, 5000) : sanitized;
  }

  List<Map<String, dynamic>> buildContents(List<ChatMessage> messages) {
    return messages.map((m) {
      final role = m.role == ChatRole.user ? 'user' : 'model';
      return {
        'role': role,
        'parts': [{'text': _sanitize(m.text)}],
      };
    }).toList();
  }
}
