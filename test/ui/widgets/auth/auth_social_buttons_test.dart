import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/ui/widgets/auth/auth_social_buttons.dart';

Widget _wrap({required AuthSocialButtons buttons}) {
  return MaterialApp(
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: buttons),
  );
}

void main() {
  testWidgets('renders google and facebook buttons', (tester) async {
    await tester.pumpWidget(
      _wrap(
        buttons: AuthSocialButtons(
          onGooglePressed: () {},
          onFacebookPressed: () {},
        ),
      ),
    );
    expect(find.text('Continuar con Google'), findsOneWidget);
    expect(find.text('Continuar con Facebook'), findsOneWidget);
  });

  testWidgets('fires callbacks when tapped', (tester) async {
    var google = 0;
    var facebook = 0;
    await tester.pumpWidget(
      _wrap(
        buttons: AuthSocialButtons(
          onGooglePressed: () => google++,
          onFacebookPressed: () => facebook++,
        ),
      ),
    );
    await tester.tap(find.text('Continuar con Google'));
    await tester.tap(find.text('Continuar con Facebook'));
    await tester.pump();
    expect(google, 1);
    expect(facebook, 1);
  });

  testWidgets('disables buttons while loading', (tester) async {
    var google = 0;
    await tester.pumpWidget(
      _wrap(
        buttons: AuthSocialButtons(
          onGooglePressed: () => google++,
          onFacebookPressed: () {},
          isLoading: true,
        ),
      ),
    );
    await tester.tap(find.text('Continuar con Google'), warnIfMissed: false);
    await tester.pump();
    expect(google, 0);
  });
}
