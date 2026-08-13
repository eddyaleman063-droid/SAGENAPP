import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/config/firestore_field_config.dart';

void main() {
  group('FirestoreFieldConfig', () {
    test('isServerOnlyField returns true for economic fields', () {
      expect(FirestoreFieldConfig.isServerOnlyField('learning_gems'), isTrue);
      expect(
        FirestoreFieldConfig.isServerOnlyField('learning_total_xp'),
        isTrue,
      );
      expect(FirestoreFieldConfig.isServerOnlyField('streakCurrent'), isTrue);
    });

    test('isServerOnlyField returns false for profile fields', () {
      expect(FirestoreFieldConfig.isServerOnlyField('firstName'), isFalse);
      expect(FirestoreFieldConfig.isServerOnlyField('email'), isFalse);
    });

    test('isProfileField returns true for profile fields', () {
      expect(FirestoreFieldConfig.isProfileField('firstName'), isTrue);
      expect(FirestoreFieldConfig.isProfileField('email'), isTrue);
      expect(FirestoreFieldConfig.isProfileField('age'), isTrue);
    });

    test('isProfileField returns false for server-only fields', () {
      expect(FirestoreFieldConfig.isProfileField('learning_gems'), isFalse);
    });

    test('validateFieldType passes for correct types', () {
      expect(
        FirestoreFieldConfig.validateFieldType('firstName', 'test'),
        isTrue,
      );
      expect(FirestoreFieldConfig.validateFieldType('age', 25), isTrue);
      expect(
        FirestoreFieldConfig.validateFieldType('onboardingCompleted', true),
        isTrue,
      );
    });

    test('validateFieldType fails for wrong types', () {
      expect(FirestoreFieldConfig.validateFieldType('firstName', 123), isFalse);
      expect(FirestoreFieldConfig.validateFieldType('age', 'twenty'), isFalse);
    });

    test('validateFieldType passes for unknown fields', () {
      expect(
        FirestoreFieldConfig.validateFieldType('unknownField', 'anything'),
        isTrue,
      );
    });

    test('validateStringLength passes within limit', () {
      expect(
        FirestoreFieldConfig.validateStringLength('firstName', 'John'),
        isTrue,
      );
    });

    test('validateStringLength fails over limit', () {
      expect(
        FirestoreFieldConfig.validateStringLength('firstName', 'A' * 51),
        isFalse,
      );
    });

    test('validateStringLength passes for unknown fields', () {
      expect(
        FirestoreFieldConfig.validateStringLength('unknown', 'any'),
        isTrue,
      );
    });

    test('validateIntRange passes within range', () {
      expect(FirestoreFieldConfig.validateIntRange('age', 25), isTrue);
      expect(FirestoreFieldConfig.validateIntRange('age', 13), isTrue);
      expect(FirestoreFieldConfig.validateIntRange('age', 120), isTrue);
    });

    test('validateIntRange fails out of range', () {
      expect(FirestoreFieldConfig.validateIntRange('age', 12), isFalse);
      expect(FirestoreFieldConfig.validateIntRange('age', 121), isFalse);
    });

    test('validateIntRange passes for unknown fields', () {
      expect(FirestoreFieldConfig.validateIntRange('unknown', 999), isTrue);
    });

    test('syncKeys contains all expected profile keys', () {
      expect(FirestoreFieldConfig.syncKeys, contains('firstName'));
      expect(FirestoreFieldConfig.syncKeys, contains('email'));
      expect(FirestoreFieldConfig.syncKeys, contains('motivation'));
      expect(FirestoreFieldConfig.syncKeys, contains('updatedAt'));
    });

    test('spToFirestoreMapping keys are subset of profileFields', () {
      for (final key in FirestoreFieldConfig.spToFirestoreMapping.keys) {
        expect(FirestoreFieldConfig.profileFields, contains(key));
      }
    });

    test('serverOnlyFields does not overlap with profileFields', () {
      final overlap = FirestoreFieldConfig.serverOnlyFields.intersection(
        FirestoreFieldConfig.profileFields,
      );
      expect(overlap, isEmpty);
    });

    test('profileFieldTypes covers all profile fields', () {
      for (final field in FirestoreFieldConfig.profileFields) {
        expect(
          FirestoreFieldConfig.profileFieldTypes,
          contains(field),
          reason: 'profileFieldTypes missing type for $field',
        );
      }
    });

    test('stringFieldMaxLengths are positive', () {
      for (final entry in FirestoreFieldConfig.stringFieldMaxLengths.entries) {
        expect(
          entry.value,
          greaterThan(0),
          reason: '${entry.key} has non-positive max length',
        );
      }
    });

    test('intFieldRanges have min <= max', () {
      for (final entry in FirestoreFieldConfig.intFieldRanges.entries) {
        expect(
          entry.value.$1,
          lessThanOrEqualTo(entry.value.$2),
          reason: '${entry.key} has min > max',
        );
      }
    });

    test('all serverOnlyFields are covered by syncKeys exclusion', () {
      for (final field in FirestoreFieldConfig.serverOnlyFields) {
        expect(
          FirestoreFieldConfig.syncKeys,
          isNot(contains(field)),
          reason: 'server-only field $field should NOT be in syncKeys',
        );
      }
    });
  });
}
