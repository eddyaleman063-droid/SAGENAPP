import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/models/learning/challenge.dart';
import 'package:sagen/models/learning/lesson_type.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/ui/widgets/learning/quiz_session.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  List<Challenge> buildChallenges() => [
    const Challenge(
      id: 'q1',
      question: 'Pregunta 1',
      type: LessonType.multipleChoice,
      options: ['A1', 'B1', 'C1', 'D1'],
      correctIndex: 0,
      explanation: 'explicacion 1',
    ),
    const Challenge(
      id: 'q2',
      question: 'Pregunta 2',
      type: LessonType.multipleChoice,
      options: ['A2', 'B2', 'C2', 'D2'],
      correctIndex: 0,
      explanation: 'explicacion 2',
    ),
    const Challenge(
      id: 'q3',
      question: 'Pregunta 3',
      type: LessonType.multipleChoice,
      options: ['A3', 'B3', 'C3', 'D3'],
      correctIndex: 0,
      explanation: 'explicacion 3',
    ),
  ];

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        reduceAnimationsProvider.overrideWithValue(true),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          return MaterialApp(
            locale: const Locale('es'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: QuizSession(
                challenges: buildChallenges(),
                stageId: 'st1',
                lessonId: 'lesson_1_1',
                lessonTitle: 'Lección',
                onComplete: (_) {},
              ),
            ),
          );
        },
      ),
    );
  }

  testWidgets(
    'doble tap en Next no salta preguntas (guard transitorio anti-race)',
    (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Pregunta 1 visible.
      expect(find.text('Pregunta 1'), findsOneWidget);

      // Responder correctamente la primera (opción 0).
      await tester.tap(find.text('A1'));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(QuizSession)),
      )!;
      final nextButton = find.text(l10n.nextText);
      expect(nextButton, findsOneWidget);
      await tester.ensureVisible(nextButton);
      await tester.pumpAndSettle();

      // Doble tap rápido SIN pumpAndSettle intermedio: el segundo evento llega
      // mientras la animación de reverse está en curso.
      await tester.tap(nextButton, warnIfMissed: false);
      await tester.tap(nextButton, warnIfMissed: false);
      await tester.pump();

      // En plena transición (aún NO se ha resuelto el reverse), la segunda
      // llamada _next() debe ser ignorada: SOLO una pregunta avanzará
      // al completar la animación.
      await tester.pumpAndSettle();

      // Debe mostrar la pregunta 2 (una sola transición), nunca la 3.
      expect(find.text('Pregunta 2'), findsOneWidget);
      expect(find.text('Pregunta 3'), findsNothing);
    },
  );

  testWidgets(
    'doble tap en See Results no dispara onComplete dos veces (guard anti doble award)',
    (tester) async {
      var completeCount = 0;
      final single = [
        const Challenge(
          id: 'q1',
          question: 'Pregunta única',
          type: LessonType.multipleChoice,
          options: ['A1', 'B1', 'C1', 'D1'],
          correctIndex: 0,
          explanation: 'explicacion 1',
        ),
      ];
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            prefsProvider.overrideWithValue(prefs),
            reduceAnimationsProvider.overrideWithValue(true),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              return MaterialApp(
                locale: const Locale('es'),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: Scaffold(
                  body: QuizSession(
                    challenges: single,
                    stageId: 'st1',
                    lessonId: 'lesson_1_2',
                    lessonTitle: 'Lección',
                    onComplete: (_) => completeCount++,
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Con UN solo challenge, responderlo correctamente lo convierte en la
      // última pregunta y aparece "Ver resultados".
      await tester.tap(find.text('A1'));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(QuizSession)),
      )!;
      final seeResults = find.text(l10n.firstLessonSeeResults);
      expect(seeResults, findsOneWidget);
      await tester.ensureVisible(seeResults);
      await tester.pumpAndSettle();

      // Doble tap rápido sobre "Ver resultados": onComplete debe dispararse UNA
      // sola vez, evitando duplicar XP/gemas/repasos en el flujo de repaso.
      await tester.tap(seeResults, warnIfMissed: false);
      await tester.tap(seeResults, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(completeCount, 1);
    },
  );

  testWidgets(
    'reanuda en la PRIMERA pregunta sin responder (no la salta tras Next)',
    (tester) async {
      // Reproduce el bug histórico: data[5] apuntaba a la pregunta PENDIENTE
      // (q2) tras Next, pero se trataba como "última respondida" y al reanudar
      // se saltaba saltaba q2. El contrato nuevo: data[5] es la PRIMERA sin
      // responder y la reanudación continúa AHÍ MISMO.
      await prefs.setStringList('quiz_progress_resume_key', [
        'st1',
        '1',
        '1',
        'q1,q2,q3',
        DateTime.now().toIso8601String(),
        'q2',
      ]);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            prefsProvider.overrideWithValue(prefs),
            reduceAnimationsProvider.overrideWithValue(true),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              return MaterialApp(
                locale: const Locale('es'),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: Scaffold(
                  body: QuizSession(
                    challenges: buildChallenges(),
                    stageId: 'st1',
                    lessonId: 'resume_key',
                    lessonTitle: 'Lección',
                    onComplete: (_) {},
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Debe reanudar en q2 (índice 1), no saltarlo a q3.
      expect(find.text('Pregunta 2'), findsOneWidget);
      expect(find.text('Pregunta 3'), findsNothing);
    },
  );

  testWidgets(
    'responde la última pregunta y cierra: al reabrir inicia limpio (sin reinicio atascado)',
    (tester) async {
      // data[5] vacío = ya no quedan preguntas por responder: el progreso se
      // descarta e inicia limpio en la primera pregunta.
      await prefs.setStringList('quiz_progress_resume_key', [
        'st1',
        '3',
        '2',
        'q1,q2,q3',
        DateTime.now().toIso8601String(),
        '',
      ]);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            prefsProvider.overrideWithValue(prefs),
            reduceAnimationsProvider.overrideWithValue(true),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              return MaterialApp(
                locale: const Locale('es'),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: Scaffold(
                  body: QuizSession(
                    challenges: buildChallenges(),
                    stageId: 'st1',
                    lessonId: 'resume_key',
                    lessonTitle: 'Lección',
                    onComplete: (_) {},
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pregunta 1'), findsOneWidget);
      // La clave se limpió para no reutilizar un cursor obsoleto.
      expect(prefs.getStringList('quiz_progress_resume_key'), isNull);
    },
  );

  testWidgets(
    'set de preguntas distinto descarta el progreso obsoleto (limpia la clave)',
    (tester) async {
      // El id guardado (qX) no pertenece al set actual del quiz.
      await prefs.setStringList('quiz_progress_resume_key', [
        'st1',
        '0',
        '0',
        'q1,zzz',
        DateTime.now().toIso8601String(),
        'zzz',
      ]);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            prefsProvider.overrideWithValue(prefs),
            reduceAnimationsProvider.overrideWithValue(true),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              return MaterialApp(
                locale: const Locale('es'),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: Scaffold(
                  body: QuizSession(
                    challenges: buildChallenges(),
                    stageId: 'st1',
                    lessonId: 'resume_key',
                    lessonTitle: 'Lección',
                    onComplete: (_) {},
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Inicia limpio en la primera pregunta y se limpia el progreso obsoleto.
      expect(find.text('Pregunta 1'), findsOneWidget);
      expect(prefs.getStringList('quiz_progress_resume_key'), isNull);
    },
  );
}
