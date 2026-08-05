import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/utils/map_utils.dart';

void main() {
  group('parseStringMap', () {
    test('returns empty map for empty string', () {
      expect(parseStringMap(''), isEmpty);
    });

    test('parses single entry', () {
      expect(parseStringMap('key:42'), {'key': 42});
    });

    test('parses multiple entries', () {
      expect(parseStringMap('a:1,b:2,c:3'), {'a': 1, 'b': 2, 'c': 3});
    });

    test('handles non-numeric values as 0', () {
      expect(parseStringMap('key:abc'), {'key': 0});
    });

    test('handles entry without colon', () {
      expect(parseStringMap('badentry'), isEmpty);
    });

    test('handles trailing comma', () {
      expect(parseStringMap('a:1,'), {'a': 1});
    });

    test('handles leading comma', () {
      expect(parseStringMap(',a:1'), {'a': 1});
    });

    test('handles empty entries between commas', () {
      expect(parseStringMap('a:1,,b:2'), {'a': 1, 'b': 2});
    });

    test('handles negative values', () {
      expect(parseStringMap('key:-5'), {'key': -5});
    });

    test('handles zero value', () {
      expect(parseStringMap('key:0'), {'key': 0});
    });

    test('keys with colons are dropped (split on all colons)', () {
      expect(parseStringMap('a:b:5'), isEmpty);
    });

    test('handles large numbers', () {
      expect(parseStringMap('key:999999'), {'key': 999999});
    });
  });

  group('encodeStringMap', () {
    test('returns empty string for empty map', () {
      expect(encodeStringMap({}), '');
    });

    test('encodes single entry', () {
      expect(encodeStringMap({'key': 42}), 'key:42');
    });

    test('encodes multiple entries', () {
      final result = encodeStringMap({'a': 1, 'b': 2, 'c': 3});
      expect(result, contains('a:1'));
      expect(result, contains('b:2'));
      expect(result, contains('c:3'));
      expect(result.split(',').length, 3);
    });

    test('handles zero value', () {
      expect(encodeStringMap({'key': 0}), 'key:0');
    });

    test('handles negative value', () {
      expect(encodeStringMap({'key': -5}), 'key:-5');
    });

    test('roundtrip preserves data', () {
      final original = {'x': 10, 'y': 20, 'z': 30};
      final encoded = encodeStringMap(original);
      final decoded = parseStringMap(encoded);
      expect(decoded, original);
    });

    test('roundtrip with empty map', () {
      final encoded = encodeStringMap(<String, int>{});
      final decoded = parseStringMap(encoded);
      expect(decoded, isEmpty);
    });
  });
}
