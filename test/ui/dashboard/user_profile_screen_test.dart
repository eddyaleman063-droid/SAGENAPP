import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/hardware_tier_provider.dart';
import 'package:sagen/providers/service_providers.dart';
import 'package:sagen/services/sage_emotion_service.dart';
import 'package:sagen/ui/screens/dashboard/user_profile_screen.dart';

// ignore: subtype_of_sealed_class
class _MockDocSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {
  @override
  Map<String, dynamic>? data() => snapshotData;
  @override
  bool get exists => snapshotExists;

  Map<String, dynamic>? snapshotData;
  bool snapshotExists = true;
}

class _NoPrecacheSageEmotionService extends SageEmotionService {
  @override
  Future<void> ensurePrecached(SageEmotion emotion) async {}
}

Widget _buildApp({required Stream<DocumentSnapshot> stream}) {
  return ProviderScope(
    overrides: [
      reduceAnimationsProvider.overrideWithValue(true),
      sageEmotionServiceProvider.overrideWithValue(
        _NoPrecacheSageEmotionService(),
      ),
    ],
    child: MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: UserProfileScreen(uid: 'u1', userStream: stream),
    ),
  );
}

void main() {
  group('UserProfileScreen', () {
    testWidgets('muestra datos del usuario con estadisticas', (tester) async {
      final doc = _MockDocSnapshot()
        ..snapshotData = {
          'firstName': 'Ana',
          'lastName': 'Garcia',
          'learning_total_xp': 250,
          'currentStreak': 12,
          'learning_level': 5,
        };

      await tester.pumpWidget(
        _buildApp(stream: Stream<DocumentSnapshot>.value(doc)),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Ana Garcia'), findsOneWidget);
      expect(find.text('Nivel'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('XP Total'), findsOneWidget);
      expect(find.text('250'), findsOneWidget);
      expect(find.text('Racha'), findsOneWidget);
      expect(find.text('12 días'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('usa valores por defecto cuando faltan campos', (tester) async {
      final doc = _MockDocSnapshot()..snapshotData = <String, dynamic>{};

      await tester.pumpWidget(
        _buildApp(stream: Stream<DocumentSnapshot>.value(doc)),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Guerrero Anónimo'), findsOneWidget);
      expect(find.text('Nivel'), findsOneWidget);
      expect(find.text('XP Total'), findsOneWidget);
      expect(find.text('Racha'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('muestra error con boton reintentar que recarga', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildApp(stream: Stream<DocumentSnapshot>.error(Exception('boom'))),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Error al cargar perfil'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('documento que no existe muestra error con Volver', (
      tester,
    ) async {
      final doc = _MockDocSnapshot()..snapshotExists = false;

      await tester.pumpWidget(
        _buildApp(stream: Stream<DocumentSnapshot>.value(doc)),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Error al cargar perfil'), findsOneWidget);
      expect(find.text('Atrás'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpWidget(const SizedBox());
    });
  });
}
