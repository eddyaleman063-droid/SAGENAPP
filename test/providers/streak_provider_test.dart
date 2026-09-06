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
  });
}
