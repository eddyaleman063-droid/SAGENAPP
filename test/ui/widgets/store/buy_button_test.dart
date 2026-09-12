import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/ui/widgets/store/buy_button.dart';

Widget _wrap(BuyButton button) {
  return MaterialApp(
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: Center(child: button)),
  );
}

void main() {
  testWidgets('muestra el costo y permite comprar', (tester) async {
    await tester.pumpWidget(
      _wrap(const BuyButton(cost: 50, canBuy: true, onBuy: _noop)),
    );
    expect(find.text('50'), findsOneWidget);
  });

  testWidgets('item gratis muestra la etiqueta de gratis', (tester) async {
    await tester.pumpWidget(
      _wrap(const BuyButton(cost: 0, canBuy: true, onBuy: _noop)),
    );
    final l = AppLocalizations.of(tester.element(find.byType(BuyButton)))!;
    expect(find.text(l.free), findsOneWidget);
  });

  testWidgets('tap llama onBuy y muestra el spinner durante la compra', (
    tester,
  ) async {
    var buys = 0;
    await tester.pumpWidget(
      _wrap(
        BuyButton(cost: 50, canBuy: true, gemBalance: 100, onBuy: () => buys++),
      ),
    );
    await tester.tap(find.byType(BuyButton));
    await tester.pump();
    expect(buys, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpWidget(
      _wrap(
        BuyButton(
          cost: 50,
          canBuy: false,
          gemBalance: 100,
          onBuy: () => buys++,
        ),
      ),
    );
    await tester.pump();
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 700));
    expect(find.byIcon(Icons.check_rounded), findsNothing);
  });

  testWidgets('loading externo muestra spinner y deshabilita', (tester) async {
    var buys = 0;
    await tester.pumpWidget(
      _wrap(
        BuyButton(
          cost: 50,
          canBuy: true,
          isLoading: true,
          gemBalance: 100,
          onBuy: () => buys++,
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(BuyButton), warnIfMissed: false);
    await tester.pump();
    expect(buys, 0);

    await tester.pumpWidget(
      _wrap(
        BuyButton(
          cost: 50,
          canBuy: true,
          isLoading: false,
          gemBalance: 100,
          onBuy: () => buys++,
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('50'), findsOneWidget);
  });

  testWidgets('sin saldo muestra cuantas gemas faltan', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const BuyButton(cost: 50, canBuy: true, gemBalance: 10, onBuy: _noop),
      ),
    );
    final l = AppLocalizations.of(tester.element(find.byType(BuyButton)))!;
    expect(find.text(l.storeNeedMoreGems(40, 10, 50)), findsOneWidget);
    await tester.tap(find.byType(BuyButton), warnIfMissed: false);
    expect(find.text(l.storeNeedMoreGems(40, 10, 50)), findsOneWidget);
  });

  testWidgets('articulo ya comprado muestra etiqueta de owned', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const BuyButton(cost: 50, canBuy: false, gemBalance: 200, onBuy: _noop),
      ),
    );
    final l = AppLocalizations.of(tester.element(find.byType(BuyButton)))!;
    expect(find.text(l.storeAlreadyOwned), findsOneWidget);
  });

  testWidgets('no vuelve a comprar mientras esta comprando', (tester) async {
    var buys = 0;
    await tester.pumpWidget(
      _wrap(
        BuyButton(cost: 50, canBuy: true, gemBalance: 100, onBuy: () => buys++),
      ),
    );
    await tester.tap(find.byType(BuyButton));
    await tester.pump();
    await tester.tap(find.byType(BuyButton), warnIfMissed: false);
    await tester.pump();
    expect(buys, 1);
  });
}

void _noop() {}
