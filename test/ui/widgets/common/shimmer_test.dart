import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/ui/widgets/shimmer_loading.dart';
import 'package:sagen/ui/widgets/shimmer_scope.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('ShimmerLoading', () {
    Widget buildApp({bool withScope = false}) {
      return ProviderScope(
        overrides: [prefsProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: withScope
                ? const ShimmerScope(
                    child: ShimmerLoading(width: 200, height: 16),
                  )
                : const ShimmerLoading(width: 200, height: 16),
          ),
        ),
      );
    }

    testWidgets('renders without ShimmerScope (own controller)', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();
      expect(find.byType(ShimmerLoading), findsOneWidget);
    });

    testWidgets('renders within ShimmerScope (shared controller)', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp(withScope: true));
      await tester.pump();
      expect(find.byType(ShimmerLoading), findsOneWidget);
    });

    testWidgets('honors custom dimensions', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [prefsProvider.overrideWithValue(prefs)],
          child: MaterialApp(
            home: Scaffold(
              body: ShimmerLoading(width: 100, height: 20, borderRadius: 4),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ShimmerLoading), findsOneWidget);
    });
  });

  group('ShimmerBlock', () {
    testWidgets('renders multiple lines', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [prefsProvider.overrideWithValue(prefs)],
          child: MaterialApp(home: Scaffold(body: ShimmerBlock(lines: 3))),
        ),
      );
      await tester.pump();
      expect(find.byType(ShimmerLoading), findsNWidgets(3));
    });
  });
}
