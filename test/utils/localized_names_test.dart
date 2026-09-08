import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/utils/localized_names.dart';

void main() {
  final l = lookupAppLocalizations(const Locale('es'));

  group('shopItemLocalizedName', () {
    const ids = [
      'focus_elixir',
      'xp_boost',
      'luck_boost',
      'sage_monocle',
      'time_warp',
      'titanium_shield',
      'phoenix_feather',
      'avatar_frame_neon',
      'avatar_frame_galaxy',
      'avatar_frame_dragon',
      'avatar_frame_crystal',
      'avatar_frame_skull',
      'title_storm_breaker',
      'title_cyber_sage',
      'title_shadow_hacker',
      'title_night_guardian',
      'title_digital_phoenix',
      'effect_digital_rain',
      'effect_fire_trail',
      'theme_blue',
      'theme_purple',
      'theme_dark_fire',
      'theme_cyber_neon',
    ];

    test('devuelve cadena localizada no vacia para cada item', () {
      for (final id in ids) {
        expect(shopItemLocalizedName(id, l), isNotEmpty, reason: id);
      }
    });

    test('devuelve el id como fallback para ids desconocidos', () {
      expect(shopItemLocalizedName('id_inexistente', l), 'id_inexistente');
    });
  });

  group('shopItemLocalizedDescription', () {
    const ids = [
      'focus_elixir',
      'xp_boost',
      'luck_boost',
      'sage_monocle',
      'time_warp',
      'titanium_shield',
      'phoenix_feather',
      'avatar_frame_neon',
      'avatar_frame_galaxy',
      'avatar_frame_dragon',
      'avatar_frame_crystal',
      'avatar_frame_skull',
      'title_storm_breaker',
      'title_cyber_sage',
      'title_shadow_hacker',
      'title_night_guardian',
      'title_digital_phoenix',
      'effect_digital_rain',
      'effect_fire_trail',
      'theme_blue',
      'theme_purple',
      'theme_dark_fire',
      'theme_cyber_neon',
    ];

    test('devuelve descripcion localizada no vacia para cada item', () {
      for (final id in ids) {
        expect(shopItemLocalizedDescription(id, l), isNotEmpty, reason: id);
      }
    });

    test('devuelve el id como fallback para ids desconocidos', () {
      expect(
        shopItemLocalizedDescription('id_inexistente', l),
        'id_inexistente',
      );
    });
  });

  group('missionLocalizedTitle', () {
    for (var i = 1; i <= 9; i++) {
      test('m$i devuelve titulo localizado', () {
        expect(missionLocalizedTitle('m$i', l), isNotEmpty);
      });
    }

    test('devuelve el id como fallback para misiones desconocidas', () {
      expect(missionLocalizedTitle('m99', l), 'm99');
    });
  });

  group('missionLocalizedDescription', () {
    for (var i = 1; i <= 9; i++) {
      test('m$i devuelve descripcion localizada', () {
        expect(missionLocalizedDescription('m$i', l), isNotEmpty);
      });
    }

    test('devuelve el id como fallback para misiones desconocidas', () {
      expect(missionLocalizedDescription('m99', l), 'm99');
    });
  });

  group('resolvePaymentError', () {
    test('mapea cada error conocido a su string localizado', () {
      final known = {
        'You must be signed in to donate': l.paymentErrorNotSignedIn,
        'Could not get session. Please sign in again.':
            l.paymentErrorSessionExpired,
        'Invalid product': l.paymentErrorInvalidProduct,
        'Could not start payment. Please try again.': l.paymentErrorStartFailed,
        'Could not register payment. Please try again.':
            l.paymentErrorRegisterFailed,
        'Payment expired. Please try again.': l.paymentErrorExpired,
        'Payment was cancelled or did not complete': l.paymentErrorCancelled,
      };
      known.forEach((code, expected) {
        expect(resolvePaymentError(code, l), expected);
      });
    });

    test('error null cae en paymentNotCompleted', () {
      expect(resolvePaymentError(null, l), l.paymentNotCompleted);
    });

    test('error desconocido se devuelve tal cual', () {
      expect(resolvePaymentError('otro error', l), 'otro error');
    });
  });
}
