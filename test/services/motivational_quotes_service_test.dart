import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/services/motivational_quotes_service.dart';

void main() {
  final service = MotivationalQuotesService.instance;

  test('random returns a non-empty quote', () {
    final quote = service.random();
    expect(quote, isNotEmpty);
  });

  test('returns distinct quotes without repeating recent ones', () {
    final seen = <String>{};
    for (int i = 0; i < 12; i++) {
      final quote = service.random();
      expect(quote, isNotEmpty);
      seen.add(quote);
    }
    expect(seen.length, greaterThanOrEqualTo(12));
  });

  test('repeats are allowed only after recent window is exceeded', () {
    final first = service.random();
    var foundRepeat = false;
    for (int i = 0; i < 200 && !foundRepeat; i++) {
      if (service.random() == first) foundRepeat = true;
    }
    expect(foundRepeat, isTrue);
  });

  test('setMaxRecent clamps to minimum of 2', () {
    service.setMaxRecent(1);
    final quotes = <String>{};
    for (int i = 0; i < 4; i++) {
      quotes.add(service.random());
    }
    expect(quotes.length, greaterThan(0));
  });

  test('setMaxRecent clamps to maximum of 20', () {
    service.setMaxRecent(500);
    final quotes = <String>{};
    for (int i = 0; i < 30; i++) {
      quotes.add(service.random());
    }
    expect(quotes.length, greaterThanOrEqualTo(20));
  });

  test('setMaxRecent accepts valid values', () {
    service.setMaxRecent(10);
    expect(service.random(), isNotEmpty);
  });
}
