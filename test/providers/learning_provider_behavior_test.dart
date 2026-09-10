import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sagen/models/chest_type.dart';
import 'package:sagen/models/learning/lesson.dart';
import 'package:sagen/models/learning/stage.dart';
import 'package:sagen/providers/learning_stages.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/repositories/learning_repository.dart';
import 'package:sagen/services/analytics_service.dart';
import 'package:sagen/services/chest_event_bus.dart';
import 'package:sagen/services/economic_functions_service.dart';
import 'package:sagen/services/emotion_event_bus.dart';
import 'package:sagen/services/experience_service.dart';
import 'package:sagen/services/learning_reward_service.dart';
import 'package:sagen/services/notification_service.dart';
import 'package:sagen/services/offline_queue_service.dart';
import 'package:sagen/services/streak_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Mocks de servicios ─────────────────────────────────────────────
class _MockQueue extends Mock implements OfflineQueueService {}

class _MockEconomic extends Mock implements EconomicFunctionsService {}

class _MockRewards extends Mock implements LearningRewardService {}

class _MockAnalytics extends Mock implements AnalyticsService {}

class _MockEventBus extends Mock implements EmotionEventBus {}

class _MockExperience extends Mock implements ExperienceService {}

class _MockNotifications extends Mock implements NotificationService {}

// ── Fake repo de aprendizaje ───────────────────────────────────────
class _FakeRepo implements LearningRepository {
  List<Stage> seeded = [];
  List<Stage> fetched = [];
  bool failLoad = false;
  bool failFetch = false;
  int failSaveAllCalls = 0;
  bool failSaveAllRollback = false;

  final List<Stage> _stages = [];
  double _totalDonated = 0;
  int _xp = 0;
  int _currentLevel = 1;
  int _lessonsCompleted = 0;
  final List<String> _achievements = [];
  int _totalXpEarned = 0;
  int _sageTalks = 0;
  bool _isSupporter = false;

  final List<Map<String, dynamic>> savedSnapshots = [];

  @override
  List<Stage> get stages => List.unmodifiable(_stages);

  @override
  double get totalDonated => _totalDonated;

  @override
  int get xp => _xp;

  @override
  int get currentLevel => _currentLevel;

  @override
  int get lessonsCompleted => _lessonsCompleted;

  @override
  List<String> get achievements => List.unmodifiable(_achievements);

  @override
  int get totalXpEarned => _totalXpEarned;

  @override
  int get sageTalks => _sageTalks;

  @override
  bool get isSupporter => _isSupporter;

  @override
  bool get needsServerReconciliation => false;

  @override
  void markReconciled() {}

  @override
  Future<void> load() async {
    if (failLoad) throw Exception('load boom');
    _stages
      ..clear()
      ..addAll(seeded);
  }

  @override
  Future<List<Stage>> fetchStages() async {
    if (failFetch) throw Exception('fetch boom');
    return List.of(fetched);
  }

  @override
  void saveStages(List<Stage> stages) {
    _stages
      ..clear()
      ..addAll(stages);
  }

  @override
  void saveTotalDonated(double amount) => _totalDonated = amount;

  @override
  void saveXp(int amount) => _xp = amount;

  @override
  void saveLevel(int level) => _currentLevel = level;

  @override
  void saveLessonsCompleted(int count) => _lessonsCompleted = count;

  @override
  void saveAchievements(List<String> achievements) {
    _achievements
      ..clear()
      ..addAll(achievements);
  }

  @override
  void saveTotalXp(int amount) => _totalXpEarned = amount;

  @override
  void saveSageTalks(int count) => _sageTalks = count;

  @override
  void saveIsSupporter(bool value) => _isSupporter = value;

  @override
  void saveAll({
    required List<Stage> stages,
    required double totalDonated,
    required int xp,
    required int level,
    required int lessonsCompleted,
    required List<String> achievements,
    required int totalXp,
    required int sageTalks,
    required bool isSupporter,
  }) {
    if (failSaveAllCalls > 0) {
      failSaveAllCalls--;
      throw StateError('saveAll boom');
    }
    savedSnapshots.add({
      'stages': stages,
      'totalDonated': totalDonated,
      'xp': xp,
      'level': level,
      'lessonsCompleted': lessonsCompleted,
      'achievements': achievements,
      'totalXp': totalXp,
      'sageTalks': sageTalks,
      'isSupporter': isSupporter,
    });
    _stages
      ..clear()
      ..addAll(stages);
    _totalDonated = totalDonated;
    _xp = xp;
    _currentLevel = level;
    _lessonsCompleted = lessonsCompleted;
    _achievements
      ..clear()
      ..addAll(achievements);
    _totalXpEarned = totalXp;
    _sageTalks = sageTalks;
    _isSupporter = isSupporter;
  }

  @override
  void saveIntegrity() {}
}

// ── Fakes de notifiers de dependencias ─────────────────────────────
class _FakeAuth extends AuthNotifier {
  @override
  AuthState build() => const AuthState(
    status: AuthStatus.authenticated,
    uid: 'u1',
    email: 'x@y.dev',
  );

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) async => 'token-u1';
}

class _FakeStreak extends StreakNotifier {
  _FakeStreak(this.streak);
  final int streak;

  @override
  StreakState build() => StreakState(
    status: StreakStatus(
      currentStreak: streak,
      longestStreak: streak,
      streakFreezes: 0,
      isAtRisk: false,
      message: '',
      tier: '',
    ),
    totalCheckIns: streak,
    perfectWeeks: 0,
    missionCompleted: false,
    weeklyStats: const {},
    heatmapData: const {},
    monthlyData: const {},
    streakHistory: const [],
    emotionalMessages: const [],
  );
}

class _FakeShop extends ShopNotifier {
  @override
  ShopState build() => const ShopState();

  @override
  void activateXpBoost() => state = state.copyWith(xpBoostActive: true);

  @override
  void deactivateXpBoost() => state = state.copyWith(xpBoostActive: false);

  @override
  void syncXpBoostFromServer(int available) =>
      state = state.copyWith(xpBoostActive: available > 0);
}

class _FakeGem extends GemNotifier {
  final List<String> calls = [];
  int balance = 0;
  bool firstLessonAvailable = true;

  @override
  GemState build() => GemState(balance: balance, totalEarned: balance);

  @override
  bool get canAwardFirstLessonOfDay => firstLessonAvailable;

  @override
  void addGems(int amount, {String? reason}) {
    balance += amount;
    calls.add('addGems:$amount:$reason');
  }

  @override
  void syncBalance(int serverBalance) {
    balance = serverBalance;
    calls.add('syncBalance:$serverBalance');
  }

  @override
  Future<void> syncBalanceFromServer() async {}
}

class _FakeMemory extends LearningMemoryNotifier {
  final List<String> records = [];

  @override
  LearningMemoryState build() => const LearningMemoryState();

  @override
  void recordLessonResult({required bool passed, required String topic}) {
    records.add('$topic:$passed');
  }
}

class _FakeAchievements extends AchievementNotifier {
  final List<String> unlocked = [];

  @override
  AchievementState build() => const AchievementState();

  @override
  bool unlockAchievement(String id) {
    if (!unlocked.contains(id)) unlocked.add(id);
    return true;
  }
}

class _FakeItems extends ItemNotifier {
  @override
  ItemState build() => const ItemState();

  @override
  bool isLuckBoostActive() => false;
}

// ── Helpers ────────────────────────────────────────────────────────
Lesson _lesson(String id, {bool completed = false}) => Lesson(
  id: id,
  title: 'Lesson $id',
  subtitle: 'Sub $id',
  challenges: const [],
  completed: completed,
);

Stage _stage({
  required String id,
  List<Lesson> lessons = const [],
  bool unlocked = false,
}) => Stage(
  id: id,
  title: 'Stage $id',
  subtitle: 'Sub $id',
  accent: Colors.orange,
  icon: Icons.school_rounded,
  lessons: lessons,
  unlocked: unlocked,
);

final _stagesJson = jsonEncode([
  {
    'id': 's1',
    'title': 'T1',
    'subtitle': 'S1',
    'accent': '#FF6F00',
    'sessions': [
      {
        'id': 'ses1',
        'title': 'Se1',
        'subtitle': 'Ses1',
        'lessons': [
          {
            'id': 's1_l1',
            'title': 'L1',
            'subtitle': 'L1',
            'xpReward': 15,
            'estimatedMinutes': 3,
          },
          {
            'id': 's1_l2',
            'title': 'L2',
            'subtitle': 'L2',
            'xpReward': 20,
            'estimatedMinutes': 4,
          },
        ],
      },
    ],
  },
]);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeRepo repo;
  late _MockQueue queue;
  late _MockEconomic economic;
  late _MockRewards rewards;
  late _MockAnalytics analytics;
  late _MockEventBus eventBus;
  late _MockExperience experience;
  late _MockNotifications notifications;
  late ProviderContainer container;

  Future<void> settle() async {
    for (var i = 0; i < 15; i++) {
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  void buildContainer(SharedPreferences prefs) {
    container = ProviderContainer(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        learningRepositoryProvider.overrideWith((ref) => repo),
        authProvider.overrideWith(() => _FakeAuth()),
        streakProvider.overrideWith(() => _FakeStreak(0)),
        shopProvider.overrideWith(() => _FakeShop()),
        gemProvider.overrideWith(() => _FakeGem()),
        learningMemoryProvider.overrideWith(() => _FakeMemory()),
        achievementProvider.overrideWith(() => _FakeAchievements()),
        itemProvider.overrideWith(() => _FakeItems()),
        analyticsServiceProvider.overrideWith((ref) => analytics),
        emotionEventBusProvider.overrideWith((ref) => eventBus),
        experienceServiceProvider.overrideWith((ref) => experience),
        notificationServiceProvider.overrideWith((ref) => notifications),
        offlineQueueServiceProvider.overrideWith((ref) => queue),
        economicFunctionsServiceProvider.overrideWith((ref) => economic),
        learningRewardServiceProvider.overrideWith((ref) => rewards),
      ],
    );
  }

  setUpAll(() {
    registerFallbackValue(
      const ChestRewardData(type: ChestType.silver, source: 'test'),
    );
  });

  setUp(() async {
    resetStagesForTest();
    SharedPreferences.setMockInitialValues({});
    // El off-lineQueue real haría SQLite; aquí lo dejamos aislado.
    repo = _FakeRepo();
    queue = _MockQueue();
    economic = _MockEconomic();
    rewards = _MockRewards();
    analytics = _MockAnalytics();
    eventBus = _MockEventBus();
    experience = _MockExperience();
    notifications = _MockNotifications();

    when(() => queue.init()).thenAnswer((_) async {});
    when(
      () => queue.queueLessonCompletion(
        lessonId: any(named: 'lessonId'),
        stageId: any(named: 'stageId'),
        gemsEarned: any(named: 'gemsEarned'),
        xpEarned: any(named: 'xpEarned'),
        correctAnswers: any(named: 'correctAnswers'),
        totalQuestions: any(named: 'totalQuestions'),
        completedAt: any(named: 'completedAt'),
        feedback: any(named: 'feedback'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => queue.queueAddXp(
        reason: any(named: 'reason'),
        lessonId: any(named: 'lessonId'),
        achievementId: any(named: 'achievementId'),
        idempotencyKey: any(named: 'idempotencyKey'),
      ),
    ).thenAnswer((_) async {});
    when(() => economic.createIdempotencyKey(any())).thenReturn('idem-key');
    when(
      () => economic.addXp(
        reason: any(named: 'reason'),
        lessonId: any(named: 'lessonId'),
        idempotencyKey: any(named: 'idempotencyKey'),
        achievementId: any(named: 'achievementId'),
      ),
    ).thenAnswer((_) async => null);
    when(
      () => economic.recordDonation(
        amount: any(named: 'amount'),
        method: any(named: 'method'),
      ),
    ).thenAnswer((_) async => null);
    when(
      () => rewards.rollChest(
        lessonsCompleted: any(named: 'lessonsCompleted'),
        totalDonated: any(named: 'totalDonated'),
        xp: any(named: 'xp'),
        luckBoostActive: any(named: 'luckBoostActive'),
        contextId: any(named: 'contextId'),
      ),
    ).thenAnswer((_) async => null);
    when(() => experience.notificationsEnabled).thenReturn(false);

    buildContainer(await SharedPreferences.getInstance());
  });

  tearDown(() => container.dispose());

  // ── init / carga de stages ───────────────────────────────────────
  group('LearningNotifier._init', () {
    test(
      'carga stages cacheados, desbloquea la primera y encadena unlocks',
      () async {
        final l1 = _lesson('s1_l1', completed: true);
        final l2 = _lesson('s2_l1');
        repo.seeded = [
          _stage(id: 's1', lessons: [l1], unlocked: false),
          _stage(id: 's2', lessons: [l2], unlocked: false),
        ];

        container.read(learningProvider.notifier);
        await settle();

        final state = container.read(learningProvider);
        expect(state.isLoading, isFalse);
        expect(state.errorMessage, isNull);
        expect(state.stages, hasLength(2));
        expect(state.stages[0].unlocked, isTrue);
        expect(state.stages[1].unlocked, isTrue);
        verify(() => queue.init()).called(1);
      },
    );

    test('usa stages fresh del repositorio cuando no hay cache', () async {
      final l1 = _lesson('s1_l1');
      repo.fetched = [
        _stage(id: 's1', lessons: [l1]),
      ];

      container.read(learningProvider.notifier);
      await settle();

      final state = container.read(learningProvider);
      expect(state.stages, hasLength(1));
      expect(state.stages[0].unlocked, isTrue);
      expect(state.stages[0].id, 's1');
      expect(state.isLoading, isFalse);
    });

    test('carga stages desde assets cuando no hay cache ni fetch', () async {
      loadStagesOverride = () async => _stagesJson;

      container.read(learningProvider.notifier);
      await settle();

      final state = container.read(learningProvider);
      expect(state.stages, hasLength(1));
      expect(state.stages[0].id, 's1');
      expect(state.stages[0].unlocked, isTrue);
      expect(state.stages[0].lessons, hasLength(2));
      expect(state.isLoading, isFalse);
    });

    test('marca error si no hay contenido disponible', () async {
      loadStagesOverride = () async => 'not json at all';

      container.read(learningProvider.notifier);
      await settle();

      final state = container.read(learningProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, contains('Could not load content'));
    });

    test('marca error si repo.load falla', () async {
      repo.failLoad = true;

      container.read(learningProvider.notifier);
      await settle();

      final state = container.read(learningProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, contains('Could not load your progress'));
    });
  });

  // ── XP computation ───────────────────────────────────────────────
  group('LearningNotifier.xp', () {
    test('xpForLessonId usa base 15/20 sin multiplicador', () async {
      final notifier = container.read(learningProvider.notifier);
      await settle();
      expect(notifier.xpForLessonId('ac_s1_ses1_l1'), 15);
      expect(notifier.xpForLessonId('ac_s1_ses1_l6'), 20);
    });

    test('xpForLessonId escala por multiplicador de racha', () async {
      container.dispose();
      container = ProviderContainer(
        overrides: [
          prefsProvider.overrideWithValue(
            await SharedPreferences.getInstance(),
          ),
          learningRepositoryProvider.overrideWith((ref) => repo),
          authProvider.overrideWith(() => _FakeAuth()),
          streakProvider.overrideWith(() => _FakeStreak(31)),
          shopProvider.overrideWith(() => _FakeShop()),
          gemProvider.overrideWith(() => _FakeGem()),
          learningMemoryProvider.overrideWith(() => _FakeMemory()),
          achievementProvider.overrideWith(() => _FakeAchievements()),
          itemProvider.overrideWith(() => _FakeItems()),
          analyticsServiceProvider.overrideWith((ref) => analytics),
          emotionEventBusProvider.overrideWith((ref) => eventBus),
          experienceServiceProvider.overrideWith((ref) => experience),
          notificationServiceProvider.overrideWith((ref) => notifications),
          offlineQueueServiceProvider.overrideWith((ref) => queue),
          economicFunctionsServiceProvider.overrideWith((ref) => economic),
          learningRewardServiceProvider.overrideWith((ref) => rewards),
        ],
      );
      final notifier = container.read(learningProvider.notifier);
      await settle();
      // streak 31 → mult 1.3 → 15*1.3=19.5 → round 20; 20*1.3=26
      expect(notifier.xpForLessonId('ac_s1_ses1_l1'), 20);
      expect(notifier.xpForLessonId('ac_s1_ses1_l6'), 26);
    });

    test('xpForLessonId duplica con boost de XP activo', () async {
      final notifier = container.read(learningProvider.notifier);
      final shop = container.read(shopProvider.notifier);
      await settle();
      shop.activateXpBoost();
      expect(notifier.xpForLessonId('ac_s1_ses1_l1'), 30);
      expect(notifier.xpForLessonId('ac_s1_ses1_l6'), 40);
    });
  });

  // ── completeLesson ───────────────────────────────────────────────
  group('LearningNotifier.completeLesson', () {
    Stage oneStage() {
      final l1 = _lesson('s1_l1');
      return _stage(id: 's1', lessons: [l1], unlocked: true);
    }

    test('completa la leccion, acredita XP y registra efectos', () async {
      repo.fetched = [oneStage()];
      final notifier = container.read(learningProvider.notifier);
      await settle();

      await notifier.completeLesson(
        's1',
        's1_l1',
        correctAnswers: 2,
        totalQuestions: 3,
      );

      final state = container.read(learningProvider);
      expect(state.lessonsCompleted, 1);
      expect(state.xp, 15);
      expect(state.totalXpEarned, 15);
      expect(state.stages.single.lessons.single.completed, isTrue);
      verify(() => analytics.trackLessonComplete('s1_l1')).called(1);
      verify(() => eventBus.fire(EmotionEventType.lessonCompleted)).called(1);
      final gem = container.read(gemProvider.notifier) as _FakeGem;
      expect(gem.calls, contains('addGems:10:lesson'));
      expect(gem.calls, contains('addGems:10:first_lesson_of_day'));
      expect(gem.calls, isNot(contains('addGems:20:perfect_lesson')));
      final memory =
          container.read(learningMemoryProvider.notifier) as _FakeMemory;
      expect(memory.records, ['Stage s1:false']); // 2/3 < 0.7
      final achievements =
          container.read(achievementProvider.notifier) as _FakeAchievements;
      expect(achievements.unlocked, contains('first_lesson'));
      verify(
        () => queue.queueLessonCompletion(
          lessonId: 's1_l1',
          stageId: 's1',
          gemsEarned: 20,
          xpEarned: 15,
          correctAnswers: 2,
          totalQuestions: 3,
          completedAt: any(named: 'completedAt'),
          feedback: any(named: 'feedback'),
        ),
      ).called(1);
      expect(repo.savedSnapshots, isNotEmpty);
      verifyNever(() => notifications.scheduleStreakReminder(any()));
    });

    test('perfect lesson otorga bonus y desbloquea el logro', () async {
      repo.fetched = [oneStage()];
      final notifier = container.read(learningProvider.notifier);
      await settle();

      await notifier.completeLesson(
        's1',
        's1_l1',
        perfectLesson: true,
        correctAnswers: 3,
        totalQuestions: 3,
      );

      final gem = container.read(gemProvider.notifier) as _FakeGem;
      expect(gem.calls, contains('addGems:20:perfect_lesson'));
      expect(gem.calls, contains('addGems:20:perfect_lesson'));
      expect(
        (container.read(learningMemoryProvider.notifier) as _FakeMemory)
            .records,
        ['Stage s1:true'],
      );
      expect(
        (container.read(achievementProvider.notifier) as _FakeAchievements)
            .unlocked,
        containsAll(['perfect_lesson', 'first_lesson']),
      );
      verify(() => eventBus.fire(EmotionEventType.perfectLesson)).called(1);
    });

    test('sube de nivel y emite el evento cuando cruza 100 XP', () async {
      repo.fetched = [oneStage()];
      final notifier = container.read(learningProvider.notifier);
      await settle();

      notifier.applyServerXp(99);
      final levels = <int>[];
      final sub = notifier.onLevelUp.listen(levels.add);
      addTearDown(sub.cancel);

      await notifier.completeLesson(
        's1',
        's1_l1',
        correctAnswers: 3,
        totalQuestions: 3,
      );

      final state = container.read(learningProvider);
      expect(state.currentLevel, 2);
      expect(state.xp, 14); // 114 - 100
      expect(state.totalXpEarned, 114);
      expect(levels, [2]);
      verify(() => eventBus.fire(EmotionEventType.levelledUp)).called(1);
    });

    test('no completa lecciones de una etapa bloqueada ni repetidas', () async {
      repo.fetched = [
        _stage(id: 's1', lessons: [_lesson('s1_l1')], unlocked: true),
        _stage(id: 's2', lessons: [_lesson('s2_l1')], unlocked: false),
      ];
      final notifier = container.read(learningProvider.notifier);
      await settle();

      // Etapa 2 sigue bloqueada (etapa 1 incompleta): no-op.
      await notifier.completeLesson('s2', 's2_l1');
      var state = container.read(learningProvider);
      expect(state.lessonsCompleted, 0);
      expect(state.xp, 0);

      // Completar s1 desbloquea la cadena y permite completar s2.
      await notifier.completeLesson('s1', 's1_l1');
      expect(container.read(learningProvider).lessonsCompleted, 1);
      await notifier.completeLesson('s2', 's2_l1');
      expect(container.read(learningProvider).lessonsCompleted, 2);

      // Repetir la misma leccion: no-op.
      await notifier.completeLesson('s1', 's1_l1');
      state = container.read(learningProvider);
      expect(state.lessonsCompleted, 2);
      expect(state.totalXpEarned, 30);

      // Stage/ID desconocidos: no-op.
      await notifier.completeLesson('nope', 's1_l1');
      await notifier.completeLesson('s1', 'nope');
      expect(container.read(learningProvider).totalXpEarned, 30);
    });

    test('consumo de boost activo al completar leccion con XP 2x', () async {
      repo.fetched = [oneStage()];
      final notifier = container.read(learningProvider.notifier);
      final shop = container.read(shopProvider.notifier);
      await settle();
      shop.activateXpBoost();

      await notifier.completeLesson('s1', 's1_l1');

      final state = container.read(learningProvider);
      expect(state.totalXpEarned, 30);
      expect(container.read(shopProvider).xpBoostActive, isFalse);
      verify(
        () => queue.queueLessonCompletion(
          lessonId: 's1_l1',
          stageId: 's1',
          gemsEarned: any(named: 'gemsEarned'),
          xpEarned: 30,
          correctAnswers: any(named: 'correctAnswers'),
          totalQuestions: any(named: 'totalQuestions'),
          completedAt: any(named: 'completedAt'),
          feedback: any(named: 'feedback'),
        ),
      ).called(1);
    });
  });

  // ── Reconciliacion con el servidor ───────────────────────────────
  group('LearningNotifier._reconcileWithServer', () {
    test('ignora duplicados que no sean add_xp', () async {
      final notifier = container.read(learningProvider.notifier);
      await settle();
      final before = container.read(learningProvider).totalXpEarned;

      notifier.reconcileForTest({
        '_op': 'completeLesson',
        'duplicate': true,
        'totalXp': 999,
        'level': 10,
      });

      expect(container.read(learningProvider).totalXpEarned, before);
      verifyNever(
        () => economic.addXp(
          reason: any(named: 'reason'),
          lessonId: any(named: 'lessonId'),
          idempotencyKey: any(named: 'idempotencyKey'),
          achievementId: any(named: 'achievementId'),
        ),
      );
    });

    test(
      'aplica los totales server-authoritative de un add_xp duplicado',
      () async {
        final notifier = container.read(learningProvider.notifier);
        await settle();

        notifier.reconcileForTest({
          '_op': 'add_xp',
          'duplicate': true,
          'totalXp': 210,
          'level': 3,
          'lessonsCompleted': 5,
        });

        final state = container.read(learningProvider);
        expect(state.totalXpEarned, 210);
        expect(state.currentLevel, 3);
        expect(state.xp, 10);
        expect(state.lessonsCompleted, 5);
        expect(repo.savedSnapshots, isNotEmpty);
      },
    );

    test(
      'aplica shape anidado de completeLesson y sincroniza gemas/boost',
      () async {
        when(
          () => rewards.rollChest(
            lessonsCompleted: any(named: 'lessonsCompleted'),
            totalDonated: any(named: 'totalDonated'),
            xp: any(named: 'xp'),
            luckBoostActive: any(named: 'luckBoostActive'),
            contextId: any(named: 'contextId'),
          ),
        ).thenAnswer(
          (_) async => const ChestRewardData(
            type: ChestType.gold,
            xp: 30,
            gems: 25,
            source: 'lesson',
          ),
        );
        final notifier = container.read(learningProvider.notifier);
        await settle();

        notifier.reconcileForTest({
          '_op': 'completeLesson',
          'totalXp': -150,
          'xp': {'totalXp': 250},
          'level': {'current': 3},
          'lessonsCompleted': 9,
          'lessonId': 's1_l1',
          'gems': {'balance': 120},
          'xpBoost': {'remaining': 1},
        });
        await settle();

        final state = container.read(learningProvider);
        expect(state.totalXpEarned, 280); // 250 server + 30 cofre
        expect(state.currentLevel, 3);
        expect(state.xp, 80); // 280 - 200
        expect(state.lessonsCompleted, 9);
        final gem = container.read(gemProvider.notifier) as _FakeGem;
        expect(gem.calls, contains('syncBalance:120'));
        expect(gem.calls, contains('addGems:25:chest_drop'));
        expect(container.read(shopProvider).xpBoostActive, isTrue);
        verify(() => rewards.emitRewardEffects(any())).called(1);
      },
    );

    test('no escribe nada cuando faltan claves de XP', () async {
      final notifier = container.read(learningProvider.notifier);
      await settle();
      final before = container.read(learningProvider).totalXpEarned;

      notifier.reconcileForTest({'_op': 'add_xp', 'foo': 'bar'});

      expect(container.read(learningProvider).totalXpEarned, before);
      final gem = container.read(gemProvider.notifier) as _FakeGem;
      expect(gem.calls, isNot(contains('syncBalance')));
      expect(container.read(shopProvider).xpBoostActive, isFalse);
    });

    test('no aplica cofre cuando rollChest devuelve null', () async {
      final notifier = container.read(learningProvider.notifier);
      await settle();

      notifier.reconcileForTest({
        '_op': 'completeLesson',
        'totalXp': 150,
        'level': 2,
        'lessonsCompleted': 3,
        'lessonId': 's1_l1',
      });
      await settle();

      expect(container.read(learningProvider).totalXpEarned, 150);
      final gem = container.read(gemProvider.notifier) as _FakeGem;
      expect(gem.calls, isNot(contains('addGems:25:chest_drop')));
    });
  });

  // ── recordDonation ───────────────────────────────────────────────
  group('LearningNotifier.recordDonation', () {
    test('monto 0 es no-op', () async {
      final notifier = container.read(learningProvider.notifier);
      await settle();
      await notifier.recordDonation(amount: 0, method: 'mercadopago');
      expect(container.read(learningProvider).totalDonated, 0);
      verifyNever(
        () => economic.recordDonation(
          amount: any(named: 'amount'),
          method: any(named: 'method'),
        ),
      );
    });

    test('acredita el supporter al procesar la donacion', () async {
      when(
        () => economic.recordDonation(
          amount: any(named: 'amount'),
          method: any(named: 'method'),
        ),
      ).thenAnswer((_) async => {});
      final notifier = container.read(learningProvider.notifier);
      await settle();

      await notifier.recordDonation(amount: 50, method: 'whatsapp');

      final state = container.read(learningProvider);
      expect(state.totalDonated, 50);
      expect(state.isSupporter, isTrue);
      expect(repo.savedSnapshots.last['totalDonated'], 50);
    });

    test('revierte el optimista cuando el server marca pending', () async {
      when(
        () => economic.recordDonation(
          amount: any(named: 'amount'),
          method: any(named: 'method'),
        ),
      ).thenAnswer((_) async => {'pending': true});
      final notifier = container.read(learningProvider.notifier);
      await settle();

      await notifier.recordDonation(amount: 50, method: 'yape');

      final state = container.read(learningProvider);
      expect(state.totalDonated, 0);
      expect(state.isSupporter, isFalse);
    });

    test('revierte el optimista si el server falla', () async {
      when(
        () => economic.recordDonation(
          amount: any(named: 'amount'),
          method: any(named: 'method'),
        ),
      ).thenThrow(Exception('boom'));
      final notifier = container.read(learningProvider.notifier);
      await settle();

      await notifier.recordDonation(amount: 50, method: 'plin');

      final state = container.read(learningProvider);
      expect(state.totalDonated, 0);
      expect(state.isSupporter, isFalse);
    });
  });

  // ── addXp ────────────────────────────────────────────────────────
  group('LearningNotifier.addXp', () {
    test('monto 0 es no-op', () async {
      final notifier = container.read(learningProvider.notifier);
      await settle();
      await notifier.addXp(0);
      verifyNever(
        () => economic.addXp(
          reason: any(named: 'reason'),
          lessonId: any(named: 'lessonId'),
          idempotencyKey: any(named: 'idempotencyKey'),
          achievementId: any(named: 'achievementId'),
        ),
      );
    });

    test('aplica los totales del server y guarda', () async {
      when(() => economic.createIdempotencyKey(any())).thenReturn('k1');
      when(
        () => economic.addXp(
          reason: any(named: 'reason'),
          lessonId: any(named: 'lessonId'),
          idempotencyKey: any(named: 'idempotencyKey'),
          achievementId: any(named: 'achievementId'),
        ),
      ).thenAnswer((_) async => {'totalXp': 150, 'level': 2});
      final notifier = container.read(learningProvider.notifier);
      await settle();

      await notifier.addXp(10, reason: 'review');

      final state = container.read(learningProvider);
      expect(state.totalXpEarned, 150);
      expect(state.currentLevel, 2);
      expect(state.xp, 50);
      verify(() => economic.createIdempotencyKey('xp_review')).called(1);
      expect(repo.savedSnapshots, isNotEmpty);
    });

    test('no aplica totales del server en respuesta duplicada', () async {
      when(
        () => economic.addXp(
          reason: any(named: 'reason'),
          lessonId: any(named: 'lessonId'),
          idempotencyKey: any(named: 'idempotencyKey'),
          achievementId: any(named: 'achievementId'),
        ),
      ).thenAnswer(
        (_) async => {'totalXp': 500, 'level': 6, 'duplicate': true},
      );
      final notifier = container.read(learningProvider.notifier);
      await settle();

      await notifier.addXp(25, reason: 'review');

      final state = container.read(learningProvider);
      expect(state.totalXpEarned, 25);
      expect(state.currentLevel, 1);
    });

    test('revierte y reencola offline cuando el server falla', () async {
      when(
        () => economic.addXp(
          reason: any(named: 'reason'),
          lessonId: any(named: 'lessonId'),
          idempotencyKey: any(named: 'idempotencyKey'),
          achievementId: any(named: 'achievementId'),
        ),
      ).thenThrow(Exception('server down'));
      final notifier = container.read(learningProvider.notifier);
      await settle();

      await notifier.addXp(30, reason: 'mission', lessonId: 'l9');

      final state = container.read(learningProvider);
      expect(state.totalXpEarned, 0);
      expect(state.xp, 0);
      verify(
        () => queue.queueAddXp(
          reason: 'mission',
          lessonId: 'l9',
          achievementId: any(named: 'achievementId'),
          idempotencyKey: 'idem-key',
        ),
      ).called(1);
    });

    test('clave idempotente con achievementId al acreditar logros', () async {
      when(
        () => economic.addXp(
          reason: any(named: 'reason'),
          lessonId: any(named: 'lessonId'),
          idempotencyKey: any(named: 'idempotencyKey'),
          achievementId: any(named: 'achievementId'),
        ),
      ).thenThrow(Exception('offline'));
      final notifier = container.read(learningProvider.notifier);
      await settle();

      await notifier.addXp(10, reason: 'achievement', achievementId: 'ach1');

      verify(
        () => economic.createIdempotencyKey('xp_achievement_ach1'),
      ).called(1);
      verify(
        () => queue.queueAddXp(
          reason: 'achievement',
          lessonId: any(named: 'lessonId'),
          achievementId: 'ach1',
          idempotencyKey: 'idem-key',
        ),
      ).called(1);
    });

    test('sube de nivel al cruzar 100 XP y emite el evento', () async {
      when(
        () => economic.addXp(
          reason: any(named: 'reason'),
          lessonId: any(named: 'lessonId'),
          idempotencyKey: any(named: 'idempotencyKey'),
          achievementId: any(named: 'achievementId'),
        ),
      ).thenAnswer((_) async => null);
      final notifier = container.read(learningProvider.notifier);
      await settle();
      notifier.applyServerXp(90);

      final levels = <int>[];
      final sub = notifier.onLevelUp.listen(levels.add);
      addTearDown(sub.cancel);

      await notifier.addXp(20, reason: 'mission');
      final state = container.read(learningProvider);
      expect(state.currentLevel, 2);
      expect(state.xp, 10);
      expect(levels, [2]);
      verify(() => eventBus.fire(EmotionEventType.levelledUp)).called(1);
    });
  });

  // ── applyServerXp / cofre ────────────────────────────────────────
  group('LearningNotifier.applyServerXp y cofre', () {
    test('applyServerXp no-op con monto 0', () async {
      final notifier = container.read(learningProvider.notifier);
      await settle();
      notifier.applyServerXp(0);
      expect(container.read(learningProvider).totalXpEarned, 0);
    });

    test('applyServerXp acredita XP local sin llamar al server', () async {
      final notifier = container.read(learningProvider.notifier);
      await settle();
      notifier.applyServerXp(30);
      final state = container.read(learningProvider);
      expect(state.totalXpEarned, 30);
      expect(state.xp, 30);
      verifyNever(
        () => economic.addXp(
          reason: any(named: 'reason'),
          lessonId: any(named: 'lessonId'),
          idempotencyKey: any(named: 'idempotencyKey'),
          achievementId: any(named: 'achievementId'),
        ),
      );
    });

    test(
      'applyServerXp cruza el nivel y ajusta el XP del nuevo nivel',
      () async {
        final notifier = container.read(learningProvider.notifier);
        await settle();
        notifier.applyServerXp(101);
        final state = container.read(learningProvider);
        expect(state.currentLevel, 2);
        expect(state.xp, 1);
      },
    );

    test('applyServerChestReward con xp y gemas', () async {
      final notifier = container.read(learningProvider.notifier);
      await settle();
      notifier.applyServerChestReward(30, 25);
      expect(container.read(learningProvider).totalXpEarned, 30);
      final gem = container.read(gemProvider.notifier) as _FakeGem;
      expect(gem.calls, contains('addGems:25:chest_drop'));
    });

    test('applyServerChestReward sin gemas no llama a addGems', () async {
      final notifier = container.read(learningProvider.notifier);
      await settle();
      notifier.applyServerChestReward(10, 0);
      final gem = container.read(gemProvider.notifier) as _FakeGem;
      expect(gem.calls, isNot(contains('addGems')));
    });
  });

  // ── logros y sage talks ──────────────────────────────────────────
  group('LearningNotifier.achievements y sage talks', () {
    test('unlockAchievement agrega y guarda', () async {
      final notifier = container.read(learningProvider.notifier);
      await settle();
      notifier.unlockAchievement('custom');
      expect(container.read(learningProvider).achievements, ['custom']);
      expect(repo.savedSnapshots.last['achievements'], ['custom']);
    });

    test('unlockAchievement idempotente', () async {
      final notifier = container.read(learningProvider.notifier);
      await settle();
      notifier.unlockAchievement('custom');
      notifier.unlockAchievement('custom');
      expect(container.read(learningProvider).achievements, ['custom']);
    });

    test('recordSageTalk desbloquea sage_talk al llegar a 10', () async {
      final notifier = container.read(learningProvider.notifier);
      await settle();
      for (var i = 0; i < 9; i++) {
        notifier.recordSageTalk();
        expect(
          (container.read(achievementProvider.notifier) as _FakeAchievements)
              .unlocked,
          isNot(contains('sage_talk')),
        );
      }
      notifier.recordSageTalk();
      expect(container.read(learningProvider).sageTalks, 10);
      expect(
        (container.read(achievementProvider.notifier) as _FakeAchievements)
            .unlocked,
        contains('sage_talk'),
      );
      expect(repo.savedSnapshots.last['sageTalks'], 10);
    });
  });

  // ── reload ───────────────────────────────────────────────────────
  group('LearningNotifier.reload', () {
    test('limpia el errorMessage al recargar con exito', () async {
      repo.fetched = [
        _stage(id: 'r1', lessons: [_lesson('r1_l1')]),
      ];
      repo.seeded = [
        _stage(id: 'r1', lessons: [_lesson('r1_l1')]),
      ];
      final notifier = container.read(learningProvider.notifier);
      await settle(); // init termina via fetchStages (sin asset fallback)
      await notifier.reload();
      expect(container.read(learningProvider).errorMessage, isNull);
      expect(container.read(learningProvider).stages.single.id, 'r1');
    });

    test('marca error si la recarga falla', () async {
      repo.fetched = [
        _stage(id: 'r1', lessons: [_lesson('r1_l1')]),
      ];
      repo.seeded = [
        _stage(id: 'r1', lessons: [_lesson('r1_l1')]),
      ];
      final notifier = container.read(learningProvider.notifier);
      await settle();
      repo.failLoad = true;
      await notifier.reload();
      expect(
        container.read(learningProvider).errorMessage,
        contains('Could not reload'),
      );
    });

    test('se descarta si _init esta en vuelo', () async {
      repo.fetched = [
        _stage(id: 's1', lessons: [_lesson('s1_l1')]),
      ];
      final notifier = container.read(learningProvider.notifier);
      final result = notifier.reload(); // init aun en vuelo: se descarta
      expect(result, completes);
      await settle();
      expect(container.read(learningProvider).isLoading, isFalse);
      expect(container.read(learningProvider).stages.single.id, 's1');
    });
  });

  // ── _save con rollback ───────────────────────────────────────────
  group('LearningNotifier._save rollback', () {
    test('reintenta guardar el snapshot previo si saveAll falla', () async {
      repo.fetched = [
        _stage(id: 's1', lessons: [_lesson('s1_l1')], unlocked: true),
      ];
      final notifier = container.read(learningProvider.notifier);
      await settle();

      repo.failSaveAllCalls = 1;
      await notifier.completeLesson('s1', 's1_l1');

      // Primer saveAll fallo; el rollback debio escribir el snapshot previo
      // (repo se conserva intacto, sin el acreditado de la leccion).
      expect(repo.savedSnapshots, isNotEmpty);
      final last = repo.savedSnapshots.last;
      expect(last['level'], 1);
      expect(last['totalXp'], 0);
      expect(repo.totalXpEarned, 0);
      // El estado local es optimista y conserva el acreditado.
      expect(container.read(learningProvider).totalXpEarned, 15);
    });
  });
}
