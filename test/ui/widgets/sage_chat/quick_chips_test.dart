import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/ui/widgets/sage_chat/quick_chips.dart';

void main() {
  testWidgets('renders all chips', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuickChips(
            chips: const ['¿Qué es XP?', 'Ayuda', 'Consejos'],
            onTap: (_) {},
            dark: false,
          ),
        ),
      ),
    );
    expect(find.text('¿Qué es XP?'), findsOneWidget);
    expect(find.text('Ayuda'), findsOneWidget);
    expect(find.text('Consejos'), findsOneWidget);
  });

  testWidgets('fires onTap with the tapped chip value', (tester) async {
    String? tapped;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuickChips(
            chips: const ['Pista', 'Siguiente'],
            onTap: (value) => tapped = value,
            dark: true,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Pista'));
    await tester.pump();
    expect(tapped, 'Pista');
  });
}
