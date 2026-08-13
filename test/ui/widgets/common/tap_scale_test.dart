import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/ui/widgets/common/tap_scale.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  testWidgetsAnimated('renders its child', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: TapScale(child: Text('tap me'))),
      ),
    );
    expect(find.text('tap me'), findsOneWidget);
  });

  testWidgetsAnimated('invokes onTap when tapped', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TapScale(child: const Text('tap me'), onTap: () => tapped++),
        ),
      ),
    );
    await tester.tap(find.text('tap me'));
    await tester.pump();
    expect(tapped, 1);
  });

  testWidgetsAnimated('does not fire onTap when disabled', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TapScale(
            onTap: () => tapped++,
            enabled: false,
            child: const Text('tap me'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('tap me'), warnIfMissed: false);
    await tester.pump();
    expect(tapped, 0);
  });

  testWidgetsAnimated('ignores onTap when callback is null', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: TapScale(child: Text('tap me'))),
      ),
    );
    await tester.tap(find.text('tap me'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
