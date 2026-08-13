import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/ui/widgets/keyboard_aware_layout.dart';

void main() {
  testWidgets('renders the child inside a scroll view', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: KeyboardAwareLayout(child: Text('content'))),
      ),
    );
    expect(find.text('content'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(SafeArea), findsOneWidget);
  });

  testWidgets('tapping outside a focused field dismisses the keyboard', (
    tester,
  ) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KeyboardAwareLayout(
            child: Column(
              children: [
                TextField(focusNode: focusNode, autofocus: true),
                const SizedBox(height: 200),
                const Text('tap area'),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);

    await tester.tap(find.text('tap area'));
    await tester.pump();
    expect(focusNode.hasFocus, isFalse);
  });
}
