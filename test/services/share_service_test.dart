import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sagen/services/analytics_service.dart';
import 'package:sagen/services/share_service.dart';
import 'package:share_plus/share_plus.dart';

class _MockAnalytics extends Mock implements AnalyticsService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'getTemporaryDirectory' ||
              call.method == 'getTemporaryPath') {
            return Directory.systemTemp.createTempSync().path;
          }
          return null;
        });
  });

  group('ShareService', () {
    test('is a singleton', () {
      final a = ShareService.instance;
      final b = ShareService.instance;
      expect(a, same(b));
    });

    test('shareImage returns false when platform unavailable', () async {
      final service = ShareService.instance;
      final result = await service.shareImage(Uint8List(0), text: 'test');
      expect(result, false);
    });

    group('with injected share function', () {
      test('shareImage writes the file, shares it, and cleans up', () async {
        ShareParams? shared;
        final analytics = _MockAnalytics();
        when(() => analytics.trackFlexCardShared(any())).thenReturn(null);
        final service = ShareService.test(
          analytics: analytics,
          shareOverride: (params) async {
            shared = params;
          },
        );

        final result = await service.shareImage(
          Uint8List.fromList([1, 2, 3]),
          text: 'hello',
          source: 'profile',
        );

        expect(result, isTrue);
        expect(shared, isNotNull);
        expect(shared!.files, hasLength(1));
        expect(shared!.files!.single.name, contains('sagen_flex_card_'));
        expect(shared!.files!.single.path, endsWith('.png'));
        expect(shared!.text, 'hello');
        expect(File(shared!.files!.single.path).existsSync(), isFalse);
        verify(() => analytics.trackFlexCardShared('profile')).called(1);
      });

      test(
        'shareImage returns false and cleans up when sharing fails',
        () async {
          final service = ShareService.test(
            shareOverride: (_) async => throw Exception('share rejected'),
          );

          final result = await service.shareImage(
            Uint8List.fromList([1]),
            text: 'hello',
          );

          expect(result, isFalse);
        },
      );

      test('shareText shares text and tracks the source', () async {
        ShareParams? shared;
        final analytics = _MockAnalytics();
        when(() => analytics.trackFlexCardShared(any())).thenReturn(null);
        final service = ShareService.test(
          analytics: analytics,
          shareOverride: (params) async {
            shared = params;
          },
        );

        final result = await service.shareText('sharing!', source: 'store');

        expect(result, isTrue);
        expect(shared!.text, 'sharing!');
        expect(shared!.files, isNull);
        verify(() => analytics.trackFlexCardShared('store')).called(1);
      });

      test('shareText returns false when sharing fails', () async {
        final service = ShareService.test(
          shareOverride: (_) async => throw Exception('rejected'),
        );
        expect(await service.shareText('text'), isFalse);
      });
    });
  });
}
