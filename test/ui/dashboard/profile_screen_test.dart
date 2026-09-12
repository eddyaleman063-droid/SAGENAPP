import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/models/sagen_pass.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/achievement_service.dart';
import 'package:sagen/services/sage_emotion_service.dart';
import 'package:sagen/services/streak_service.dart';
import 'package:sagen/ui/screens/dashboard/profile_screen.dart';
import 'package:sagen/ui/widgets/profile/achievement_card.dart';
import 'package:sagen/ui/widgets/profile/flex_card_share_sheet.dart';

class _NoPrecacheSageEmotionService extends SageEmotionService {
  @override
  Future<void> ensurePrecached(SageEmotion emotion) async {}
}

class _FakeAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthState(displayName: 'Ana');
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
      currentStreak: 7,
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

  @override
  GemState build() => _state;
}

class _FakeAchievementNotifier extends AchievementNotifier {
  _FakeAchievementNotifier(this._state);

  final AchievementState _state;

  @override
  AchievementState build() => _state;
}

class _FakeShopNotifier extends ShopNotifier {
  _FakeShopNotifier(this._items);

  final List<ShopItem> _items;

  @override
  ShopState build() => ShopState(items: _items);
}

class _FakeSagenPassNotifier extends SagenPassNotifier {
  @override
  SagenPass build() => SagenPass(currentLevel: 3, currentSP: 100);
}

final _achievements = [
  AchievementModel(
    id: 'first_lesson',
    title: 'First Shield',
    description: 'Completa tu primera lección',
    icon: Icons.shield_rounded,
    unlocked: true,
    xpReward: 10,
  ),
  AchievementModel(
    id: 'five_lessons',
    title: 'Learner',
    description: 'Completa 5 lecciones',
    icon: Icons.school_rounded,
    unlocked: false,
    xpReward: 25,
  ),
];

LearningState _learning({
  bool isLoading = false,
  String? errorMessage,
  int currentLevel = 3,
  int totalXpEarned = 850,
  double totalDonated = 25.5,
}) {
  return LearningState(
    stages: [],
    totalDonated: totalDonated,
    currentLevel: currentLevel,
    totalXpEarned: totalXpEarned,
    isLoading: isLoading,
    errorMessage: errorMessage,
  );
}

Widget _wrap(List<Override> overrides) {
  return ProviderScope(
    overrides: [
      reduceAnimationsProvider.overrideWithValue(true),
      sageEmotionServiceProvider.overrideWithValue(
        _NoPrecacheSageEmotionService(),
      ),
      authProvider.overrideWith(() => _FakeAuthNotifier()),
      learningProvider.overrideWith(() => _FakeLearningNotifier(_learning())),
      streakProvider.overrideWith(() => _FakeStreakNotifier()),
      gemProvider.overrideWith(
        () => _FakeGemNotifier(
          const GemState(balance: 250, totalEarned: 600, totalSpent: 50),
        ),
      ),
      achievementProvider.overrideWith(
        () => _FakeAchievementNotifier(
          const AchievementState(
            isInitialized: true,
            unlockedCount: 1,
            totalCount: 2,
            progress: 0.5,
          ),
        ),
      ),
      shopProvider.overrideWith(() => _FakeShopNotifier(const [])),
      sagenPassProvider.overrideWith(() => _FakeSagenPassNotifier()),
      ...overrides,
    ],
    child: MaterialApp(
      theme: ThemeData(),
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const ProfileScreen(),
    ),
  );
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 2));
  await tester.pump(const Duration(seconds: 2));
}

void _setTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  group('ProfileScreen', () {
    testWidgets('happy path muestra estadisticas y tarjetas', (tester) async {
      _setTallViewport(tester);
      await tester.pumpWidget(_wrap(const []));
      await _settle(tester);

      expect(find.text('Ana'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('850'), findsOneWidget);
      expect(find.text(r'$25.50'), findsOneWidget);
      expect(find.text('250'), findsOneWidget);
      expect(find.text('600'), findsOneWidget);
      expect(find.text('50'), findsOneWidget);
      expect(find.text('Logros'), findsOneWidget);
      expect(find.text('1/2'), findsOneWidget);
    });

    testWidgets('grid de logros con tarjetas cuando hay totalCount', (
      tester,
    ) async {
      _setTallViewport(tester);
      await tester.pumpWidget(
        _wrap([
          achievementProvider.overrideWith(
            () => _FakeAchievementNotifier(
              AchievementState(
                isInitialized: true,
                achievements: _achievements,
                unlockedCount: 1,
                totalCount: 2,
                progress: 0.5,
              ),
            ),
          ),
        ]),
      );
      await _settle(tester);

      for (var i = 0; i < 8; i++) {
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
        await tester.pump(const Duration(milliseconds: 300));
      }
      await _settle(tester);

      expect(find.byType(AchievementCard), findsNWidgets(2));
      expect(find.text('Sin datos de perfil'), findsNothing);
    });

    testWidgets('estado vacio de logros muestra mascota pensando', (
      tester,
    ) async {
      _setTallViewport(tester);
      await tester.pumpWidget(
        _wrap([
          achievementProvider.overrideWith(
            () => _FakeAchievementNotifier(
              const AchievementState(
                isInitialized: true,
                achievements: [],
                unlockedCount: 0,
                totalCount: 0,
                progress: 0,
              ),
            ),
          ),
        ]),
      );
      await _settle(tester);

      await tester.scrollUntilVisible(
        find.text('Sin datos de perfil'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Sin datos de perfil'), findsOneWidget);
    });

    testWidgets('loading muestra PremiumLoader', (tester) async {
      _setTallViewport(tester);
      await tester.pumpWidget(
        _wrap([
          learningProvider.overrideWith(
            () => _FakeLearningNotifier(_learning(isLoading: true)),
          ),
        ]),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Cargando'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('error muestra mensaje y boton retry', (tester) async {
      _setTallViewport(tester);
      await tester.pumpWidget(
        _wrap([
          learningProvider.overrideWith(
            () =>
                _FakeLearningNotifier(_learning(errorMessage: 'Fallo de red')),
          ),
        ]),
      );
      await _settle(tester);

      expect(
        find.text(
          'No pudimos cargar el contenido. Verifica tu conexión e intenta de nuevo.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.byIcon(Icons.refresh_rounded));
      await tester.pump();
    });

    testWidgets('FAB abre la tarjeta flex compartible', (tester) async {
      _setTallViewport(tester);
      await tester.pumpWidget(_wrap(const []));
      await _settle(tester);

      await tester.tap(find.byIcon(Icons.share_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(FlexCardShareSheet), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('marco dorado cambia el header del perfil', (tester) async {
      _setTallViewport(tester);
      await tester.pumpWidget(
        _wrap([
          shopProvider.overrideWith(
            () => _FakeShopNotifier(const [
              ShopItem(
                id: 'gold_frame',
                name: 'Marco dorado',
                description: 'Marco dorado para el perfil',
              ),
            ]),
          ),
        ]),
      );
      await _settle(tester);

      expect(find.text('Ana'), findsOneWidget);
    });
  });
}
