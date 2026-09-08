import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/services/deep_link_service.dart';

void main() {
  final service = DeepLinkService.instance;

  group('DeepLinkService.handleDeepLink', () {
    test('profile con uid valido (28 chars) devuelve ProfileDeepLink', () {
      const uid = 'AbCdEfGhIjKlMnOpQrStUvWxYz12';
      final action = service.handleDeepLink(
        Uri.parse('sagen://profile?uid=$uid'),
      );
      expect(action, isA<ProfileDeepLink>());
      expect((action as ProfileDeepLink).uid, uid);
    });

    test('profile con uid invalido devuelve UnknownDeepLink', () {
      final action = service.handleDeepLink(
        Uri.parse('sagen://profile?uid=short'),
      );
      expect(action, isA<UnknownDeepLink>());
    });

    test('profile sin uid devuelve UnknownDeepLink', () {
      final action = service.handleDeepLink(Uri.parse('sagen://profile'));
      expect(action, isA<UnknownDeepLink>());
    });

    test('ranking devuelve RankingDeepLink', () {
      final action = service.handleDeepLink(Uri.parse('sagen://ranking'));
      expect(action, isA<RankingDeepLink>());
    });

    test('lesson con stageId devuelve LessonDeepLink', () {
      final action = service.handleDeepLink(
        Uri.parse('sagen://lesson?stageId=ac_st1'),
      );
      expect(action, isA<LessonDeepLink>());
      expect((action as LessonDeepLink).stageId, 'ac_st1');
    });

    test('lesson sin stageId devuelve UnknownDeepLink', () {
      final action = service.handleDeepLink(Uri.parse('sagen://lesson'));
      expect(action, isA<UnknownDeepLink>());
    });

    test('payment/success sin amount devuelve PaymentSuccessDeepLink null', () {
      final action = service.handleDeepLink(
        Uri.parse('sagen://payment/success?external_reference=ABC'),
      );
      expect(action, isA<PaymentSuccessDeepLink>());
      final p = action as PaymentSuccessDeepLink;
      expect(p.externalRef, 'ABC');
      expect(p.donationAmount, isNull);
    });

    test('payment/success con amount devuelve donacion parseada', () {
      final action = service.handleDeepLink(
        Uri.parse('sagen://payment/success?amount=9.90&external_reference=X|9.9|p'),
      );
      expect(action, isA<PaymentSuccessDeepLink>());
      final p = action as PaymentSuccessDeepLink;
      expect(p.donationAmount, 9.9);
      expect(p.externalRef, 'X|9.9|p');
    });

    test('payment/failure devuelve PaymentFailureDeepLink', () {
      expect(
        service.handleDeepLink(Uri.parse('sagen://payment/failure')),
        isA<PaymentFailureDeepLink>(),
      );
    });

    test('payment/pending devuelve PaymentPendingDeepLink', () {
      expect(
        service.handleDeepLink(Uri.parse('sagen://payment/pending')),
        isA<PaymentPendingDeepLink>(),
      );
    });

    test('payment con path desconocido devuelve UnknownDeepLink', () {
      expect(
        service.handleDeepLink(Uri.parse('sagen://payment/other')),
        isA<UnknownDeepLink>(),
      );
    });

    test('host desconocido devuelve UnknownDeepLink', () {
      final action = service.handleDeepLink(Uri.parse('sagen://otro/ruta'));
      expect(action, isA<UnknownDeepLink>());
      expect((action as UnknownDeepLink).uri, Uri.parse('sagen://otro/ruta'));
    });
  });
}