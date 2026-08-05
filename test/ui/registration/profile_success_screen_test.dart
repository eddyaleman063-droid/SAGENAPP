import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/sage_emotion_service.dart';
import 'package:sagen/ui/screens/registration/profile_success_screen.dart';

class _NoOpSageEmotionService extends SageEmotionService {
  @override
  Future<void> ensurePrecached(SageEmotion emotion) async {}
  @override
  bool canIdleBreathe(SageEmotion emotion) => false;
  @override
  bool shouldAnimateEmotionChange(SageEmotion from, SageEmotion to) => false;
  @override
  bool isSignificantMoodShift(SageEmotion from, SageEmotion to) => false;
}

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget createTestApp() {
    return ProviderScope(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        sageEmotionServiceProvider.overrideWithValue(_NoOpSageEmotionService()),
      ],
      child: MaterialApp.router(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: GoRouter(
          initialLocation: '/profile-success',
          routes: [
            GoRoute(
              name: 'profile-success',
              path: '/profile-success',
              builder: (context, state) => const ProfileSuccessScreen(),
            ),
            GoRoute(
              name: 'main',
              path: '/main',
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('main'))),
            ),
          ],
        ),
      ),
    );
  }

  group('ProfileSuccessScreen', () {
    testWidgets('renders success check icon', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1600));
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('renders profile created badge', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1600));
      expect(find.text('PERFIL CREADO'), findsOneWidget);
    });

    testWidgets('renders welcome message', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1600));
      expect(find.text('¡Bienvenido a SAGEN!'), findsOneWidget);
    });

    testWidgets('renders ready for lesson text', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1600));
      expect(find.text('Prepara para tu primera lección'), findsOneWidget);
    });

    testWidgets('renders continue button', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1600));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('continue button navigates to main', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.text('main'), findsOneWidget);
    });
  });
}
