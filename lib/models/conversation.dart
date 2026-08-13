import 'package:freezed_annotation/freezed_annotation.dart';
import 'chat_message.dart';

part 'conversation.freezed.dart';
part 'conversation.g.dart';

@freezed
class Conversation with _$Conversation {
  const Conversation._();

  const factory Conversation({
    @Default('') String id,
    @Default('') String title,
    @Default([]) List<ChatMessage> messages,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isPinned,
    @Default(false) bool isFavorite,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);

  String get preview {
    if (messages.isEmpty) return '';
    final last = messages.last;
    final codeUnits = last.text.runes.toList();
    final text = codeUnits.length > 80
        ? '${String.fromCharCodes(codeUnits.take(80))}...'
        : last.text;
    return '${last.role == ChatRole.user ? "👤 " : "🛡️ "}$text';
  }

  bool get isLong => messages.length > 10;
}
