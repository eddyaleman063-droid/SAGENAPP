import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/sage_emotion_service.dart';
import 'package:sagen/ui/screens/onboarding/motivation_screen.dart';
import 'package:sagen/ui/screens/onboarding/projection_screen.dart';
import 'package:sagen/ui/screens/onboarding/route_selection_screen.dart';
import 'package:sagen/ui/screens/onboarding/starting_point_screen.dart';
import 'package:sagen/ui/widgets/common/sage_emotion_widget.dart';

class _NoPrecacheSageEmotionService extends SageEmotionService {
  @override
  Future<void> ensurePrecached(SageEmotion emotion) async {}
}

Widget _wrap(Widget child, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: [
      reduceAnimationsProvider.overrideWithValue(true),
      sageEmotionServiceProvider.overrideWithValue(
        _NoPrecacheSageEmotionService(),
      ),
      ...overrides,
    ],
    child: MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

SageEmotion _mascotEmotion(WidgetTester tester) =>
    tester.widget<SageEmotionWidget>(find.byType(SageEmotionWidget)).emotion;

void _setTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  group('MotivationScreen', () {
    testWidgets('renderiza estado inicial sin seleccion', (tester) async {
      _setTallViewport(tester);
      var wentBack = false;
      await tester.pumpWidget(
        _wrap(MotivationScreen(onBack: () => wentBack = true)),
      );
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Carrera profesional'), findsOneWidget);
      expect(find.text('Estudios'), findsOneWidget);
      expect(find.text('Divertirme'), findsOneWidget);
      expect(find.text('Entrenar mi mente'), findsOneWidget);
      expect(find.text('Conectar con personas'), findsOneWidget);
      expect(find.text('Viajar'), findsOneWidget);
      expect(find.text('Otro'), findsOneWidget);
      expect(find.text('Sin motivación seleccionada'), findsOneWidget);
      expect(_mascotEmotion(tester), SageEmotion.curious);

      await tester.tap(find.byTooltip('Atrás'));
      await tester.pump();
      expect(wentBack, isTrue);
      await _settle(tester);
    });

    testWidgets('selecciona y deselecciona una opcion', (tester) async {
      _setTallViewport(tester);
      var continued = false;
      await tester.pumpWidget(
        _wrap(MotivationScreen(onContinue: () => continued = true)),
      );
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.byKey(const ValueKey('motivation_0')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('¡Grandes razones para aprender!'), findsOneWidget);
      expect(_mascotEmotion(tester), SageEmotion.thinking);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('motivation_0')),
          matching: find.byIcon(Icons.check),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Continuar'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(continued, isTrue);

      continued = false;
      await tester.tap(find.byKey(const ValueKey('motivation_0')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Sin motivación seleccionada'), findsOneWidget);
      expect(_mascotEmotion(tester), SageEmotion.curious);

      await tester.tap(find.text('Continuar'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(continued, isFalse);
      await _settle(tester);
    });

    testWidgets('seleccion multiple muestra dialogo y mascota', (tester) async {
      _setTallViewport(tester);
      var continued = false;
      await tester.pumpWidget(
        _wrap(MotivationScreen(onContinue: () => continued = true)),
      );
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.byKey(const ValueKey('motivation_1')));
      await tester.tap(find.byKey(const ValueKey('motivation_2')));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Múltiples motivaciones seleccionadas'), findsOneWidget);
      expect(_mascotEmotion(tester), SageEmotion.excitedWave);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('motivation_1')),
          matching: find.byIcon(Icons.check),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('motivation_2')),
          matching: find.byIcon(Icons.check),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Continuar'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(continued, isTrue);
      await _settle(tester);
    });

    testWidgets('opcion Otro es exclusiva y se libera al elegir otra', (
      tester,
    ) async {
      _setTallViewport(tester);
      var continued = false;
      await tester.pumpWidget(
        _wrap(MotivationScreen(onContinue: () => continued = true)),
      );
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.byKey(const ValueKey('motivation_5')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(_mascotEmotion(tester), SageEmotion.wink);

      await tester.tap(find.byKey(const ValueKey('motivation_6')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.text('¡Entendido! Cuéntame más por el camino.'),
        findsOneWidget,
      );
      expect(_mascotEmotion(tester), SageEmotion.curious);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('motivation_5')),
          matching: find.byIcon(Icons.check),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('motivation_6')),
          matching: find.byIcon(Icons.check),
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('motivation_2')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.text('¡Me encanta! Divertirme es mi especialidad.'),
        findsOneWidget,
      );
      expect(_mascotEmotion(tester), SageEmotion.laughing);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('motivation_6')),
          matching: find.byIcon(Icons.check),
        ),
        findsNothing,
      );

      await tester.tap(find.text('Continuar'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(continued, isTrue);
      await _settle(tester);
    });

    testWidgets('mapea mascota y dialogo para cada motivo', (tester) async {
      _setTallViewport(tester);
      var continued = false;
      await tester.pumpWidget(
        _wrap(MotivationScreen(onContinue: () => continued = true)),
      );
      await tester.pump(const Duration(milliseconds: 400));

      const msg = {
        0: '¡Grandes razones para aprender!',
        1: '¡Un mundo de oportunidades se abrirá para ti!',
        2: '¡Me encanta! Divertirme es mi especialidad.',
        3: 'Es una decisión sabia.',
        4: '¡Vamos a conectarte!',
        5: '¡Nada supera viajar con tus dispositivos 100% protegidos!',
      };
      const emotion = {
        0: SageEmotion.thinking,
        1: SageEmotion.happyWings,
        2: SageEmotion.laughing,
        3: SageEmotion.thinking,
        4: SageEmotion.happyWings,
        5: SageEmotion.wink,
      };

      for (var i = 0; i <= 5; i++) {
        await tester.tap(find.byKey(ValueKey('motivation_$i')));
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text(msg[i]!), findsOneWidget);
        expect(_mascotEmotion(tester), emotion[i]);
        await tester.tap(find.byKey(ValueKey('motivation_$i')));
        await tester.pump(const Duration(milliseconds: 300));
      }
      expect(_mascotEmotion(tester), SageEmotion.curious);
      expect(continued, isFalse);
      await _settle(tester);
    });
  });

  group('StartingPointScreen', () {
    testWidgets('renderiza estado inicial sin seleccion', (tester) async {
      var continued = false;
      await tester.pumpWidget(
        _wrap(StartingPointScreen(onContinue: () => continued = true)),
      );
      await tester.pump(const Duration(milliseconds: 400));

      expect(
        find.text('¡Perfecto! Veamos dónde empezar tu entrenamiento.'),
        findsOneWidget,
      );
      expect(find.text('¿Es tu primera vez en ciberdefensa?'), findsOneWidget);
      expect(find.text('Empieza desde cero y forja tu escudo'), findsOneWidget);
      expect(find.text('¿Ya tienes experiencia como hacker?'), findsOneWidget);
      expect(
        find.text('¡Toma el test de nivel y salta lo básico!'),
        findsOneWidget,
      );
      expect(find.text('RECOMENDADO'), findsNothing);
      expect(_mascotEmotion(tester), SageEmotion.curious);

      await tester.tap(find.text('Continuar'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(continued, isFalse);
      await _settle(tester);
    });

    testWidgets(
      'seleccionar tarjeta principiante escribe beginner y continua',
      (tester) async {
        var continued = false;
        await tester.pumpWidget(
          _wrap(StartingPointScreen(onContinue: () => continued = true)),
        );
        await tester.pump(const Duration(milliseconds: 400));

        await tester.tap(find.text('¿Es tu primera vez en ciberdefensa?'));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(find.text('Continuar'));
        await tester.pump(const Duration(milliseconds: 300));

        expect(continued, isTrue);
        final scope = ProviderScope.containerOf(
          tester.element(find.byType(StartingPointScreen)),
        );
        expect(scope.read(diagnosticPathProvider), DiagnosticPath.beginner);
        await _settle(tester);
      },
    );

    testWidgets('seleccionar tarjeta avanzada escribe experienced', (
      tester,
    ) async {
      var continued = false;
      await tester.pumpWidget(
        _wrap(StartingPointScreen(onContinue: () => continued = true)),
      );
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.text('¿Ya tienes experiencia como hacker?'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Continuar'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(continued, isTrue);
      final scope = ProviderScope.containerOf(
        tester.element(find.byType(StartingPointScreen)),
      );
      expect(scope.read(diagnosticPathProvider), DiagnosticPath.experienced);
      await _settle(tester);
    });

    testWidgets('muestra badge RECOMENDADO segun assessmentLevel', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const StartingPointScreen(),
          overrides: [assessmentLevelProvider.overrideWith((ref) => 1)],
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('RECOMENDADO'), findsOneWidget);

      await tester.pumpWidget(
        _wrap(
          const StartingPointScreen(),
          overrides: [assessmentLevelProvider.overrideWith((ref) => 2)],
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('RECOMENDADO'), findsOneWidget);
      await _settle(tester);
    });

    testWidgets('back invoca onBack', (tester) async {
      var wentBack = false;
      await tester.pumpWidget(
        _wrap(StartingPointScreen(onBack: () => wentBack = true)),
      );
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.byTooltip('Atrás'));
      await tester.pump();
      expect(wentBack, isTrue);
      await _settle(tester);
    });
  });

  group('RouteSelectionScreen', () {
    testWidgets('renderiza estado inicial sin ruta elegida', (tester) async {
      var continued = false;
      await tester.pumpWidget(
        _wrap(RouteSelectionScreen(onContinue: () => continued = true)),
      );
      await tester.pump(const Duration(milliseconds: 400));

      expect(
        find.text('¿Qué área del entorno digital te gustaría dominar primero?'),
        findsOneWidget,
      );
      expect(find.text('Rutas de entrenamiento disponibles:'), findsOneWidget);
      expect(find.text('Fundamentos primero'), findsOneWidget);
      expect(find.text('Ruta intermedia'), findsOneWidget);
      expect(find.text('Ruta avanzada'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsNothing);

      await tester.tap(find.text('Continuar'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(continued, isFalse);
      await _settle(tester);
    });

    testWidgets('selecciona ruta, cambia de ruta y continua', (tester) async {
      var continued = false;
      await tester.pumpWidget(
        _wrap(RouteSelectionScreen(onContinue: () => continued = true)),
      );
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.text('Fundamentos primero'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

      await tester.tap(find.text('Ruta intermedia'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

      await tester.tap(find.text('Continuar'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(continued, isTrue);
      await _settle(tester);
    });

    testWidgets('back invoca onBack', (tester) async {
      var wentBack = false;
      await tester.pumpWidget(
        _wrap(RouteSelectionScreen(onBack: () => wentBack = true)),
      );
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.byTooltip('Atrás'));
      await tester.pump();
      expect(wentBack, isTrue);
      await _settle(tester);
    });
  });

  group('ProjectionScreen', () {
    testWidgets('renderiza beneficios y titulo', (tester) async {
      var continued = false;
      await tester.pumpWidget(
        _wrap(ProjectionScreen(onContinue: () => continued = true)),
      );
      await tester.pump(const Duration(milliseconds: 400));

      expect(
        find.text('¡Esto es lo que dominarás en 3 meses!'),
        findsOneWidget,
      );
      expect(find.text('Protege tus cuentas'), findsOneWidget);
      expect(find.text('Asegura tus redes sociales y correos'), findsOneWidget);
      expect(find.text('Detecta estafas'), findsOneWidget);
      expect(
        find.text('Identifica phishing y enlaces maliciosos'),
        findsOneWidget,
      );
      expect(find.text('Navega con seguridad'), findsOneWidget);
      expect(find.text('Navega internet con confianza'), findsOneWidget);
      expect(_mascotEmotion(tester), SageEmotion.happyWings);
      expect(continued, isFalse);
      await _settle(tester);
    });

    testWidgets('continuar siempre habilitado y con estado presionado', (
      tester,
    ) async {
      var continued = false;
      await tester.pumpWidget(
        _wrap(ProjectionScreen(onContinue: () => continued = true)),
      );
      await tester.pump(const Duration(milliseconds: 400));

      final continueFinder = find.text('Continuar');
      await tester.ensureVisible(continueFinder);
      await tester.pump();

      final gesture = await tester.startGesture(
        tester.getCenter(continueFinder),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 300));
      expect(continued, isTrue);
      await _settle(tester);
    });

    testWidgets('back invoca onBack', (tester) async {
      var wentBack = false;
      await tester.pumpWidget(
        _wrap(ProjectionScreen(onBack: () => wentBack = true)),
      );
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.byTooltip('Atrás'));
      await tester.pump();
      expect(wentBack, isTrue);
      await _settle(tester);
    });
  });
}
