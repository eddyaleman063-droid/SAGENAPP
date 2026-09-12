import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/streak_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagen/ui/widgets/common/sync_coordinator.dart';

// ── Recording notifiers ──────────────────────────────────────────────────
class _FlipperAuth extends AuthNotifier {
  @override
  AuthState build() => const AuthState(status: AuthStatus.unauthenticated);

  void flip() => state = const AuthState(
    uid: 'test-uid',
    status: AuthStatus.authenticated,
  );

  void logout() => state = const AuthState(status: AuthStatus.unauthenticated);
}

class _RecStreak extends StreakNotifier {
  int reloads = 0;

  @override
  StreakState build() => const StreakState(
    status: StreakStatus(
      currentStreak: 0,
      longestStreak: 0,
      streakFreezes: 0,
      isAtRisk: false,
      message: '',
      tier: '',
    ),
    totalCheckIns: 0,
    perfectWeeks: 0,
    missionCompleted: false,
    weeklyStats: {},
    heatmapData: {},
    monthlyData: {},
    streakHistory: [],
    emotionalMessages: [],
  );

  @override
  void reload() {
    reloads++;
  }
}

class _RecLearning extends LearningNotifier {
  int reloads = 0;

  @override
  LearningState build() => const LearningState();

  @override
  Future<void> reload() async {
    reloads++;
  }
}

class _RecProtection extends ProtectionNotifier {
  int reloads = 0;

  @override
  ProtectionState build() => const ProtectionState();

  @override
  void reload() {
    reloads++;
  }
}

class _RecMission extends MissionNotifier {
  int reloads = 0;

  @override
  MissionState build() => MissionState();

  @override
  void reload() {
    reloads++;
  }
}

class _RecReview extends ReviewNotifier {
  int reloads = 0;
  bool shouldThrow;

  _RecReview({this.shouldThrow = false});

  @override
  ReviewState build() => const ReviewState();

  @override
  void reload() {
    if (shouldThrow) throw Exception('reload boom');
    reloads++;
  }
}

late SharedPreferences _prefs;

Widget _wrap({required SharedPreferences prefs, required bool reviewThrows}) {
  return ProviderScope(
    overrides: [
      prefsProvider.overrideWithValue(prefs),
      authProvider.overrideWith(_FlipperAuth.new),
      streakProvider.overrideWith(_RecStreak.new),
      learningProvider.overrideWith(_RecLearning.new),
      protectionProvider.overrideWith(_RecProtection.new),
      missionProvider.overrideWith(_RecMission.new),
      reviewProvider.overrideWith(() => _RecReview(shouldThrow: reviewThrows)),
    ],
    child: const MaterialApp(
      locale: Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SyncCoordinator(child: Text('app'))),
    ),
  );
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    _prefs = await SharedPreferences.getInstance();
  });

  ProviderContainer containerOf(WidgetTester tester) {
    return ProviderScope.containerOf(
      tester.element(find.byType(SyncCoordinator)),
    );
  }

  testWidgets('al autenticar recarga los 5 providers', (tester) async {
    await tester.pumpWidget(_wrap(prefs: _prefs, reviewThrows: false));
    await tester.pump(const Duration(milliseconds: 200));

    final auth =
        containerOf(tester).read(authProvider.notifier) as _FlipperAuth;
    auth.flip();
    await tester.pump();
    await tester.pump();

    expect(
      (containerOf(tester).read(streakProvider.notifier) as _RecStreak).reloads,
      1,
    );
    expect(
      (containerOf(tester).read(learningProvider.notifier) as _RecLearning)
          .reloads,
      1,
    );
    expect(
      (containerOf(tester).read(protectionProvider.notifier) as _RecProtection)
          .reloads,
      1,
    );
    expect(
      (containerOf(tester).read(missionProvider.notifier) as _RecMission)
          .reloads,
      1,
    );
    expect(
      (containerOf(tester).read(reviewProvider.notifier) as _RecReview).reloads,
      1,
    );
  });

  testWidgets('un error en reload muestra un snackbar de error', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(prefs: _prefs, reviewThrows: true));
    await tester.pump(const Duration(milliseconds: 200));

    final auth =
        containerOf(tester).read(authProvider.notifier) as _FlipperAuth;
    auth.flip();
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final l = AppLocalizations.of(
      tester.element(find.byType(SyncCoordinator)),
    )!;
    expect(find.text(l.errorGeneric), findsOneWidget);
  });

  testWidgets('al des-autenticar NO se recargan providers', (tester) async {
    await tester.pumpWidget(_wrap(prefs: _prefs, reviewThrows: false));
    await tester.pump(const Duration(milliseconds: 200));

    final auth =
        containerOf(tester).read(authProvider.notifier) as _FlipperAuth;
    auth.flip();
    await tester.pump();
    await tester.pump();
    expect(
      (containerOf(tester).read(streakProvider.notifier) as _RecStreak).reloads,
      1,
    );

    auth.logout();
    await tester.pump();
    expect(
      (containerOf(tester).read(streakProvider.notifier) as _RecStreak).reloads,
      1,
    );
    expect(
      (containerOf(tester).read(reviewProvider.notifier) as _RecReview).reloads,
      1,
    );
  });
}
