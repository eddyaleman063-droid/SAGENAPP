import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/gem_provider.dart';
import 'package:sagen/providers/learning_provider.dart';

class _NoopLearningNotifier extends LearningNotifier {
  int addXpCalls = 0;
  int lastAmount = 0;

  @override
  LearningState build() => const LearningState(isLoading: false);

  @override
  Future<void> addXp(
    int amount, {
    String? reason,
    String? lessonId,
    String? achievementId,
  }) async {
    addXpCalls++;
    lastAmount = amount;
  }
}

class _NoopGemNotifier extends GemNotifier {
  int awardCalls = 0;

  @override
  GemState build() => const GemState();

  @override
  void awardMiniGameGems() {
    awardCalls++;
  }
}

/// Records reward calls made by a mini-game screen without touching Firestore.
///
/// Los notifiers se crean por llamada a [app]: cada test monta instancias
/// nuevas en su propio ProviderScope. Reusar el mismo objeto entre tests
/// provoca que Riverpod re-inicialice el `_element` del notifier
/// (LateInitializationError).
class MiniGameHarness {
  _NoopLearningNotifier? _learning;
  _NoopGemNotifier? _gems;

  int get addXpCalls => _learning?.addXpCalls ?? 0;
  int get lastXpAmount => _learning?.lastAmount ?? 0;
  int get gemAwardCalls => _gems?.awardCalls ?? 0;

  Widget app(Widget home) {
    final learning = _NoopLearningNotifier();
    final gems = _NoopGemNotifier();
    _learning = learning;
    _gems = gems;
    return ProviderScope(
      overrides: [
        learningProvider.overrideWith(() => learning),
        gemProvider.overrideWith(() => gems),
      ],
      child: MaterialApp(
        theme: ThemeData(),
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    );
  }
}

/// Viewport alto para que las grillas de 12 items sean totalmente hit-testables
/// (el default de 600px logicos las deja fuera de pantalla).
Future<void> useTallViewport(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

/// Desmonta el arbol cancelando los timers de los juegos y los de
/// flutter_animate (timer de 0ms), evitando "Timer is still pending".
Future<void> teardownGame(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 600));
}
