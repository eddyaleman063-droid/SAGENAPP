import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/ui/screens/dashboard/ranking_screen.dart';

class _MockAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthState(
        uid: 'user-2',
        displayName: 'Carlos Mtz',
      );
}

final _mockEntries = [
  const LeaderboardEntry(uid: 'user-1', displayName: 'Ariana Reyes', totalXp: 3200),
  const LeaderboardEntry(uid: 'user-2', displayName: 'Carlos Mtz', totalXp: 2850),
  const LeaderboardEntry(uid: 'user-3', displayName: 'Luisa Fernanda', totalXp: 2410),
  const LeaderboardEntry(uid: 'user-4', displayName: 'Pedro Ramirez', totalXp: 2100),
  const LeaderboardEntry(uid: 'user-5', displayName: 'Sofia Torres', totalXp: 1890),
];

Widget createTestApp(SharedPreferences prefs) {
  return ProviderScope(
    overrides: [
      prefsProvider.overrideWithValue(prefs),
      authProvider.overrideWith(() => _MockAuthNotifier()),
      leaderboardProvider.overrideWith((ref) => Stream.value(_mockEntries)),
    ],
    child: MaterialApp(
      theme: ThemeData(),
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const RankingScreen(),
    ),
  );
}

void main() {
  group('RankingScreen', () {
    testWidgets('renders ranking title and subtitle', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(createTestApp(prefs));
      await tester.pumpAndSettle();

      expect(find.text('El Coliseo'), findsOneWidget);
      expect(find.textContaining('Clasificación global'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('renders top 3 names in podium', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(createTestApp(prefs));
      await tester.pumpAndSettle();

      // Podium shows first name only
      expect(find.text('Ariana'), findsOneWidget);
      expect(find.text('Carlos'), findsOneWidget);
      expect(find.text('Luisa'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('renders remaining entries in scrollable list',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(createTestApp(prefs));
      await tester.pumpAndSettle();

      // Scroll down to show entries below the fold
      await tester.drag(find.text('El Coliseo'), const Offset(0, -800));
      await tester.pumpAndSettle();

      expect(find.text('Pedro Ramirez'), findsOneWidget);
      expect(find.text('Sofia Torres'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('shows empty message when no entries', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final emptyApp = ProviderScope(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          authProvider.overrideWith(() => _MockAuthNotifier()),
          leaderboardProvider.overrideWith((ref) => Stream.value(<LeaderboardEntry>[])),
        ],
        child: MaterialApp(
          theme: ThemeData(),
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const RankingScreen(),
        ),
      );
      await tester.pumpWidget(emptyApp);
      await tester.pump();

      expect(find.textContaining('Completa lecciones'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
    });
  });
}
