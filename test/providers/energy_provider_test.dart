import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/providers/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ProviderContainer createContainer(SharedPreferences prefs) {
    final container = ProviderContainer(
      overrides: [prefsProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('EnergyNotifier', () {
    test('defaults to max energy when nothing is stored', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifier = createContainer(prefs).read(energyProvider.notifier);

      expect(notifier.energy, EnergyNotifier.maxEnergy);
      expect(EnergyNotifier.maxEnergy, 100);
      expect(EnergyNotifier.lessonCost, 20);
      expect(notifier.fraction, 1.0);
      expect(notifier.canDoLesson, isTrue);
    });

    test('loads stored energy', () async {
      SharedPreferences.setMockInitialValues({
        'energy_current': 55,
        'energy_last_regen': DateTime.now().toIso8601String(),
      });
      final prefs = await SharedPreferences.getInstance();
      final notifier = createContainer(prefs).read(energyProvider.notifier);

      expect(notifier.energy, 55);
      expect(notifier.fraction, closeTo(0.55, 0.001));
    });

    test('applies offline regeneration since last regen', () async {
      final last = DateTime.now().subtract(const Duration(minutes: 15));
      SharedPreferences.setMockInitialValues({
        'energy_current': 60,
        'energy_last_regen': last.toIso8601String(),
      });
      final prefs = await SharedPreferences.getInstance();
      final notifier = createContainer(prefs).read(energyProvider.notifier);

      // 3 regen cycles of 5 minutes each
      expect(notifier.energy, 63);
    });

    test('offline regeneration caps at max energy', () async {
      final last = DateTime.now().subtract(const Duration(hours: 8));
      SharedPreferences.setMockInitialValues({
        'energy_current': 90,
        'energy_last_regen': last.toIso8601String(),
      });
      final prefs = await SharedPreferences.getInstance();
      final notifier = createContainer(prefs).read(energyProvider.notifier);

      expect(notifier.energy, 100);
    });

    test('ignores invalid stored date', () async {
      SharedPreferences.setMockInitialValues({
        'energy_current': 30,
        'energy_last_regen': 'not-a-date',
      });
      final prefs = await SharedPreferences.getInstance();
      final notifier = createContainer(prefs).read(energyProvider.notifier);

      expect(notifier.energy, 30);
    });

    test('clamps energy to range on load', () async {
      SharedPreferences.setMockInitialValues({
        'energy_current': 500,
        'energy_last_regen': DateTime.now().toIso8601String(),
      });
      final prefs = await SharedPreferences.getInstance();
      final notifier = createContainer(prefs).read(energyProvider.notifier);

      expect(notifier.energy, 100);
    });

    test('consumeForLesson deducts the lesson cost', () async {
      SharedPreferences.setMockInitialValues({
        'energy_current': 80,
        'energy_last_regen': DateTime.now().toIso8601String(),
      });
      final prefs = await SharedPreferences.getInstance();
      final notifier = createContainer(prefs).read(energyProvider.notifier);

      expect(notifier.consumeForLesson(), isTrue);
      expect(notifier.energy, 60);
      expect(notifier.canDoLesson, isTrue);
    });

    test('consumeForLesson fails when energy is insufficient', () async {
      SharedPreferences.setMockInitialValues({
        'energy_current': 5,
        'energy_last_regen': DateTime.now().toIso8601String(),
      });
      final prefs = await SharedPreferences.getInstance();
      final notifier = createContainer(prefs).read(energyProvider.notifier);

      expect(notifier.canDoLesson, isFalse);
      expect(notifier.consumeForLesson(), isFalse);
      expect(notifier.energy, 5);
    });

    test('addEnergy adds and clamps', () async {
      SharedPreferences.setMockInitialValues({
        'energy_current': 90,
        'energy_last_regen': DateTime.now().toIso8601String(),
      });
      final prefs = await SharedPreferences.getInstance();
      final notifier = createContainer(prefs).read(energyProvider.notifier);

      notifier.addEnergy(5);
      expect(notifier.energy, 95);

      notifier.addEnergy(100);
      expect(notifier.energy, 100);
    });

    test('refill sets energy to max', () async {
      SharedPreferences.setMockInitialValues({
        'energy_current': 10,
        'energy_last_regen': DateTime.now().toIso8601String(),
      });
      final prefs = await SharedPreferences.getInstance();
      final notifier = createContainer(prefs).read(energyProvider.notifier);

      notifier.refill();
      expect(notifier.energy, 100);
    });

    test('persists consumed energy', () async {
      SharedPreferences.setMockInitialValues({
        'energy_current': 100,
        'energy_last_regen': DateTime.now().toIso8601String(),
      });
      final prefs = await SharedPreferences.getInstance();
      final notifier = createContainer(prefs).read(energyProvider.notifier);
      notifier.consumeForLesson();

      expect(prefs.getInt('energy_current'), 80);
    });

    test('regenerates energy on timer tick', () async {
      SharedPreferences.setMockInitialValues({
        'energy_current': 80,
        'energy_last_regen': DateTime.now().toIso8601String(),
      });
      final prefs = await SharedPreferences.getInstance();

      fakeAsync((async) {
        final container = ProviderContainer(
          overrides: [prefsProvider.overrideWithValue(prefs)],
        );
        addTearDown(container.dispose);

        final notifier = container.read(energyProvider.notifier);
        expect(notifier.energy, 80);

        async.elapse(const Duration(minutes: 5));
        expect(notifier.energy, 81);

        async.elapse(const Duration(minutes: 95));
        expect(notifier.energy, 100);

        async.elapse(const Duration(minutes: 30));
        expect(notifier.energy, 100);
      });
    });
  });
}
