import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/services/certificate_pinning.dart';

void main() {
  late CertificatePinning pinning;

  setUp(() {
    pinning = CertificatePinning.test();
  });

  String fingerprintFor(String secret) {
    return 'sha256/${sha256.convert(utf8.encode(secret)).toString()}';
  }

  test('hasPinsFor is false until pins are added', () {
    expect(pinning.hasPinsFor('api.example.com'), isFalse);
  });

  test('addPin appends a pin and clearPins removes the host', () {
    pinning.addPin('a.com', fingerprintFor('a'));
    expect(pinning.allPins['a.com'], [fingerprintFor('a')]);
    expect(pinning.hasPinsFor('a.com'), isTrue);

    pinning.clearPins('a.com');
    expect(pinning.hasPinsFor('a.com'), isFalse);
  });

  test('addPins replaces the whole pin list for the host', () {
    pinning.addPins('a.com', [fingerprintFor('a')]);
    pinning.addPins('a.com', [fingerprintFor('b'), fingerprintFor('c')]);
    expect(pinning.allPins['a.com'], [
      fingerprintFor('b'),
      fingerprintFor('c'),
    ]);
  });

  test('allPins is an unmodifiable view', () {
    pinning.addPin('a.com', fingerprintFor('a'));
    expect(() => pinning.allPins['a.com'] = [], throwsUnsupportedError);
  });

  group('fingerprint validation', () {
    test('allows a known host with a matching pin', () {
      pinning.addPin('api.example.com', fingerprintFor('secret1'));
      expect(
        pinning.checkFingerprintForTest(
          'api.example.com',
          fingerprintFor('secret1'),
        ),
        isTrue,
      );
    });

    test('blocks a mismatched fingerprint against an empty pin list', () {
      pinning.addPins('api.example.com', <String>[]);
      expect(
        pinning.checkFingerprintForTest('api.example.com', fingerprintFor('x')),
        isFalse,
      );
    });

    test('rejects a mismatched pin in enforce mode', () {
      pinning.addPin('api.example.com', fingerprintFor('secret1'));
      expect(
        pinning.checkFingerprintForTest(
          'api.example.com',
          fingerprintFor('secret2'),
        ),
        isFalse,
      );
    });

    test('rejects a pin mismatch against a placeholder pin', () {
      pinning.addPin('api.example.com', 'sha256/placeholder-not-a-hash!!');
      expect(
        pinning.checkFingerprintForTest(
          'api.example.com',
          fingerprintFor('anything'),
        ),
        isFalse,
      );
    });

    test('rejects unknown hosts in enforce mode', () {
      expect(
        pinning.checkFingerprintForTest('unknown.com', fingerprintFor('x')),
        isFalse,
      );
    });

    test('allows unknown hosts in log-only mode', () {
      pinning.setEnforceMode(enforce: false);
      expect(
        pinning.checkFingerprintForTest('unknown.com', fingerprintFor('x')),
        isTrue,
      );
    });
  });

  group('placeholder detection', () {
    test('validateConfiguration passes with hex and base64 pins', () {
      pinning.addPins('a.com', [
        'sha256/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
        "sha256/${'A' * 43}=",
      ]);
      expect(pinning.validateConfiguration(), isTrue);
    });

    test('validateConfiguration fails with a placeholder pin', () {
      pinning.addPins('a.com', ['sha256/NOT_A_REAL_PIN_AT_ALL']);
      expect(pinning.validateConfiguration(), isFalse);
    });
  });
}
