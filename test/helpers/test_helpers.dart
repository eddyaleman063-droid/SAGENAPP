import 'package:flutter_test/flutter_test.dart';

/// Wraps [testWidgets] to automatically settle all pending timers
/// (flutter_animate, etc.) after each test.
void testWidgetsAnimated(
  String description,
  WidgetTesterCallback test, {
  bool? skip,
  Timeout? timeout,
  dynamic tags,
}) {
  testWidgets(
    description,
    (tester) async {
      await test(tester);
      await tester.pumpAndSettle();
    },
    skip: skip,
    timeout: timeout,
    tags: tags,
  );
}
