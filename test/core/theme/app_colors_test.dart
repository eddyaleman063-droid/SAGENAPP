import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';

void main() {
  Widget wrap(Widget child, {Brightness brightness = Brightness.dark}) {
    return MaterialApp(
      theme: brightness == Brightness.dark
          ? ThemeData.dark()
          : ThemeData.light(),
      home: Builder(
        builder: (context) {
          return child;
        },
      ),
    );
  }

  group('AppColorsX', () {
    testWidgets('isDark returns true for dark theme', (tester) async {
      bool? result;
      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) {
              result = context.isDark;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(result, isTrue);
    });

    testWidgets('isDark returns false for light theme', (tester) async {
      bool? result;
      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) {
              result = context.isDark;
              return const SizedBox();
            },
          ),
          brightness: Brightness.light,
        ),
      );
      expect(result, isFalse);
    });

    testWidgets('textPrimary returns white for dark', (tester) async {
      Color? result;
      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) {
              result = context.textPrimary;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(result, Colors.white);
    });

    testWidgets('textPrimary returns textDark for light', (tester) async {
      Color? result;
      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) {
              result = context.textPrimary;
              return const SizedBox();
            },
          ),
          brightness: Brightness.light,
        ),
      );
      expect(result, PremiumColors.textDark);
    });

    testWidgets('surfaceCard returns white for light', (tester) async {
      Color? result;
      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) {
              result = context.surfaceCard;
              return const SizedBox();
            },
          ),
          brightness: Brightness.light,
        ),
      );
      expect(result, Colors.white);
    });

    testWidgets('surfaceCard returns darkCard for dark', (tester) async {
      Color? result;
      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) {
              result = context.surfaceCard;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(result, PremiumColors.darkCard);
    });

    testWidgets('textSecondary returns white70 for dark', (tester) async {
      Color? result;
      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) {
              result = context.textSecondary;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(result, Colors.white70);
    });

    testWidgets('textTertiary returns white60 for dark', (tester) async {
      Color? result;
      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) {
              result = context.textTertiary;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(result, Colors.white54);
    });

    testWidgets('subtle returns white12 for dark', (tester) async {
      Color? result;
      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) {
              result = context.subtle;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(result, Colors.white12);
    });
  });
}
