import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/models/learning/lesson.dart';
import 'package:sagen/models/learning/session.dart';
import 'package:sagen/models/learning/stage.dart';

Lesson _lesson(
  String id, {
  bool completed = false,
  int correct = 0,
  int total = 0,
}) {
  return Lesson(
    id: id,
    title: 'Leccion $id',
    subtitle: 'Sub',
    challenges: const [],
    completed: completed,
    correctAnswers: correct,
    totalQuestions: total,
  );
}

Stage _stageFixture() {
  final s1l1 = _lesson('s1_l1');
  final s1l2 = _lesson('s1_l2');
  final s2l1 = _lesson('s2_l1');
  final session1 = Session(
    id: 's1',
    title: 'Sesion 1',
    subtitle: 'Sub',
    lessons: [s1l1, s1l2],
  );
  final session2 = Session(
    id: 's2',
    title: 'Sesion 2',
    subtitle: 'Sub',
    lessons: [s2l1],
  );
  return Stage(
    id: 'stage_1',
    title: 'Etapa 1',
    subtitle: 'Sub',
    accent: Colors.blue,
    icon: Icons.shield,
    lessons: [s1l1, s1l2, s2l1],
    unlocked: true,
    sessions: [session1, session2],
  );
}

void main() {
  group('Stage.withLessons', () {
    test('actualiza la lista plana y las sublistas de sesion por id', () {
      final stage = _stageFixture();
      final updated = stage.withLessons(
        stage.lessons
            .map(
              (l) => l.id == 's1_l1'
                  ? l.copyWith(
                      completed: true,
                      correctAnswers: 12,
                      totalQuestions: 15,
                    )
                  : l,
            )
            .toList(),
      );

      // Lista plana actualizada.
      expect(updated.lessons.where((l) => l.completed).map((l) => l.id), [
        's1_l1',
      ]);
      expect(updated.completedCount, 1);
      expect(updated.progress, closeTo(1 / 3, 0.0001));
      expect(updated.isComplete, false);

      // Sesiones sincronizadas (compartian instancias al cargar).
      expect(updated.sessions[0].lessons[0].completed, true);
      expect(updated.sessions[0].lessons[0].correctAnswers, 12);
      expect(updated.sessions[0].lessons[0].totalQuestions, 15);
      expect(updated.sessions[0].lessons[1].completed, false);
      expect(updated.sessions[1].lessons[0].completed, false);

      // La sesion unica reporta su propia completitud.
      expect(updated.sessions[0].isComplete, false);
      expect(updated.sessions[0].completedCount, 1);
    });

    test('completar todas las lecciones de una sesion la marca completa', () {
      final stage = _stageFixture();
      final updated = stage.withLessons(
        stage.lessons
            .map(
              (l) => l.id.startsWith('s1_') ? l.copyWith(completed: true) : l,
            )
            .toList(),
      );

      expect(updated.sessions[0].isComplete, true);
      expect(updated.sessions[1].isComplete, false);
      expect(updated.isComplete, false);
    });

    test('no modifica la etapa original', () {
      final stage = _stageFixture();
      stage.withLessons(
        stage.lessons.map((l) => l.copyWith(completed: true)).toList(),
      );

      expect(stage.lessons.every((l) => !l.completed), true);
      expect(stage.sessions[0].lessons.every((l) => !l.completed), true);
      expect(stage.unlocked, true);
    });

    test('preserva la invariante lessons == sessions.expand(lessons)', () {
      final stage = _stageFixture();
      final updated = stage.withLessons(
        stage.lessons
            .map(
              (l) => l.id == 's2_l1'
                  ? l.copyWith(
                      completed: true,
                      correctAnswers: 10,
                      totalQuestions: 15,
                    )
                  : l,
            )
            .toList(),
      );

      expect(
        updated.lessons.map((l) => l.id).toList(),
        updated.sessions.expand((s) => s.lessons).map((l) => l.id).toList(),
      );
      expect(updated.assertConsistency, returnsNormally);
      expect(updated.sessions[1].lessons[0].completed, true);
    });

    test('etapa con sesiones vacias queda intacta', () {
      final stage = _stageFixture().copyWith(sessions: const []);
      final updated = stage.withLessons(
        stage.lessons.map((l) => l.copyWith(completed: true)).toList(),
      );

      expect(updated.lessons.every((l) => l.completed), true);
      expect(updated.sessions, isEmpty);
    });
  });
}
