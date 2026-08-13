import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/services/firestore_service.dart';

void main() {
  group('FirestoreService Security', () {
    group('sanitize', () {
      test('removes angle brackets', () async {
        final result = await FirestoreService.sanitize(
          'test<script>alert</script>',
        );
        expect(result, isNot(contains('<')));
        expect(result, isNot(contains('>')));
        expect(result, isNot(contains('"')));
        expect(result, isNot(contains("'")));
      });

      test('removes quotes', () async {
        final result = await FirestoreService.sanitize(
          'say "hello" and \'bye\'',
        );
        expect(result, isNot(contains('"')));
        expect(result, isNot(contains("'")));
      });

      test('trims whitespace', () async {
        final result = await FirestoreService.sanitize('  test  ');
        expect(result, equals('test'));
      });

      test('handles empty string', () async {
        final result = await FirestoreService.sanitize('');
        expect(result, isEmpty);
      });
    });

    group('_allowedUpdateFields', () {
      test('contains expected safe fields', () {
        expect(FirestoreService.allowedUpdateFields, contains('firstName'));
        expect(FirestoreService.allowedUpdateFields, contains('email'));
        expect(FirestoreService.allowedUpdateFields, contains('age'));
        expect(FirestoreService.allowedUpdateFields, contains('photoUrl'));
      });

      test('does not contain dangerous fields', () {
        expect(FirestoreService.allowedUpdateFields, isNot(contains('role')));
        expect(
          FirestoreService.allowedUpdateFields,
          isNot(contains('isAdmin')),
        );
        expect(
          FirestoreService.allowedUpdateFields,
          isNot(contains('password')),
        );
        expect(FirestoreService.allowedUpdateFields, isNot(contains('uid')));
      });
    });

    group('age validation', () {
      test('clamps age to minimum 10', () {
        final result = FirestoreService.clampAge(5);
        expect(result, equals(13));
      });

      test('clamps age to maximum 120', () {
        final result = FirestoreService.clampAge(200);
        expect(result, equals(120));
      });

      test('accepts valid age', () {
        final result = FirestoreService.clampAge(25);
        expect(result, equals(25));
      });
    });
  });
}
