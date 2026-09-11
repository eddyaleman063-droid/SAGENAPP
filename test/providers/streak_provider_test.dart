import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagen/models/special_item.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/economic_functions_service.dart';
import 'package:sagen/services/streak_chest_service.dart';

import '../helpers/mock_learning_provider.dart';

class MockEconomicFunctionsService extends Mock
    implements EconomicFunctionsService {}

class MockStreakChestService extends Mock implements StreakChestService {}

void main() {
  setUpAll(() {
    registerFallbackValue(MockLearningNotifier());
  });

  ProviderContainer createContainer(SharedPreferences prefs) {
    final mockEconomic = MockEconomicFunctionsService();
    final mockChest = MockStreakChestService();

    when(
      () => mockEconomic.incrementStreak(
        freezeUsed: any(named: 'freezeUsed'),
        activityDay: any(named: 'activityDay'),
        activityStreak: any(named: 'activityStreak'),
      ),
    ).thenAnswer((_) async => <String, dynamic>{});
    when(
      () => mockChest.checkAndReward(
        oldStreak: any(named: 'oldStreak'),
        newStreak: any(named: 'newStreak'),
        learning: any(named: 'learning'),
      ),
    ).thenAnswer((_) async {});

    return ProviderContainer(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        learningProvider.overrideWith(MockLearningNotifier.new),
        economicFunctionsServiceProvider.overrideWithValue(mockEconomic),
        streakChestServiceProvider.overrideWithValue(mockChest),
      ],
    );
  }

  group('StreakNotifier', () {
    test('starts with zero streak', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = createContainer(prefs);
      addTearDown(() => container.dispose());
      final notifier = container.read(streakProvider.notifier);
      expect(notifier.currentStreak, 0);
      expect(notifier.longestStreak, 0);
      expect(notifier.streakFreezes, 0);
      expect(notifier.streakHistory, isEmpty);
    });
    test('tracks daily check-in', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = createContainer(prefs);
      addTearDown(() => container.dispose());
      final notifier = container.read(streakProvider.notifier);
      notifier.checkIn();
      expect(notifier.currentStreak, greaterThanOrEqualTo(1));
      expect(notifier.lastActivityDate, isNotNull);
    });
    test('provides emotional messages after check-in', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = createContainer(prefs);
      addTearDown(() => container.dispose());
      final notifier = container.read(streakProvider.notifier);
      notifier.checkIn();
      expect(notifier.emotionalMessages, isNotEmpty);
    });
    test('check-in increments streak', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = createContainer(prefs);
      addTearDown(() => container.dispose());
      final notifier = container.read(streakProvider.notifier);
      notifier.checkIn();
      final afterFirst = notifier.currentStreak;
      expect(afterFirst, greaterThanOrEqualTo(1));
    });
    test(
      'reconciliación: no regresa una racha local legítima ante divergencia del servidor',
      () async {
        // Ra cha local consolidada (10 días), última actividad HOY.
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        SharedPreferences.setMockInitialValues({
          'streak_current': 10,
          'streak_longest': 10,
          'streak_last_activity': today.toIso8601String(),
          'streak_freezes': 2,
        });
        final prefs = await SharedPreferences.getInstance();
        final container = createContainer(prefs);
        addTearDown(() => container.dispose());

        // El servidor está por detrás (syncs previos fallaron): devuelve 3.
        final ec = container.read(economicFunctionsServiceProvider);
        when(
          () => ec.incrementStreak(
            freezeUsed: any(named: 'freezeUsed'),
            activityDay: any(named: 'activityDay'),
            activityStreak: any(named: 'activityStreak'),
          ),
        ).thenAnswer((_) async => {'currentStreak': 3, 'longestStreak': 3});

        final notifier = container.read(streakProvider.notifier);
        expect(notifier.currentStreak, 10);

        notifier.checkIn();

        // Esperar a que el sync (fire-and-forget con retry) reconcilie.
        await Future<void>.delayed(const Duration(milliseconds: 200));

        // La racha local legítima se conserva (máximo), no se regresa a 3.
        expect(notifier.currentStreak, greaterThanOrEqualTo(10));
        expect(notifier.longestStreak, greaterThanOrEqualTo(10));
      },
    );

    test(
      'reconciliación: respeta la rotura explícita del servidor (baja a 1)',
      () async {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        SharedPreferences.setMockInitialValues({
          'streak_current': 6,
          'streak_longest': 12,
          'streak_last_activity': today.toIso8601String(),
          'streak_freezes': 1,
        });
        final prefs = await SharedPreferences.getInstance();
        final container = createContainer(prefs);
        addTearDown(() => container.dispose());

        // `streakBroken` solo se devuelve tras una llamada real de incremento;
        // aquí simulamos una divergencia donde el servidor rompió la racha.
        final ec = container.read(economicFunctionsServiceProvider);
        when(
          () => ec.incrementStreak(
            freezeUsed: any(named: 'freezeUsed'),
            activityDay: any(named: 'activityDay'),
            activityStreak: any(named: 'activityStreak'),
          ),
        ).thenAnswer(
          (_) async => {
            'currentStreak': 1,
            'longestStreak': 12,
            'streakBroken': true,
          },
        );

        final notifier = container.read(streakProvider.notifier);
        notifier.checkIn();

        await Future<void>.delayed(const Duration(milliseconds: 200));

        // Cuando el servidor rompió la racha de forma explícita, el cliente
        // acepta el valor bajo (no aplica max).
        expect(notifier.currentStreak, 1);
      },
    );

    test(
      'reload() usa sync read-only (checkIn:false) y no muta el servidor',
      () async {
        final yesterday = DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String();
        SharedPreferences.setMockInitialValues({
          'streak_current': 5,
          'streak_longest': 5,
          'streak_freezes': 1,
          'streak_last_activity': yesterday,
        });
        final prefs = await SharedPreferences.getInstance();
        final container = createContainer(prefs);
        addTearDown(() => container.dispose());
        final ec = container.read(economicFunctionsServiceProvider);
        when(
          () => ec.incrementStreak(
            freezeUsed: any(named: 'freezeUsed'),
            checkIn: any(named: 'checkIn'),
            activityDay: any(named: 'activityDay'),
            activityStreak: any(named: 'activityStreak'),
          ),
        ).thenAnswer(
          (_) async => {
            'currentStreak': 5,
            'longestStreak': 5,
            'shieldsRemaining': 1,
          },
        );

        final notifier = container.read(streakProvider.notifier);
        notifier.reload();

        await Future<void>.delayed(const Duration(milliseconds: 200));

        // reload/login hace un sync read-only: se consume incrementStreak con
        // checkIn:false (el servidor no avanza racha, no quema escudos). La racha
        // local se conserva tal cual.
        verify(
          () => ec.incrementStreak(
            freezeUsed: false,
            checkIn: false,
            itemUsed: any(named: 'itemUsed'),
            activityDay: any(named: 'activityDay'),
            activityStreak: any(named: 'activityStreak'),
          ),
        ).called(1);
        expect(notifier.currentStreak, 5);
      },
    );

    test('monthly stats accessible', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = createContainer(prefs);
      addTearDown(() => container.dispose());
      final notifier = container.read(streakProvider.notifier);
      expect(notifier.monthlyStreakStats, isNotNull);
      expect(notifier.monthlyStreakStats.keys.length, 6);
    });
    test('weekly stats accessible', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = createContainer(prefs);
      addTearDown(() => container.dispose());
      final notifier = container.read(streakProvider.notifier);
      expect(notifier.weeklyStats, isNotNull);
    });
    test('heatmap data accessible', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = createContainer(prefs);
      addTearDown(() => container.dispose());
      final notifier = container.read(streakProvider.notifier);
      expect(notifier.heatmapData, isNotNull);
    });
    test('sets defrosting flag when check-in while frozen', () async {
      final yesterday = DateTime.now()
          .subtract(const Duration(days: 1))
          .toIso8601String();
      SharedPreferences.setMockInitialValues({
        'streak_current': 5,
        'streak_longest': 5,
        'streak_freezes': 1,
        'streak_last_activity': yesterday,
      });
      final prefs = await SharedPreferences.getInstance();
      final container = createContainer(prefs);
      addTearDown(() => container.dispose());
      final notifier = container.read(streakProvider.notifier);
      expect(notifier.isStreakFrozen, isTrue);
      notifier.checkIn();
      expect(notifier.isStreakFrozen, isFalse);
      await Future<void>.delayed(Duration.zero);
      expect(prefs.getBool('streak_just_defrosted'), isTrue);
    });
    test('daily bonus awarded only on first check-in of local day', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = createContainer(prefs);
      addTearDown(() => container.dispose());
      final notifier = container.read(streakProvider.notifier);
      final gems = container.read(gemProvider.notifier);

      notifier.checkIn();
      final afterFirst = gems.state.balance;

      // Un segundo check-in del mismo día no debe duplicar el bono diario.
      notifier.checkIn();
      expect(gems.state.balance, afterFirst);
      expect(notifier.totalCheckIns, 1);
    });

    test(
      'reconcilia el contador local de escudos con los del servidor (read-back)',
      () async {
        final yesterday = DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String();
        SharedPreferences.setMockInitialValues({
          'streak_current': 3,
          'streak_longest': 3,
          'streak_freezes': 1,
          'streak_last_activity': yesterday,
        });
        final prefs = await SharedPreferences.getInstance();
        final container = createContainer(prefs);
        addTearDown(() => container.dispose());
        final ec = container.read(economicFunctionsServiceProvider);
        when(
          () => ec.incrementStreak(
            freezeUsed: any(named: 'freezeUsed'),
            activityDay: any(named: 'activityDay'),
            activityStreak: any(named: 'activityStreak'),
          ),
        ).thenAnswer(
          (_) async => {
            'currentStreak': 4,
            'longestStreak': 4,
            'shieldsRemaining': 2,
          },
        );

        final notifier = container.read(streakProvider.notifier);
        notifier.checkIn();

        await Future<void>.delayed(const Duration(milliseconds: 200));

        // El servidor es la fuente de verdad de escudos: el contador local se
        // sincroniza con shieldsRemaining (2) aunque la racha devuelta
        // coincida con la local.
        expect(notifier.streakFreezes, 2);
      },
    );

    test(
      'H5: titanium metal declara el ítem y el servidor lo consume (server-authoritative)',
      () async {
        final threeDaysAgo = DateTime.now()
            .subtract(const Duration(days: 3))
            .toIso8601String();
        SharedPreferences.setMockInitialValues({
          'streak_current': 10,
          'streak_longest': 15,
          'streak_last_activity': threeDaysAgo,
          'special_item_quantities': '{"titaniumShield":1}',
        });
        final prefs = await SharedPreferences.getInstance();
        final container = createContainer(prefs);
        addTearDown(() => container.dispose());
        final ec = container.read(economicFunctionsServiceProvider);
        when(
          () => ec.incrementStreak(
            freezeUsed: any(named: 'freezeUsed'),
            checkIn: any(named: 'checkIn'),
            itemUsed: any(named: 'itemUsed'),
            activityDay: any(named: 'activityDay'),
            activityStreak: any(named: 'activityStreak'),
          ),
        ).thenAnswer(
          (_) async => {
            'currentStreak': 11,
            'longestStreak': 15,
            'itemConsumed': true,
            'itemUsed': 'titaniumShield',
            'shieldsRemaining': 0,
          },
        );

        final notifier = container.read(streakProvider.notifier);

        // Sin escudos y con racha vencida, el cliente declara el ítem al servidor.
        notifier.checkIn();
        expect(notifier.currentStreak, 11);

        await Future<void>.delayed(const Duration(milliseconds: 200));

        // El sync confirmó el consumo: el ítem ya no está en el inventario local
        // y la racha protegida se conserva.
        verify(
          () => ec.incrementStreak(
            freezeUsed: false,
            checkIn: true,
            itemUsed: 'titaniumShield',
            activityDay: any(named: 'activityDay'),
            activityStreak: any(named: 'activityStreak'),
          ),
        ).called(1);
        expect(
          container.read(itemProvider).quantity(SpecialItemType.titaniumShield),
          0,
        );
        expect(notifier.currentStreak, 11);
      },
    );

    test(
      'H5: phoenix feather revive sin gastar el max() del cliente',
      () async {
        final threeDaysAgo = DateTime.now()
            .subtract(const Duration(days: 3))
            .toIso8601String();
        SharedPreferences.setMockInitialValues({
          'streak_current': 10,
          'streak_longest': 10,
          'streak_last_activity': threeDaysAgo,
          'special_item_quantities': '{"phoenixFeather":1}',
        });
        final prefs = await SharedPreferences.getInstance();
        final container = createContainer(prefs);
        addTearDown(() => container.dispose());
        final ec = container.read(economicFunctionsServiceProvider);
        when(
          () => ec.incrementStreak(
            freezeUsed: any(named: 'freezeUsed'),
            checkIn: any(named: 'checkIn'),
            itemUsed: any(named: 'itemUsed'),
            activityDay: any(named: 'activityDay'),
            activityStreak: any(named: 'activityStreak'),
          ),
        ).thenAnswer(
          (_) async => {
            'currentStreak': 10,
            'longestStreak': 10,
            'itemConsumed': true,
            'itemUsed': 'phoenixFeather',
            'revived': true,
            'shieldsRemaining': 0,
          },
        );

        final notifier = container.read(streakProvider.notifier);

        notifier.checkIn();
        expect(notifier.currentStreak, 10);

        await Future<void>.delayed(const Duration(milliseconds: 200));

        // Revive = conserva el valor previo (10), no 11.
        verify(
          () => ec.incrementStreak(
            freezeUsed: false,
            checkIn: true,
            itemUsed: 'phoenixFeather',
            activityDay: any(named: 'activityDay'),
            activityStreak: any(named: 'activityStreak'),
          ),
        ).called(1);
        expect(
          container.read(itemProvider).quantity(SpecialItemType.phoenixFeather),
          0,
        );
        expect(notifier.currentStreak, 10);
      },
    );

    test(
      'H5: servidor deniega el ítem (inventario vacío): rompe y NO consume localmente',
      () async {
        final threeDaysAgo = DateTime.now()
            .subtract(const Duration(days: 3))
            .toIso8601String();
        SharedPreferences.setMockInitialValues({
          'streak_current': 10,
          'streak_longest': 15,
          'streak_last_activity': threeDaysAgo,
          'special_item_quantities': '{"titaniumShield":1}',
        });
        final prefs = await SharedPreferences.getInstance();
        final container = createContainer(prefs);
        addTearDown(() => container.dispose());
        final ec = container.read(economicFunctionsServiceProvider);
        when(
          () => ec.incrementStreak(
            freezeUsed: any(named: 'freezeUsed'),
            checkIn: any(named: 'checkIn'),
            itemUsed: any(named: 'itemUsed'),
            activityDay: any(named: 'activityDay'),
            activityStreak: any(named: 'activityStreak'),
          ),
        ).thenAnswer(
          (_) async => {
            'currentStreak': 1,
            'longestStreak': 15,
            'streakBroken': true,
            'itemDenied': true,
            'shieldsRemaining': 0,
          },
        );

        final notifier = container.read(streakProvider.notifier);
        final items = container.read(itemProvider);

        notifier.checkIn();
        await Future<void>.delayed(const Duration(milliseconds: 200));

        // Sin ítem real en el servidor, la racha se rompe y el ítem local
        // NO se consume (la ilusión de consumo se elimina).
        expect(notifier.currentStreak, 1);
        expect(items.quantity(SpecialItemType.titaniumShield), 1);
      },
    );

    test(
      'NUEVO-fix: envía activityDay/activityStreak locales al hacer check-in',
      () async {
        final threeDaysAgoUtc = DateTime.now()
            .subtract(const Duration(days: 3))
            .toUtc();
        final expectedDay =
            '${threeDaysAgoUtc.year}-'
            '${threeDaysAgoUtc.month.toString().padLeft(2, '0')}-'
            '${threeDaysAgoUtc.day.toString().padLeft(2, '0')}';
        SharedPreferences.setMockInitialValues({
          'streak_current': 10,
          'streak_longest': 10,
          'streak_last_activity': threeDaysAgoUtc.toIso8601String(),
        });
        final prefs = await SharedPreferences.getInstance();
        final container = createContainer(prefs);
        addTearDown(() => container.dispose());
        final ec = container.read(economicFunctionsServiceProvider);
        when(
          () => ec.incrementStreak(
            freezeUsed: any(named: 'freezeUsed'),
            checkIn: any(named: 'checkIn'),
            itemUsed: any(named: 'itemUsed'),
            activityDay: any(named: 'activityDay'),
            activityStreak: any(named: 'activityStreak'),
          ),
        ).thenAnswer(
          (_) async => {
            'currentStreak': 10,
            'longestStreak': 10,
            'streakBroken': true,
            'shieldsRemaining': 0,
          },
        );

        final notifier = container.read(streakProvider.notifier);
        notifier.checkIn();
        await Future<void>.delayed(const Duration(milliseconds: 200));

        // El sync lleva el día UTC del último check-in local previo y la racha
        // previa; el server los usa para recuperar días offline probados.
        verify(
          () => ec.incrementStreak(
            freezeUsed: false,
            checkIn: true,
            itemUsed: any(named: 'itemUsed'),
            activityDay: expectedDay,
            activityStreak: 10,
          ),
        ).called(1);
      },
    );

    test('emite mensajes emocionales a cada hito (100/50/30/14)', () async {
      final cases = <(int, String)>[
        (100, '100 days of constant protection. Legend.'),
        (50, '50 days of constant digital protection.'),
        (30, 'One month of learning.'),
        (14, 'Two weeks of consistency.'),
      ];
      for (final c in cases) {
        SharedPreferences.setMockInitialValues({
          'streak_current': c.$1,
          'streak_longest': c.$1,
        });
        final prefs = await SharedPreferences.getInstance();
        final container = createContainer(prefs);
        final notifier = container.read(streakProvider.notifier);
        expect(
          notifier.emotionalMessages.any((m) => m.contains(c.$2)),
          true,
          reason: 'hito ${c.$1}',
        );
        container.dispose();
      }
    });

    test('checkIn cruza hitos y desbloquea logros (14/30/100)', () async {
      final cases = <(int, int)>[(13, 14), (29, 30), (99, 100)];
      for (final c in cases) {
        final yesterday = DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String();
        SharedPreferences.setMockInitialValues({
          'streak_current': c.$1,
          'streak_longest': c.$1,
          'streak_last_activity': yesterday,
        });
        final prefs = await SharedPreferences.getInstance();
        final container = createContainer(prefs);
        final notifier = container.read(streakProvider.notifier);
        notifier.checkIn();
        expect(notifier.currentStreak, c.$2, reason: 'hito ${c.$1}->${c.$2}');
        container.dispose();
      }
    });

    test('lee todos los getters simples', () async {
      SharedPreferences.setMockInitialValues({
        'streak_current': 1,
        'streak_longest': 7,
        'streak_history': '2026-01-01,2026-01-02',
      });
      final prefs = await SharedPreferences.getInstance();
      final container = createContainer(prefs);
      addTearDown(() => container.dispose());
      final notifier = container.read(streakProvider.notifier);
      expect(notifier.status, isNotNull);
      expect(notifier.isAtRisk, isA<bool>());
      expect(notifier.message, isA<String>());
      expect(notifier.tier, isA<String>());
      expect(notifier.hasStreak, isA<bool>());
      expect(notifier.perfectWeeks, isA<int>());
      expect(notifier.missionCompleted, isA<bool>());
      expect(notifier.monthlyStats, isNotNull);
      expect(container.read(streakProvider).freezeConsumed, isA<bool>());
      expect(notifier.streakHistory, ['2026-01-01', '2026-01-02']);
    });

    test('cacheMonthlyStats y completeMission marcan estado', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = createContainer(prefs);
      addTearDown(() => container.dispose());
      final notifier = container.read(streakProvider.notifier);
      expect(notifier.missionCompleted, isFalse);
      notifier.completeMission();
      expect(notifier.missionCompleted, isTrue);
      notifier.completeMission();
      notifier.cacheMonthlyStats();
      notifier.cacheMonthlyStats();
      notifier.clearMilestone();
    });

    test('setFreezes aplica el valor dado (clamp 0..max)', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = createContainer(prefs);
      addTearDown(() => container.dispose());
      final notifier = container.read(streakProvider.notifier);
      notifier.setFreezes(3);
      expect(notifier.streakFreezes, 3);
    });

    test('heatmap >365 recortado al cargar y al añadir día', () async {
      final heatmap = <String>[
        for (var i = 1; i <= 400; i++) 'day-$i:1',
      ].join(',');
      final yesterday = DateTime.now()
          .subtract(const Duration(days: 1))
          .toIso8601String();
      SharedPreferences.setMockInitialValues({
        'streak_heatmap': heatmap,
        'streak_current': 3,
        'streak_longest': 3,
        'streak_last_activity': yesterday,
      });
      final prefs = await SharedPreferences.getInstance();
      final container = createContainer(prefs);
      addTearDown(() => container.dispose());
      final notifier = container.read(streakProvider.notifier);
      expect(notifier.heatmapData.length, lessThanOrEqualTo(365));
      notifier.checkIn();
      expect(notifier.heatmapData.length, lessThanOrEqualTo(365));
    });

    test('reconcile: serverLongest supera al local y gana', () async {
      final yesterday = DateTime.now()
          .subtract(const Duration(days: 1))
          .toIso8601String();
      SharedPreferences.setMockInitialValues({
        'streak_current': 10,
        'streak_longest': 10,
        'streak_last_activity': yesterday,
      });
      final prefs = await SharedPreferences.getInstance();
      final container = createContainer(prefs);
      addTearDown(() => container.dispose());
      final ec = container.read(economicFunctionsServiceProvider);
      when(
        () => ec.incrementStreak(
          freezeUsed: any(named: 'freezeUsed'),
          checkIn: any(named: 'checkIn'),
          itemUsed: any(named: 'itemUsed'),
          activityDay: any(named: 'activityDay'),
          activityStreak: any(named: 'activityStreak'),
        ),
      ).thenAnswer((_) async => {'currentStreak': 10, 'longestStreak': 20});
      final notifier = container.read(streakProvider.notifier);
      notifier.checkIn();
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(notifier.longestStreak, 20);
    });

    test('reconcile: rotura con freezeDenied repone un escudo local', () async {
      final yesterday = DateTime.now()
          .subtract(const Duration(days: 1))
          .toIso8601String();
      SharedPreferences.setMockInitialValues({
        'streak_current': 10,
        'streak_longest': 10,
        'streak_last_activity': yesterday,
      });
      final prefs = await SharedPreferences.getInstance();
      final container = createContainer(prefs);
      addTearDown(() => container.dispose());
      final ec = container.read(economicFunctionsServiceProvider);
      when(
        () => ec.incrementStreak(
          freezeUsed: any(named: 'freezeUsed'),
          checkIn: any(named: 'checkIn'),
          itemUsed: any(named: 'itemUsed'),
          activityDay: any(named: 'activityDay'),
          activityStreak: any(named: 'activityStreak'),
        ),
      ).thenAnswer(
        (_) async => {
          'currentStreak': 1,
          'longestStreak': 10,
          'freezeDenied': true,
        },
      );
      final notifier = container.read(streakProvider.notifier);
      notifier.setFreezes(2);
      notifier.checkIn();
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(notifier.currentStreak, 1);
      expect(notifier.streakFreezes, 3);
    });

    test('reconcile: rotura sin longestStreak conserva el local', () async {
      final yesterday = DateTime.now()
          .subtract(const Duration(days: 1))
          .toIso8601String();
      SharedPreferences.setMockInitialValues({
        'streak_current': 10,
        'streak_longest': 10,
        'streak_last_activity': yesterday,
      });
      final prefs = await SharedPreferences.getInstance();
      final container = createContainer(prefs);
      addTearDown(() => container.dispose());
      final ec = container.read(economicFunctionsServiceProvider);
      when(
        () => ec.incrementStreak(
          freezeUsed: any(named: 'freezeUsed'),
          checkIn: any(named: 'checkIn'),
          itemUsed: any(named: 'itemUsed'),
          activityDay: any(named: 'activityDay'),
          activityStreak: any(named: 'activityStreak'),
        ),
      ).thenAnswer((_) async => {'currentStreak': 1, 'streakBroken': true});
      final notifier = container.read(streakProvider.notifier);
      notifier.setFreezes(2);
      notifier.checkIn();
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(notifier.currentStreak, 1);
      // El server no envía longestStreak: se conserva el local (11 tras el
      // checkIn local que sumó 1 antes de que el reconcile bajara la racha).
      expect(notifier.longestStreak, 11);
    });

    test(
      'H5 titanium: longestStreak local menor no infla el fallback',
      () async {
        final threeDaysAgo = DateTime.now()
            .subtract(const Duration(days: 3))
            .toIso8601String();
        SharedPreferences.setMockInitialValues({
          'streak_current': 10,
          'streak_longest': 10,
          'streak_last_activity': threeDaysAgo,
          'special_item_quantities': '{"titaniumShield":1}',
        });
        final prefs = await SharedPreferences.getInstance();
        final container = createContainer(prefs);
        addTearDown(() => container.dispose());
        final notifier = container.read(streakProvider.notifier);
        notifier.checkIn();
        expect(notifier.currentStreak, 11);
        await Future<void>.delayed(const Duration(milliseconds: 200));
        expect(notifier.currentStreak, 11);
      },
    );

    test(
      'freeze consumido dispara el just-defrosted y notificación estable',
      () async {
        final threeDaysAgo = DateTime.now()
            .subtract(const Duration(days: 3))
            .toIso8601String();
        SharedPreferences.setMockInitialValues({
          'streak_current': 5,
          'streak_longest': 5,
          'streak_freezes': 1,
          'streak_last_activity': threeDaysAgo,
        });
        final prefs = await SharedPreferences.getInstance();
        final container = createContainer(prefs);
        addTearDown(() => container.dispose());
        final notifier = container.read(streakProvider.notifier);
        expect(notifier.isStreakFrozen, isTrue);
        notifier.checkIn();
        expect(notifier.isStreakFrozen, isFalse);
        expect(notifier.streakFreezes, 0);
        await Future<void>.delayed(const Duration(milliseconds: 200));
        expect(prefs.getBool('streak_just_defrosted'), isTrue);
      },
    );

    test('dos syncs solapados: el segundo se encola y re-despacha', () async {
      final completer = Completer<Map<String, dynamic>>();
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = createContainer(prefs);
      addTearDown(() => container.dispose());
      final ec = container.read(economicFunctionsServiceProvider);
      when(
        () => ec.incrementStreak(
          freezeUsed: any(named: 'freezeUsed'),
          checkIn: any(named: 'checkIn'),
          itemUsed: any(named: 'itemUsed'),
          activityDay: any(named: 'activityDay'),
          activityStreak: any(named: 'activityStreak'),
        ),
      ).thenAnswer((_) => completer.future);
      final notifier = container.read(streakProvider.notifier);
      notifier.reload();
      notifier.checkIn();
      await Future<void>.delayed(Duration.zero);
      completer.complete({'currentStreak': 1, 'longestStreak': 1});
      await Future<void>.delayed(const Duration(milliseconds: 200));
      verify(
        () => ec.incrementStreak(
          freezeUsed: any(named: 'freezeUsed'),
          checkIn: any(named: 'checkIn'),
          itemUsed: any(named: 'itemUsed'),
          activityDay: any(named: 'activityDay'),
          activityStreak: any(named: 'activityStreak'),
        ),
      ).called(2);
    });
  });
}
