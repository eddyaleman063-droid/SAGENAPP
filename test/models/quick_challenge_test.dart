import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/models/quick_challenge.dart';

void main() {
  final es = lookupAppLocalizations(const Locale('es'));
  final en = lookupAppLocalizations(const Locale('en'));

  group('QuickChallengeType', () {
    test('has five challenge types', () {
      expect(QuickChallengeType.values, hasLength(5));
    });

    test('localizedLabel maps every type in Spanish', () {
      expect(QuickChallengeType.trueFalse.localizedLabel(es), es.quickChallengeTrueFalse);
      expect(QuickChallengeType.detectRisk.localizedLabel(es), es.quickChallengeDetectRisk);
      expect(QuickChallengeType.safePassword.localizedLabel(es), es.quickChallengeSafePassword);
      expect(
          QuickChallengeType.whatWouldYouDo.localizedLabel(es),
          es.quickChallengeWhatWouldYouDo);
      expect(QuickChallengeType.detectPhishing.localizedLabel(es),
          es.quickChallengeDetectPhishing);
    });

    test('localizedLabel maps every type in English', () {
      expect(QuickChallengeType.trueFalse.localizedLabel(en), en.quickChallengeTrueFalse);
      expect(QuickChallengeType.detectRisk.localizedLabel(en), en.quickChallengeDetectRisk);
      expect(QuickChallengeType.safePassword.localizedLabel(en), en.quickChallengeSafePassword);
      expect(
          QuickChallengeType.whatWouldYouDo.localizedLabel(en),
          en.quickChallengeWhatWouldYouDo);
      expect(QuickChallengeType.detectPhishing.localizedLabel(en),
          en.quickChallengeDetectPhishing);
    });

    test('labels differ between locales', () {
      expect(QuickChallengeType.trueFalse.localizedLabel(es),
          isNot(QuickChallengeType.trueFalse.localizedLabel(en)));
    });
  });

  group('QuickChallenge', () {
    const challenge = QuickChallenge(
      id: 'qc-1',
      type: QuickChallengeType.trueFalse,
      question: '¿Es seguro?',
      scenario: 'Recibes un correo del banco',
      options: ['Sí', 'No'],
      correctIndex: 1,
      explanation: 'Porque verifica la URL',
      consequenceCorrect: 'Bien hecho',
      consequenceWrong: 'Cuidado',
      xpReward: 20,
    );

    test('defaults apply when omitted', () {
      const minimal = QuickChallenge(
        id: 'qc-2',
        type: QuickChallengeType.detectPhishing,
        question: 'q',
        scenario: 's',
        options: ['a', 'b'],
        correctIndex: 0,
        explanation: 'e',
      );
      expect(minimal.consequenceCorrect, '');
      expect(minimal.consequenceWrong, '');
      expect(minimal.xpReward, 15);
    });

    test('isCorrectIndexValid checks bounds', () {
      expect(challenge.isCorrectIndexValid, isTrue);
      const negative = QuickChallenge(
        id: 'q',
        type: QuickChallengeType.trueFalse,
        question: 'q',
        scenario: 's',
        options: ['a', 'b'],
        correctIndex: -1,
        explanation: 'e',
      );
      expect(negative.isCorrectIndexValid, isFalse);
      const outOfRange = QuickChallenge(
        id: 'q',
        type: QuickChallengeType.trueFalse,
        question: 'q',
        scenario: 's',
        options: ['a', 'b'],
        correctIndex: 2,
        explanation: 'e',
      );
      expect(outOfRange.isCorrectIndexValid, isFalse);
    });

    test('fromJson roundtrip preserves fields', () {
      final json = {
        'id': 'qc-3',
        'type': 'detectRisk',
        'question': '¿Qué harías?',
        'scenario': 'Un enlace sospechoso',
        'options': ['Abrir', 'Ignorar', 'Reportar'],
        'correctIndex': 2,
        'explanation': 'Reportar protege a todos',
        'consequenceCorrect': 'Correcto',
        'consequenceWrong': 'Incorrecto',
        'xpReward': 30,
      };
      final parsed = QuickChallenge.fromJson(json);
      expect(parsed.id, 'qc-3');
      expect(parsed.type, QuickChallengeType.detectRisk);
      expect(parsed.question, '¿Qué harías?');
      expect(parsed.scenario, 'Un enlace sospechoso');
      expect(parsed.options, ['Abrir', 'Ignorar', 'Reportar']);
      expect(parsed.correctIndex, 2);
      expect(parsed.explanation, 'Reportar protege a todos');
      expect(parsed.consequenceCorrect, 'Correcto');
      expect(parsed.consequenceWrong, 'Incorrecto');
      expect(parsed.xpReward, 30);
      expect(parsed.isCorrectIndexValid, isTrue);
    });

    test('fromJson applies defaults for missing optional fields', () {
      final json = {
        'id': 'qc-4',
        'type': 'safePassword',
        'question': 'q',
        'scenario': 's',
        'options': ['a', 'b', 'c'],
        'correctIndex': 1,
        'explanation': 'e',
      };
      final parsed = QuickChallenge.fromJson(json);
      expect(parsed.consequenceCorrect, '');
      expect(parsed.consequenceWrong, '');
      expect(parsed.xpReward, 15);
    });

    test('copyWith replaces fields', () {
      final updated = challenge.copyWith(correctIndex: 0, xpReward: 25);
      expect(updated.correctIndex, 0);
      expect(updated.xpReward, 25);
      expect(updated.id, challenge.id);
      expect(updated.options, challenge.options);
    });
  });
}
