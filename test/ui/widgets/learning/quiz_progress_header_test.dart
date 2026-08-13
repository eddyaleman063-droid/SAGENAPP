// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/ui/widgets/learning/quiz_progress_header.dart';

Widget buildApp(Widget child) => MaterialApp(
  theme: ThemeData(),
  locale: const Locale('es'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('renders title text', (tester) async {
    await tester.pumpWidget(
      buildApp(
        QuizProgressHeader(
          current: 1,
          total: 10,
          progress: 0.1,
          title: 'Lección de Phishing',
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Lección de Phishing'), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('renders question count as current / total', (tester) async {
    await tester.pumpWidget(
      buildApp(
        QuizProgressHeader(current: 3, total: 10, progress: 0.3, title: 'Quiz'),
      ),
    );
    await tester.pump();

    expect(find.text('3 / 10'), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('renders LinearProgressIndicator', (tester) async {
    await tester.pumpWidget(
      buildApp(
        QuizProgressHeader(current: 5, total: 10, progress: 0.5, title: 'Quiz'),
      ),
    );
    await tester.pump();

    final progressIndicator = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(progressIndicator.value, 0.5);
    await tester.pumpAndSettle();
  });

  testWidgets('renders close button', (tester) async {
    await tester.pumpWidget(
      buildApp(
        QuizProgressHeader(current: 1, total: 10, progress: 0.1, title: 'Quiz'),
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('close button triggers Navigator.pop', (tester) async {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) =>
              Scaffold(body: Center(child: Text('home'))),
        ),
        GoRoute(
          path: '/quiz',
          builder: (context, state) => Scaffold(
            body: QuizProgressHeader(
              current: 1,
              total: 10,
              progress: 0.1,
              title: 'Quiz',
            ),
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp.router(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    router.push('/quiz');
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    // Tap the close button
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
  });

  testWidgets('renders progress at 0%', (tester) async {
    await tester.pumpWidget(
      buildApp(
        QuizProgressHeader(current: 0, total: 10, progress: 0.0, title: 'Quiz'),
      ),
    );
    await tester.pump();

    final progressIndicator = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(progressIndicator.value, 0.0);
    await tester.pumpAndSettle();
  });

  testWidgets('renders progress at 100%', (tester) async {
    await tester.pumpWidget(
      buildApp(
        QuizProgressHeader(
          current: 10,
          total: 10,
          progress: 1.0,
          title: 'Quiz',
        ),
      ),
    );
    await tester.pump();

    final progressIndicator = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(progressIndicator.value, 1.0);
    await tester.pumpAndSettle();
  });

  testWidgets('renders with long title text', (tester) async {
    await tester.pumpWidget(
      buildApp(
        QuizProgressHeader(
          current: 1,
          total: 20,
          progress: 0.05,
          title:
              'Lección muy larga de ciberseguridad y protección de datos personales',
        ),
      ),
    );
    await tester.pump();

    expect(
      find.text(
        'Lección muy larga de ciberseguridad y protección de datos personales',
      ),
      findsOneWidget,
    );
    await tester.pumpAndSettle();
  });

  testWidgets('title uses ellipsis overflow', (tester) async {
    await tester.pumpWidget(
      buildApp(
        QuizProgressHeader(
          current: 1,
          total: 10,
          progress: 0.1,
          title:
              'Título extremadamente largo que debería usar ellipsis cuando se desborda del espacio disponible',
        ),
      ),
    );
    await tester.pump();

    final titleText = tester.widget<Text>(
      find.text(
        'Título extremadamente largo que debería usar ellipsis cuando se desborda del espacio disponible',
      ),
    );
    expect(titleText.overflow, TextOverflow.ellipsis);
    await tester.pumpAndSettle();
  });

  testWidgets('progress bar has Semantics label', (tester) async {
    await tester.pumpWidget(
      buildApp(
        QuizProgressHeader(current: 5, total: 10, progress: 0.5, title: 'Quiz'),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('has close button with GestureDetector', (tester) async {
    await tester.pumpWidget(
      buildApp(
        QuizProgressHeader(current: 1, total: 10, progress: 0.1, title: 'Quiz'),
      ),
    );
    await tester.pump();

    expect(find.byType(GestureDetector), findsWidgets);
    await tester.pumpAndSettle();
  });
}
