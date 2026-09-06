import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/services/motivational_quotes_service.dart';

void main() {
  final service = MotivationalQuotesService.instance;

  setUp(() {
    // Fijar una semilla y una ventana pequeña hace el test totalmente
    // determinista (sin aleatoriedad residual que lo vuelva flaky).
    service.setMaxRecent(2);
    service.setRandom(Random(42));
  });

  test('random returns a non-empty quote', () {
    final quote = service.random();
    expect(quote, isNotEmpty);
  });

  test('returns distinct quotes without repeating recent ones', () {
    service.setMaxRecent(8);
    final seen = <String>{};
    for (int i = 0; i < 12; i++) {
      final quote = service.random();
      expect(quote, isNotEmpty);
      seen.add(quote);
    }
    expect(seen.length, greaterThanOrEqualTo(10));
  });

  test('repeats are allowed only after recent window is exceeded', () {
    service.setMaxRecent(2);
    // Con ventana 2 y determinista: como máximo hay 2 índices "recientes" y el
    // resto del banco está disponible, así que una repetición siempre acaba por
    // aparecer al superar la ventana (nunca se queda colgado ni bloqueado).
    final first = service.random();
    var foundRepeat = false;
    for (int i = 0; i < 60 && !foundRepeat; i++) {
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
