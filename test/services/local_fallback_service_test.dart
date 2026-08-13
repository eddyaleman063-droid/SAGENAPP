import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/models/chat_message.dart';
import 'package:sagen/services/local_fallback_service.dart';

void main() {
  final service = LocalFallbackService();

  ChatMessage userMsg(String text) =>
      ChatMessage(role: ChatRole.user, text: text, time: DateTime(2026, 1, 1));

  ChatMessage assistantMsg(String text) => ChatMessage(
    role: ChatRole.assistant,
    text: text,
    time: DateTime(2026, 1, 1),
  );

  group('LocalFallbackService — availability', () {
    test('isAvailable is always true', () {
      expect(service.isAvailable, isTrue);
    });

    test('dispose does nothing', () {
      expect(service.dispose, returnsNormally);
    });
  });

  group('LocalFallbackService — greetings', () {
    test('es hola', () async {
      final r = await service.generate([userMsg('hola sage')]);
      const greetings = [
        '¡Hola! Soy Sage, tu tutor de ciberseguridad. ¿Cómo puedo ayudarte hoy? Puedo explicarte sobre phishing, contraseñas seguras, privacidad en redes sociales, malware y mucho más. ¿Qué te gustaría aprender?',
        '¡Buenas! Me alegra verte por aquí. ¿Listo para aprender algo nuevo sobre seguridad digital? Puedo ayudarte con cualquier pregunta que tengas.',
        '¡Hola! Soy Sage, y estoy aquí para que aprendamos juntos a protegerte en línea. ¿Por dónde te gustaría empezar?',
      ];
      expect(greetings, contains(r));
    });

    test('en hello', () async {
      final r = await service.generate([userMsg('hello there')]);
      expect(r, isNotEmpty);
    });
  });

  group('LocalFallbackService — thank you', () {
    test('gracias response', () async {
      final r = await service.generate([userMsg('muchas gracias')]);
      expect(r, isNotEmpty);
      expect(r, isNot(contains('Sage, tu tutor')));
    });
  });

  group('LocalFallbackService — goodbye', () {
    test('adios response', () async {
      final r = await service.generate([userMsg('adios hasta luego')]);
      expect(r, isNotEmpty);
    });
  });

  group('LocalFallbackService — topics', () {
    test('phishing', () async {
      final r = await service.generate([userMsg('explicame phishing')]);
      expect(r, contains('phishing'));
    });

    test('password with diacritics', () async {
      final r = await service.generate([userMsg('contraseña segura')]);
      expect(r, isNotEmpty);
      expect(r, isNot(contains('phishing es cuando')));
    });

    test('password without diacritics', () async {
      final r = await service.generate([userMsg('password segura')]);
      expect(r, isNotEmpty);
    });

    test('social media privacy', () async {
      final r = await service.generate([
        userMsg('privacidad en redes sociales'),
      ]);
      expect(r, isNotEmpty);
    });

    test('wifi security', () async {
      final r = await service.generate([userMsg('wifi público')]);
      expect(r, isNotEmpty);
    });

    test('malware', () async {
      final r = await service.generate([userMsg('que es malware')]);
      expect(r, contains('malware'));
    });

    test('identity theft', () async {
      final r = await service.generate([userMsg('robo de identidad')]);
      expect(r, isNotEmpty);
    });

    test('online scams', () async {
      final r = await service.generate([userMsg('es una estafa')]);
      expect(r, isNotEmpty);
    });

    test('digital footprint', () async {
      final r = await service.generate([userMsg('huella digital')]);
      expect(r, isNotEmpty);
    });

    test('cyberbullying', () async {
      final r = await service.generate([userMsg('acoso escolar')]);
      expect(r, isNotEmpty);
    });

    test('safe browsing', () async {
      final r = await service.generate([userMsg('navegacion segura')]);
      expect(r, isNotEmpty);
    });
  });

  group('LocalFallbackService — fallbacks', () {
    test('unknown message returns a default response', () async {
      final r = await service.generate([userMsg('zzz quark soup')]);
      expect(r, isNotEmpty);
    });

    test('empty messages list returns a default response', () async {
      final r = await service.generate([]);
      expect(r, isNotEmpty);
    });

    test('only assistant messages returns a default response', () async {
      final r = await service.generate([assistantMsg('hola')]);
      expect(r, isNotEmpty);
    });

    test('user context params are accepted', () async {
      final r = await service.generate(
        [userMsg('hola')],
        userName: 'Ana',
        userLevel: 5,
        currentStreak: 10,
        weakTopics: const ['phishing'],
      );
      expect(r, isNotEmpty);
    });
  });

  group('LocalFallbackService — streaming', () {
    test('generateStream yields the full response char by char', () async {
      final stream = service.generateStream([userMsg('hola')]);
      var count = 0;
      var text = '';
      await for (final chunk in stream) {
        count++;
        text += chunk;
      }
      expect(count, greaterThan(0));
      expect(text, isNotEmpty);
      expect(count, text.length);
    });
  });
}
