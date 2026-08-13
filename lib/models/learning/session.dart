import 'package:freezed_annotation/freezed_annotation.dart';
import 'lesson.dart';

part 'session.freezed.dart';
part 'session.g.dart';

@unfreezed
class Session with _$Session {
  Session._();

  factory Session({
    required String id,
    required String title,
    required String subtitle,
    required List<Lesson> lessons,
    @Default(false) bool completed,
  }) = _Session;

  factory Session.fromJson(Map<String, dynamic> json) =>
      _$SessionFromJson(json);

  double get progress {
    if (lessons.isEmpty) return 0;
    final done = lessons.where((l) => l.completed).length;
    return done / lessons.length;
  }

  int get completedCount => lessons.where((l) => l.completed).length;

  bool get isComplete => lessons.every((l) => l.completed);

  Lesson? get nextLesson => lessons.where((l) => !l.completed).firstOrNull;
}
