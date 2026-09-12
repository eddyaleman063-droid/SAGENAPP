import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/ui/widgets/common/ambient_background.dart';

void main() {
  testWidgets('renderiza al hijo sobre fondo degradado claro', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: AmbientBackground(child: Text('Hola SG'))),
    );
    expect(find.text('Hola SG'), findsOneWidget);
    expect(find.byType(AmbientBackground), findsOneWidget);
  });

  testWidgets('funciona en tema oscuro', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        home: const AmbientBackground(child: Text('Noche')),
      ),
    );
    expect(find.text('Noche'), findsOneWidget);
  });
}
