import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/repositories/gem_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('GemTransaction', () {
    test('encode/decode round-trip preserves all fields', () {
      final tx = GemTransaction(
        amount: 50,
        reason: 'lesson',
        timestamp: DateTime(2026, 8, 19, 12, 30),
        balanceAfter: 1200,
      );
      final encoded = tx.encode();
      final decoded = GemTransaction.decode(encoded);
      expect(decoded, isNotNull);
      expect(decoded!.amount, 50);
      expect(decoded.reason, 'lesson');
      expect(decoded.timestamp, DateTime(2026, 8, 19, 12, 30));
      expect(decoded.balanceAfter, 1200);
    });

    test('encode/decode handles special characters in reason', () {
      final tx = GemTransaction(
        amount: 10,
        reason: 'shop|pipe,comma"quote',
        timestamp: DateTime(2026, 1, 1),
        balanceAfter: 100,
      );
      final decoded = GemTransaction.decode(tx.encode());
      expect(decoded, isNotNull);
      expect(decoded!.reason, 'shop|pipe,comma"quote');
    });

    test('decode returns null for invalid data', () {
      expect(GemTransaction.decode('garbage'), isNull);
      expect(GemTransaction.decode(''), isNull);
    });

    test('decode handles JSON with missing fields gracefully', () {
      expect(GemTransaction.decode('{"a":5}'), isNull);
      expect(GemTransaction.decode('{"a":5,"r":"x","t":1000}'), isNull);
    });
  });

  group('GemRepositoryImpl', () {
    late GemRepositoryImpl repo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repo = GemRepositoryImpl(prefs);
    });

    test('initial state is all zeros', () {
      expect(repo.balance, 0);
      expect(repo.totalEarned, 0);
      expect(repo.totalSpent, 0);
      expect(repo.transactions, isEmpty);
    });

    test('addGems increases balance and totalEarned', () {
      repo.addGems(25, reason: 'test');
      expect(repo.balance, 25);
      expect(repo.totalEarned, 25);
      expect(repo.transactions, hasLength(1));
      expect(repo.transactions.first.amount, 25);
      expect(repo.transactions.first.reason, 'test');
    });

    test('addGems ignores zero or negative amounts', () {
      repo.addGems(0);
      repo.addGems(-5);
      expect(repo.balance, 0);
      expect(repo.totalEarned, 0);
      expect(repo.transactions, isEmpty);
    });

    test('spendGems decreases balance and increases totalSpent', () {
      repo.addGems(100, reason: 'test');
      final success = repo.spendGems(40, reason: 'shop');
      expect(success, true);
      expect(repo.balance, 60);
      expect(repo.totalSpent, 40);
      expect(repo.transactions, hasLength(2));
      expect(repo.transactions.first.amount, -40);
    });

    test('spendGems returns false when insufficient balance', () {
      repo.addGems(10, reason: 'test');
      final success = repo.spendGems(50, reason: 'shop');
      expect(success, false);
      expect(repo.balance, 10);
      expect(repo.totalSpent, 0);
    });

    test('spendGems returns false for zero or negative amounts', () {
      repo.addGems(100, reason: 'test');
      expect(repo.spendGems(0), false);
      expect(repo.spendGems(-10), false);
      expect(repo.balance, 100);
    });

    test('balance clamps at 100 000', () {
      repo.addGems(99999, reason: 'test');
      repo.addGems(10, reason: 'test');
      expect(repo.balance, 100000);
      expect(repo.totalEarned, 100000);
    });

    test('setBalance clamps at 100 000', () {
      repo.setBalance(200000);
      expect(repo.balance, 100000);
    });

    test('setBalance clamps at 0', () {
      repo.setBalance(-500);
      expect(repo.balance, 0);
    });

    test('save and reload preserves state', () async {
      repo.addGems(50, reason: 'lesson');
      repo.addGems(20, reason: 'bonus');
      repo.spendGems(10, reason: 'shop');
      repo.save();

      SharedPreferences.setMockInitialValues({
        'gems_balance': 60,
        'gems_total_earned': 70,
        'gems_total_spent': 10,
        'gems_transactions': repo.transactions.map((t) => t.encode()).toList(),
      });
      final prefs = await SharedPreferences.getInstance();
      final reloaded = GemRepositoryImpl(prefs);
      expect(reloaded.balance, 60);
      expect(reloaded.totalEarned, 70);
      expect(reloaded.totalSpent, 10);
      expect(reloaded.transactions, hasLength(3));
    });

    test('transactions list is unmodifiable', () {
      repo.addGems(10, reason: 'test');
      expect(
        () => repo.transactions.add(
          GemTransaction(
            amount: 1,
            reason: 'x',
            timestamp: DateTime.now(),
            balanceAfter: 0,
          ),
        ),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('transaction log caps at 200 entries', () {
      for (var i = 0; i < 210; i++) {
        repo.addGems(1, reason: 'tx_$i');
      }
      expect(repo.transactions, hasLength(200));
    });
  });

  group('GemNotifier', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [prefsProvider.overrideWithValue(prefs)],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has zero balance', () {
      final state = container.read(gemProvider);
      expect(state.balance, 0);
      expect(state.totalEarned, 0);
      expect(state.totalSpent, 0);
      expect(state.transactions, isEmpty);
    });

    test('addGems increases balance and emits on stream', () async {
      final notifier = container.read(gemProvider.notifier);
      final amounts = <int>[];
      final sub = notifier.onGemsEarned.listen(amounts.add);

      notifier.addGems(25, reason: 'test');
      await Future<void>.delayed(Duration.zero);

      expect(container.read(gemProvider).balance, 25);
      expect(amounts, [25]);
      await sub.cancel();
    });

    test('addGems no-ops for zero or negative amounts', () {
      final notifier = container.read(gemProvider.notifier);
      notifier.addGems(0);
      notifier.addGems(-5);
      expect(container.read(gemProvider).balance, 0);
    });

    test('spendGems decreases balance', () {
      final notifier = container.read(gemProvider.notifier);
      notifier.addGems(100, reason: 'test');
      final success = notifier.spendGems(30, reason: 'shop');
      expect(success, true);
      expect(container.read(gemProvider).balance, 70);
    });

    test('spendGems returns false when insufficient', () {
      final notifier = container.read(gemProvider.notifier);
      notifier.addGems(10, reason: 'test');
      final success = notifier.spendGems(50, reason: 'shop');
      expect(success, false);
      expect(container.read(gemProvider).balance, 10);
    });

    test('awardLessonGems awards correct base amount', () {
      final notifier = container.read(gemProvider.notifier);
      notifier.awardLessonGems(8);
      expect(container.read(gemProvider).balance, 40);
    });

    test('awardLessonGems does not award for zero correct', () {
      final notifier = container.read(gemProvider.notifier);
      notifier.awardLessonGems(0);
      expect(container.read(gemProvider).balance, 0);
    });

    test('awardPerfectLessonBonus awards 20 gems', () {
      final notifier = container.read(gemProvider.notifier);
      notifier.awardPerfectLessonBonus();
      expect(container.read(gemProvider).balance, 20);
    });

    test('awardDailyBonus awards based on streak', () {
      final notifier = container.read(gemProvider.notifier);
      notifier.awardDailyBonus(1);
      expect(container.read(gemProvider).balance, 5);

      // Second call same day should no-op
      notifier.awardDailyBonus(2);
      expect(container.read(gemProvider).balance, 5);
    });

    test('milestone fires when threshold crossed', () async {
      final notifier = container.read(gemProvider.notifier);
      final milestones = <int>[];
      final sub = notifier.onGemMilestone.listen(milestones.add);

      notifier.addGems(100, reason: 'test');
      await Future<void>.delayed(Duration.zero);

      expect(milestones, [100]);
      await sub.cancel();
    });

    test('milestone does not re-fire for same threshold', () async {
      final notifier = container.read(gemProvider.notifier);
      final milestones = <int>[];
      final sub = notifier.onGemMilestone.listen(milestones.add);

      notifier.addGems(60, reason: 'test');
      await Future<void>.delayed(Duration.zero);
      notifier.addGems(40, reason: 'test');
      await Future<void>.delayed(Duration.zero);

      expect(milestones, [100]);
      await sub.cancel();
    });

    test('cap warning fires once when balance >= 95000', () async {
      final notifier = container.read(gemProvider.notifier);
      final warnings = <void>[];
      final sub = notifier.onCapWarning.listen((_) => warnings.add(null));

      notifier.addGems(95000, reason: 'test');
      await Future<void>.delayed(Duration.zero);
      expect(warnings, hasLength(1));

      // Adding more gems should NOT fire again
      notifier.addGems(1000, reason: 'test');
      await Future<void>.delayed(Duration.zero);
      expect(warnings, hasLength(1));

      // But after spending below 95k and earning again, it should re-fire
      notifier.spendGems(10000, reason: 'shop');
      notifier.addGems(10000, reason: 'test');
      await Future<void>.delayed(Duration.zero);
      expect(warnings, hasLength(2));
      await sub.cancel();
    });

    test('GemState.transactions is reactive', () {
      final notifier = container.read(gemProvider.notifier);
      notifier.addGems(10, reason: 'test');
      final state = container.read(gemProvider);
      expect(state.transactions, hasLength(1));
    });
  });
}
