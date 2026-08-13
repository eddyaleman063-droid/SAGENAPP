import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/router/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AppRouter', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [prefsProvider.overrideWithValue(prefs)],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('routerProvider creates a valid GoRouter', () {
      final router = container.read(routerProvider);
      expect(router, isNotNull);
    });

    test('routerProvider returns same instance on repeated reads', () {
      final router1 = container.read(routerProvider);
      final router2 = container.read(routerProvider);
      expect(router1, same(router2));
    });
  });
}
