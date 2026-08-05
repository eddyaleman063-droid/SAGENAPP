import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/services/question_bank.dart';

void main() {
  late QuestionBank qb;

  setUp(() {
    qb = QuestionBank.instance;
  });

  group('QuestionBank', () {
    test('singleton returns same instance', () {
      expect(QuestionBank.instance, same(qb));
    });

    group('getQuestionsForLesson', () {
      test('returns empty list when no DB data (no hardcoded fallback)', () async {
        final result = await qb.getQuestionsForLesson('unknown_stage', 'unknown_lesson', count: 10);
        expect(result, isEmpty);
      });
    });

    group('getById', () {
      test('returns null for unknown id', () async {
        final result = await qb.getById('no_such_id');
        expect(result, isNull);
      });
    });
  });
}
