import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/models/sagen_pass.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/sage_emotion_service.dart';
import 'package:sagen/services/streak_service.dart';
import 'package:sagen/ui/screens/dashboard/dashboard_home_screen.dart';
import 'package:sagen/ui/screens/dashboard/profile_screen.dart';
import 'package:sagen/ui/screens/dashboard/ranking_screen.dart';
import 'package:sagen/ui/screens/dashboard/sage_chat_screen.dart';
import 'package:sagen/ui/screens/dashboard/store_screen.dart';
import 'package:sagen/ui/screens/main_layout.dart';

class _NoPrecacheSageEmotionService extends SageEmotionService {
  @override
  Future<void> ensurePrecached(SageEmotion emotion) async {}
}

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this._status);

  final AuthStatus _status;

  @override
  AuthState build() =>
      AuthState(status: _status, displayName: 'Ana', uid: 'user42');
}

class _FakeDashboardNotifier extends DashboardNotifier {
  _FakeDashboardNotifier(this._state);

  final DashboardState _state;

  @override
  DashboardState build() => _state;
}

class _FakeLearningNotifier extends LearningNotifier {
  _FakeLearningNotifier(this._state);

  final LearningState _state;

  @override
  LearningState build() => _state;
}

class _FakeStreakNotifier extends StreakNotifier {
  @override
  StreakState build() => const StreakState(
    status: StreakStatus(
      currentStreak: 3,
      longestStreak: 9,
      streakFreezes: 0,
      isAtRisk: false,
      message: 'ok',
      tier: 'bronze',
    ),
    totalCheckIns: 20,
    perfectWeeks: 2,
    missionCompleted: false,
    weeklyStats: {},
    heatmapData: {},
    monthlyData: {},
    streakHistory: [],
    emotionalMessages: [],
  );
}

class _FakeGemNotifier extends GemNotifier {
  _FakeGemNotifier(this._state);

  final GemState _state;
  final StreamController<int> _rewards = StreamController<int>.broadcast();
  final StreamController<int> _milestones = StreamController<int>.broadcast();
  final StreamController<void> _caps = StreamController<void>.broadcast();

  @override
  GemState build() => _state;

  @override
  Stream<int> get onGemsEarned => _rewards.stream;

  @override
  Stream<int> get onGemMilestone => _milestones.stream;

  @override
  Stream<void> get onCapWarning => _caps.stream;
}

class _FakeAchievementNotifier extends AchievementNotifier {
  @override
  AchievementState build() => const AchievementState(
    isInitialized: true,
    achievements: [],
    unlockedCount: 0,
    totalCount: 0,
    progress: 0,
  );
}

class _FakeShopNotifier extends ShopNotifier {
  @override
  ShopState build() => const ShopState(items: []);
}

class _FakeSagenPassNotifier extends SagenPassNotifier {
  @override
  SagenPass build() => SagenPass(currentLevel: 3, currentSP: 100);
}

class _FakeGamificationNotifier extends GamificationNotifier {
  _FakeGamificationNotifier(this._state);

  final GamificationState _state;

  @override
  GamificationState build() => _state;
}

class _FakeSageAiNotifier extends SageAiNotifier {
  @override
  SageAiChatState build() => const SageAiChatState();
}

LearningState _learning() {
  return const LearningState(
    stages: [],
    totalDonated: 25.5,
    currentLevel: 3,
    totalXpEarned: 850,
    isLoading: false,
  );
}

Widget _wrap(List<Override> overrides, {int initialTab = 0}) {
  return ProviderScope(
    overrides: [
      reduceAnimationsProvider.overrideWithValue(true),
      sageEmotionServiceProvider.overrideWithValue(
        _NoPrecacheSageEmotionService(),
      ),
      authProvider.overrideWith(
        () => _FakeAuthNotifier(AuthStatus.authenticated),
      ),
      dashboardProvider.overrideWith(
        () => _FakeDashboardNotifier(
          const DashboardState(displayName: 'Ana', isLoading: false),
        ),
      ),
      learningProvider.overrideWith(() => _FakeLearningNotifier(_learning())),
      streakProvider.overrideWith(() => _FakeStreakNotifier()),
      gemProvider.overrideWith(
        () => _FakeGemNotifier(
          const GemState(balance: 250, totalEarned: 600, totalSpent: 350),
        ),
      ),
      achievementProvider.overrideWith(() => _FakeAchievementNotifier()),
      shopProvider.overrideWith(() => _FakeShopNotifier()),
      sagenPassProvider.overrideWith(() => _FakeSagenPassNotifier()),
      gamificationProvider.overrideWith(
        () => _FakeGamificationNotifier(const GamificationState()),
      ),
      sageAiProvider.overrideWith(() => _FakeSageAiNotifier()),
      ...overrides,
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      home: MainLayout(initialTab: initialTab),
    ),
  );
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(seconds: 2));
}

Future<void> _tapTab(WidgetTester tester, Finder finder) async {
  await tester.tap(finder, warnIfMissed: false);
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  group('MainLayout', () {
    testWidgets('renderiza nav bar y tab inicial', (tester) async {
      await tester.pumpWidget(_wrap(const []));
      await _settle(tester);

      final ctx = tester.element(find.byType(MainLayout));
      final l = AppLocalizations.of(ctx)!;

      expect(find.byType(DashboardHomeScreen), findsOneWidget);
      expect(find.text(l.navHome), findsOneWidget);
      expect(find.text(l.navChest), findsOneWidget);
      expect(find.text(l.navSage), findsOneWidget);
      expect(find.text(l.navRanking), findsOneWidget);
      expect(find.text(l.navProfile), findsOneWidget);
    });

    testWidgets('modo demo muestra banner offline', (tester) async {
      await tester.pumpWidget(
        _wrap([
          authProvider.overrideWith(() => _FakeAuthNotifier(AuthStatus.demo)),
        ]),
      );
      await _settle(tester);

      final ctx = tester.element(find.byType(MainLayout));
      final l = AppLocalizations.of(ctx)!;
      expect(find.text(l.demoModeOffline), findsOneWidget);
    });

    testWidgets('switch de tab construye todas las pantallas', (tester) async {
      await tester.pumpWidget(_wrap(const []));
      await _settle(tester);

      final ctx = tester.element(find.byType(MainLayout));
      final l = AppLocalizations.of(ctx)!;

      await _tapTab(tester, find.text(l.navChest));
      expect(find.byType(StoreScreen), findsOneWidget);

      await _tapTab(tester, find.text(l.navSage));
      expect(find.byType(SageChatScreen), findsOneWidget);

      await _tapTab(tester, find.text(l.navRanking));
      expect(find.byType(RankingScreen), findsOneWidget);

      await _tapTab(tester, find.text(l.navProfile));
      expect(find.byType(ProfileScreen), findsOneWidget);

      await tester.tap(find.text(l.navHome), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(DashboardHomeScreen), findsOneWidget);
    });

    testWidgets('chest badge visible cuando hay chest sin reclamar', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap([
          gamificationProvider.overrideWith(
            () => _FakeGamificationNotifier(
              const GamificationState(hasUnclaimedChest: true),
            ),
          ),
        ]),
      );
      await _settle(tester);

      final badge = tester.widget<Badge>(
        find.ancestor(
          of: find.byIcon(Icons.card_giftcard_rounded),
          matching: find.byType(Badge),
        ),
      );
      expect(badge.isLabelVisible, isTrue);
    });

    testWidgets('initialTab arranca en perfil', (tester) async {
      await tester.pumpWidget(_wrap(const [], initialTab: 4));
      await _settle(tester);

      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.byType(DashboardHomeScreen), findsNothing);
    });
  });
}
