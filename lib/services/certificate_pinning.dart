import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'app_logger.dart';

/// Certificate pinning for Firebase/Gemini infrastructure.
///
/// ## How it works
/// All real pins are configured by [ApiClient.init]. This class manages
/// the pin registry and validates certificates against configured pins.
///
/// ## Validation
/// - Placeholder pins (non-hex, non-base64, or wrong length) → BLOCKED
/// - Known hosts with valid pin → ALLOWED
/// - Known hosts with invalid pin → BLOCKED (enforce) or WARNED (log-only)
/// - Unknown hosts via [createHttpClient] → BLOCKED in enforce mode
class CertificatePinning {
  final AppLogger _logger = AppLogger();
  final Map<String, List<String>> _pins = {};
  bool _enforcePinning = true;

  static final CertificatePinning instance = CertificatePinning._();
  CertificatePinning._() {
    _initDefaultPins();
  }

  void _initDefaultPins() {
    // No default pins — all real pins are configured by ApiClient.init().
    // Placeholder pins MUST NOT be added here; validateConfiguration() will
    // reject builds that still contain them.
  }

  /// Load additional pins from a JSON configuration file (assets/cert_pins.json).
  /// Format: { "host": ["sha256/hash1", "sha256/hash2"] }
  Future<void> loadPinsFromConfig() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/cert_pins.json');
      final config = jsonDecode(jsonStr) as Map<String, dynamic>;
      for (final entry in config.entries) {
        if (entry.value is List) {
          final pins = entry.value.cast<String>();
          if (pins.isNotEmpty && !pins.any((p) => _isPlaceholderPin(p))) {
            _pins[entry.key] = pins;
          }
        }
      }
      _logger.info('CertificatePinning: loaded pins for ${config.keys.length} hosts from config');
    } catch (e) {
      _logger.warning('CertificatePinning: no cert_pins.json found, using default pins only');
    }
  }

  /// Set to false to log-only mode (no enforcement). Use only for debugging.
  void setEnforceMode({required bool enforce}) {
    _enforcePinning = enforce;
    if (!enforce) {
      _logger.warning('CertificatePinning: enforcement DISABLED (log-only mode)');
    }
  }

  void addPin(String host, String sha256Fingerprint) {
    _pins.putIfAbsent(host, () => []).add(sha256Fingerprint);
  }

  void addPins(String host, List<String> fingerprints) {
    _pins[host] = fingerprints;
  }

  bool hasPinsFor(String host) => _pins.containsKey(host);

  void clearPins(String host) => _pins.remove(host);

  Map<String, List<String>> get allPins => Map.unmodifiable(_pins);

  /// Returns true if the certificate is valid (pinned or no pins configured).
  /// In enforce mode, rejects unknown certs. In log-only mode, allows but warns.
  bool _validateCertificate(X509Certificate cert, String host) {
    if (!_pins.containsKey(host)) {
      // Unknown host: REJECT in enforce mode (fail-closed), warn in log-only mode
      if (_enforcePinning) {
        _logger.error('CertificatePinning: REJECTING unknown host $host — no pins configured (enforce mode)');
        return false;
      }
      _logger.warning('CertificatePinning: unknown host $host — no pins configured (log-only)');
      return true;
    }

    final digest = sha256.convert(cert.der);
    final fingerprint = 'sha256/${digest.toString()}';

    final hostPins = _pins[host];
    if (hostPins == null) return true;

    if (hostPins.contains(fingerprint)) return true;

    _logger.error('Certificate pinning FAILED for $host — possible MITM');

    if (hostPins.any((p) => _isPlaceholderPin(p))) {
      _logger.error(
        'CertificatePinning: BLOCKED connection to $host — placeholder pins detected. '
        'Run: openssl s_client -connect $host:443 </dev/null 2>/dev/null '
        '| openssl x509 -fingerprint -noout -sha256',
      );
      return false;
    }

    // Real pin mismatch: block in enforce mode
    if (_enforcePinning) {
      _logger.error(
        'CertificatePinning: BLOCKED $host — pin mismatch. '
        'Certificate may have been renewed. Update pins in assets/cert_pins.json.',
      );
      return false;
    }

    return false; // Even in log-only mode, reject invalid pins
  }

  HttpClient createHttpClient({String? host}) {
    final client = HttpClient();
    client.badCertificateCallback = (X509Certificate cert, String h, int port) {
      if (_pins.containsKey(h)) {
        return _validateCertificate(cert, h);
      }
      // Unknown host: block if enforce mode is on
      if (_enforcePinning) {
        _logger.error('CertificatePinning: BLOCKED unknown host $h — no pins configured');
        return false;
      }
      return true;
    };
    return client;
  }

  /// Validates that no placeholder pins remain. Call before release builds.
  bool validateConfiguration() {
    var valid = true;
    for (final entry in _pins.entries) {
      for (final pin in entry.value) {
        if (_isPlaceholderPin(pin)) {
          _logger.error(
            'CertificatePinning: placeholder pin found for ${entry.key}: $pin',
          );
          valid = false;
        }
      }
    }
    if (!valid) {
      _logger.error(
        'CertificatePinning: configuration INVALID — '
        'production builds will BLOCK connections to pinned hosts.',
      );
    }
    return valid;
  }

  static bool _isPlaceholderPin(String pin) {
    final hash = pin.replaceFirst('sha256/', '');
    if (hash.length != 64) return true;
    if (RegExp(r'^[0-9a-f]{64}$', caseSensitive: false).hasMatch(hash)) return false;
    if (RegExp(r'^[A-Za-z0-9+/]+=*$', caseSensitive: false).hasMatch(hash) &&
        hash.length == 44) {
      return false;
    }
    return true;
  }
}
