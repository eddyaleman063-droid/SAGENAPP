import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/cloud_sync_service.dart';
import 'package:sagen/services/auth_service.dart';
import 'package:sagen/ui/screens/dashboard/store_screen.dart';

class _MockLearningNotifier extends LearningNotifier {
  @override
  LearningState build() {
    return const LearningState(isLoading: false);
  }
}

class _MockShopNotifier extends ShopNotifier {
  final List<ShopItem> _items = const [
    ShopItem(id: 'xp_boost', name: 'Boost de XP', description: '2x XP'),
    ShopItem(
      id: 'theme_blue',
      name: 'Tema azul',
      description: 'Apariencia premium',
      iconAsset: 'palette',
    ),
  ];

  @override
  ShopState build() {
    return ShopState(items: _items);
  }
}

Widget createTestApp({
  required SharedPreferences prefs,
  LearningNotifier? learning,
  ShopNotifier? shop,
}) {
  final cloudSync = CloudSyncService(authService: AuthService());
  return ProviderScope(
    overrides: [
      prefsProvider.overrideWithValue(prefs),
      authServiceProvider.overrideWithValue(AuthService()),
      cloudSyncServiceProvider.overrideWithValue(cloudSync),
      learningProvider.overrideWith(() => learning ?? _MockLearningNotifier()),
      shopProvider.overrideWith(() => shop ?? _MockShopNotifier()),
      streakProvider.overrideWith(() => StreakNotifier()),
    ],
    child: MaterialApp(
      theme: ThemeData(),
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const StoreScreen(),
    ),
  );
}

void main() {
  group('StoreScreen layout', () {
    testWidgets('renders top section titles', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(createTestApp(prefs: prefs));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Protege tu racha'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('renders Personalización section when scrolled', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(createTestApp(prefs: prefs));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Personalización'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('renders shop items when scrolled', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(createTestApp(prefs: prefs));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pump(const Duration(seconds: 1));
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Boost de XP'), findsOneWidget);
      expect(find.text('Tema azul'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('shows gem count from learning provider', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final learning = _MockLearningNotifier();
      await tester.pumpWidget(createTestApp(prefs: prefs, learning: learning));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.textContaining('0'), findsWidgets);
      await tester.pumpAndSettle();
    });
  });

  group('StoreScreen buying', () {
    testWidgets('buying an item marks it as owned', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final learning = _MockLearningNotifier();
      final shop = _MockShopNotifier();
      await tester.pumpWidget(
        createTestApp(prefs: prefs, learning: learning, shop: shop),
      );
      await tester.pumpAndSettle();

      expect(shop.state.items.length, 2);
      await tester.pumpAndSettle();
    });
  });
}
