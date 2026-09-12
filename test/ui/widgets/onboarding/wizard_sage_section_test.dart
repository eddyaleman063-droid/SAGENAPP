import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/providers/hardware_tier_provider.dart';
import 'package:sagen/providers/service_providers.dart';
import 'package:sagen/services/sage_emotion_service.dart';
import 'package:sagen/ui/widgets/common/sage_emotion_widget.dart';
import 'package:sagen/ui/widgets/onboarding/wizard_sage_section.dart';

class _NoPrecacheService extends SageEmotionService {
  @override
  Future<void> ensurePrecached(SageEmotion emotion) async {}
}

void main() {
  Widget wrap(Widget child) {
    return ProviderScope(
      overrides: [
        reduceAnimationsProvider.overrideWithValue(true),
        sageEmotionServiceProvider.overrideWithValue(_NoPrecacheService()),
      ],
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('WizardSageSection muestra mascota y mensaje', (tester) async {
    await tester.pumpWidget(
      wrap(
        const WizardSageSection(
          emotion: SageEmotion.curious,
          message: '¿Listo para empezar?',
        ),
      ),
    );
    await settle(tester);
    expect(find.text('¿Listo para empezar?'), findsOneWidget);
    expect(find.byType(SageEmotionWidget), findsOneWidget);
    final w = tester.widget<SageEmotionWidget>(find.byType(SageEmotionWidget));
    expect(w.emotion, SageEmotion.curious);
  });

  testWidgets('WizardSageBubble muestra mensaje y llama al fuego', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(const WizardSageBubble(message: 'Cuida tu constancia')),
    );
    await settle(tester);
    expect(find.text('Cuida tu constancia'), findsOneWidget);
    expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);
  });
}
