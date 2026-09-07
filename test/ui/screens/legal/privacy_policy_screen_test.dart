import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/ui/screens/legal/privacy_policy_screen.dart';

void main() {
  testWidgets('renders title and all 9 privacy sections', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PrivacyPolicyScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final l = AppLocalizations.of(
      tester.element(find.byType(PrivacyPolicyScreen)),
    )!;
    expect(find.text(l.privacyPolicy), findsOneWidget);
    expect(find.text(l.privacyPolicyTitle), findsOneWidget);
    expect(find.text(l.privacyPolicyLastUpdate), findsOneWidget);

    final titles = <String>[
      l.privacyPolicySection1Title,
      l.privacyPolicySection2Title,
      l.privacyPolicySection3Title,
      l.privacyPolicySection4Title,
      l.privacyPolicySection5Title,
      l.privacyPolicySection6Title,
      l.privacyPolicySection7Title,
      l.privacyPolicySection8Title,
      l.privacyPolicySection9Title,
    ];
    final bodies = <String>[
      l.privacyPolicySection1Body,
      l.privacyPolicySection2Body,
      l.privacyPolicySection3Body,
      l.privacyPolicySection4Body,
      l.privacyPolicySection5Body,
      l.privacyPolicySection6Body,
      l.privacyPolicySection7Body,
      l.privacyPolicySection8Body,
      l.privacyPolicySection9Body,
    ];
    for (var i = 0; i < titles.length; i++) {
      expect(find.text(titles[i]), findsOneWidget);
      expect(find.text(bodies[i]), findsOneWidget);
    }
  });
}
