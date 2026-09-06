import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/config/onboarding_wizard_config.dart';
import 'package:sagen/ui/widgets/onboarding/wizard_option_tile.dart';

void main() {
  const option = WizardOption(
    label: 'Google',
    value: 'Google',
    icon: Icons.g_mobiledata_rounded,
  );

  Widget buildApp({
    required bool isSelected,
    required VoidCallback onTap,
    bool multi = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: multi
            ? WizardMultiChoiceTile(
                option: option,
                isSelected: isSelected,
                onTap: onTap,
              )
            : WizardSingleChoiceTile(
                option: option,
                isSelected: isSelected,
                onTap: onTap,
              ),
      ),
    );
  }

  testWidgets('renders option label and gesture area', (tester) async {
    await tester.pumpWidget(buildApp(isSelected: false, onTap: () {}));
    expect(find.text('Google'), findsOneWidget);
    expect(find.byIcon(Icons.g_mobiledata_rounded), findsOneWidget);
  });

  testWidgets('shows checkbox only in multi-choice mode', (tester) async {
    await tester.pumpWidget(
      buildApp(isSelected: true, onTap: () {}, multi: true),
    );
    expect(find.byIcon(Icons.check_box_rounded), findsOneWidget);
    await tester.pumpWidget(buildApp(isSelected: true, onTap: () {}));
    expect(find.byIcon(Icons.check_box_rounded), findsNothing);
  });

  testWidgets('invokes onTap when the tile is tapped', (tester) async {
    var taps = 0;
    await tester.pumpWidget(buildApp(isSelected: false, onTap: () => taps++));
    await tester.tap(find.text('Google'));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('selecting an already selected tile still forwards the tap', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(buildApp(isSelected: true, onTap: () => taps++));
    await tester.tap(find.text('Google'));
    await tester.pump();
    expect(taps, 1);
  });
}
