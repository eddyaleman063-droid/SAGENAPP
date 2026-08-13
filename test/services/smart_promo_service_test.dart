import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/services/smart_promo_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final service = SmartPromoService.instance;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await service.init();
  });

  test('incrementLessonCount increments the counter', () async {
    await service.incrementLessonCount();
    await service.incrementLessonCount();
    expect(service.lessonsUntilNextPromo, 1);
  });

  test(
    'shouldShowPromo is false before reaching the lesson threshold',
    () async {
      await service.incrementLessonCount();
      await service.incrementLessonCount();
      expect(service.shouldShowPromo(), isFalse);
    },
  );

  test('shouldShowPromo is true at the lesson threshold', () async {
    for (int i = 0; i < 3; i++) {
      await service.incrementLessonCount();
    }
    expect(service.shouldShowPromo(), isTrue);
  });

  test('recordPromoShown resets the lesson counter', () async {
    for (int i = 0; i < 5; i++) {
      await service.incrementLessonCount();
    }
    await service.recordPromoShown();
    expect(service.shouldShowPromo(), isFalse);
    expect(service.lessonsUntilNextPromo, 3);
  });

  test('dismissForCooldown hides the promo and grows the cooldown', () async {
    for (int i = 0; i < 3; i++) {
      await service.incrementLessonCount();
    }
    await service.dismissForCooldown();
    expect(service.shouldShowPromo(), isFalse);

    await service.dismissForCooldown();
    await service.dismissForCooldown();
    expect(service.shouldShowPromo(), isFalse);
  });

  test('dismissForever hides the promo indefinitely', () async {
    for (int i = 0; i < 3; i++) {
      await service.incrementLessonCount();
    }
    await service.dismissForever();
    expect(service.shouldShowPromo(), isFalse);
  });

  test('an expired dismissedUntil no longer hides the promo', () async {
    for (int i = 0; i < 3; i++) {
      await service.incrementLessonCount();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'smart_promo_dismissed_until',
      DateTime(2020, 1, 1).toIso8601String(),
    );
    expect(service.shouldShowPromo(), isTrue);
  });

  test('lessonsUntilNextPromo clamps to zero', () async {
    for (int i = 0; i < 10; i++) {
      await service.incrementLessonCount();
    }
    expect(service.lessonsUntilNextPromo, 0);
  });

  test('recordPromoShown stores a last-shown timestamp', () async {
    await service.recordPromoShown();
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('smart_promo_last_shown');
    expect(stored, isNotNull);
    expect(DateTime.tryParse(stored!), isNotNull);
  });
}
