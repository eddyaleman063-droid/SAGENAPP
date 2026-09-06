import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/ui/widgets/common/error_boundary.dart';

void main() {
  group('ErrorBoundary', () {
    testWidgets('renders child when no error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ErrorBoundary(child: Text('Content'))),
      );
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('ErrorBoundary is a StatefulWidget', (tester) async {
      const widget = ErrorBoundary(child: Text('Inner'));
      expect(widget, isA<StatefulWidget>());
    });

    testWidgets('replaces child on dispose and re-create', (tester) async {
      final key1 = GlobalKey();
      final key2 = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(key: key1, child: const Text('V1')),
        ),
      );
      expect(find.text('V1'), findsOneWidget);
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(key: key2, child: const Text('V2')),
        ),
      );
      expect(find.text('V2'), findsOneWidget);
    });
  });
}
