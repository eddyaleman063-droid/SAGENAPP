import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/services/firestore_service.dart';

void main() {
  group('FirestoreService.sanitize', () {
    test('removes HTML tags', () async {
      expect(await FirestoreService.sanitize('<script>alert(1)</script>'), 'alert(1)');
    });

    test('removes javascript: protocol', () async {
      expect(await FirestoreService.sanitize('javascript:void(0)'), 'void(0)');
    });

    test('removes event handlers', () async {
      expect(await FirestoreService.sanitize('onclick=alert(1)'), 'alert(1)');
    });

    test('removes data URIs', () async {
      expect(
        await FirestoreService.sanitize('data:text/html,<h1>hi</h1>'),
        'text&#x2F;html,hi',
      );
    });

    test('removes base64 content', () async {
      expect(await FirestoreService.sanitize('base64,SGVsbG8='), 'SGVsbG8=');
    });

    test('escapes ampersand and quotes', () async {
      final result = await FirestoreService.sanitize('a&b"c\'d');
      expect(result, contains('&amp;'));
      expect(result, contains('&quot;'));
      expect(result, contains('&#x27;'));
    });

    test('removes control characters', () async {
      expect(await FirestoreService.sanitize('hello\x00world'), 'helloworld');
    });

    test('replaces multiline with space', () async {
      expect(await FirestoreService.sanitize('line1\nline2\r\nline3'), 'line1 line2 line3');
    });

    test('truncates to 100 characters', () async {
      final long = 'a' * 200;
      expect((await FirestoreService.sanitize(long)).length, 100);
    });

    test('trims whitespace', () async {
      expect(await FirestoreService.sanitize('  hello  '), 'hello');
    });

    test('handles empty string', () async {
      expect(await FirestoreService.sanitize(''), '');
    });

    test('blocks javascript URLs', () async {
      expect(await FirestoreService.sanitize('javascript:alert(1)'), 'alert(1)');
    });
  });

  group('FirestoreService.sanitizeUrl', () {
    test('returns valid HTTP URL', () {
      expect(FirestoreService.sanitizeUrl('https://example.com'), 'https://example.com');
    });

    test('returns valid FTP URL', () {
      expect(FirestoreService.sanitizeUrl('ftp://files.example.com'), 'ftp://files.example.com');
    });

    test('blocks javascript: URL', () {
      expect(FirestoreService.sanitizeUrl('javascript:alert(1)'), '');
    });

    test('blocks non-URL strings', () {
      expect(FirestoreService.sanitizeUrl('not a url'), '');
    });

    test('trims whitespace', () {
      expect(FirestoreService.sanitizeUrl('  https://example.com  '), 'https://example.com');
    });
  });

  group('FirestoreService.clampAge', () {
    test('clamps below minimum to 13', () {
      expect(FirestoreService.clampAge(5), 13);
    });

    test('clamps above maximum to 120', () {
      expect(FirestoreService.clampAge(200), 120);
    });

    test('allows valid age', () {
      expect(FirestoreService.clampAge(25), 25);
    });

    test('allows boundary values', () {
      expect(FirestoreService.clampAge(13), 13);
      expect(FirestoreService.clampAge(120), 120);
    });
  });

  group('FirestoreService.allowedUpdateFields', () {
    test('contains profile fields', () {
      expect(FirestoreService.allowedUpdateFields, contains('firstName'));
      expect(FirestoreService.allowedUpdateFields, contains('lastName'));
      expect(FirestoreService.allowedUpdateFields, contains('email'));
    });

    test('does not contain economic fields', () {
      expect(FirestoreService.allowedUpdateFields, isNot(contains('learning_gems')));
      expect(FirestoreService.allowedUpdateFields, isNot(contains('learning_total_xp')));
    });
  });
}
