// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/models/learning/stage.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/ui/widgets/home/learning_track_tile.dart';

late SharedPreferences prefs;

Stage makeStage({
  String id = 's1',
  String title = 'Test Stage',
  String subtitle = 'Subtitle',
}) {
  return Stage(
    id: id,
    title: title,
    subtitle: subtitle,
    accent: const Color(0xFFFF6F00),
    icon: Icons.shield_rounded,
  );
}

Widget buildTestApp({required Widget child}) {
  return ProviderScope(
    overrides: [prefsProvider.overrideWithValue(prefs)],
    child: MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  testWidgets('renders track name and subtitle', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        child: LearningTrackTile(
          stage: makeStage(
            title: 'Phishing Basics',
            subtitle: 'Learn about phishing',
          ),
          status: StageStatus.inProgress,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Phishing Basics'), findsOneWidget);
    expect(find.text('Learn about phishing'), findsOneWidget);
  });

  testWidgets('renders progress indicator', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        child: LearningTrackTile(
          stage: makeStage(),
          status: StageStatus.inProgress,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('renders lock icon for locked stage', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        child: LearningTrackTile(
          stage: makeStage(title: 'Locked Stage'),
          status: StageStatus.locked,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
  });

  testWidgets('renders check icon for completed stage', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        child: LearningTrackTile(
          stage: makeStage(),
          status: StageStatus.completed,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });

  testWidgets('handles tap on non-locked stage', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      buildTestApp(
        child: LearningTrackTile(
          stage: makeStage(),
          status: StageStatus.inProgress,
          onTap: () => tapped = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });

  testWidgets('does not call onTap when locked', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      buildTestApp(
        child: LearningTrackTile(
          stage: makeStage(),
          status: StageStatus.locked,
          onTap: () => tapped = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();
    expect(tapped, isFalse);
  });

  testWidgets('renders chevron for non-completed stages', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        child: LearningTrackTile(
          stage: makeStage(),
          status: StageStatus.inProgress,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
  });
}
