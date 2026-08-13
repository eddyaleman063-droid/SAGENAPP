import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/ui/widgets/common/skip_to_content.dart';

void main() {
  testWidgets('renders without exceptions and exposes skip semantics', (
    tester,
  ) async {
    final targetKey = GlobalKey();
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SkipToContent(targetKey: targetKey),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    key: targetKey,
                    height: 2000,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final semantics = tester.getSemantics(find.byType(SkipToContent));
    expect(semantics.flagsCollection.isButton, isTrue);
    expect(find.byType(SkipToContent), findsOneWidget);
    handle.dispose();
  });

  testWidgets('tapping the skip button does not throw', (tester) async {
    final targetKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SkipToContent(targetKey: targetKey, label: 'Saltar'),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    key: targetKey,
                    height: 2000,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byType(SkipToContent));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);
  });
}
