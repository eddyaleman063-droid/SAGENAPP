import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/ui/widgets/onboarding/legal_text_block.dart';

Widget _wrap(LegalTextBlock block) {
  return MaterialApp(
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Center(
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.black),
          child: block,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('renders the legal text with terms and privacy spans', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const LegalTextBlock()));
    expect(find.textContaining('Términos', findRichText: true), findsOneWidget);
    expect(
      find.textContaining('Política de privacidad', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'Al registrarte aceptas nuestros',
        findRichText: true,
      ),
      findsOneWidget,
    );
  });
}
