import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/ui/widgets/home/home_header.dart';

Widget buildApp({required double totalDonated}) {
  return MaterialApp(
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: HomeHeader(
        displayName: 'Alessandro',
        streak: 3,
        greeting: 'Hola',
        totalDonated: totalDonated,
        gems: 120,
      ),
    ),
  );
}

void main() {
  testWidgets('donaciones con centimos se muestran con 2 decimales', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp(totalDonated: 9.9));
    expect(find.text('\$9.90'), findsOneWidget);
  });

  testWidgets('donaciones enteras se muestran sin decimales', (tester) async {
    await tester.pumpWidget(buildApp(totalDonated: 12));
    expect(find.text('\$12'), findsOneWidget);
  });

  testWidgets('sin donaciones muestra 0', (tester) async {
    await tester.pumpWidget(buildApp(totalDonated: 0));
    expect(find.text('0'), findsOneWidget);
  });
}
