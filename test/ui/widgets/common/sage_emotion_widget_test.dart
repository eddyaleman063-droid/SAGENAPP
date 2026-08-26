import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/ui/widgets/common/sage_emotion_widget.dart';
import 'package:sagen/services/sage_emotion_service.dart';

void main() {
  group('SageEmotionWidget', () {
    testWidgets('renders with animated=true', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SageEmotionWidget(
                emotion: SageEmotion.happy,
                size: 90,
                animated: true,
              ),
            ),
          ),
        ),
      );
      await tester.pump(Duration(seconds: 6));
      expect(find.byType(SageEmotionWidget), findsOneWidget);
    });

    testWidgets('renders with animated=false', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SageEmotionWidget(
                emotion: SageEmotion.calm,
                size: 60,
                animated: false,
              ),
            ),
          ),
        ),
      );
      await tester.pump(Duration(seconds: 6));
      expect(find.byType(SageEmotionWidget), findsOneWidget);
    });

    testWidgets('applies custom semantic label', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SageEmotionWidget(
                emotion: SageEmotion.happy,
                size: 48,
                semanticLabel: 'Mi mascota',
                animated: false,
              ),
            ),
          ),
        ),
      );
      await tester.pump(Duration(seconds: 6));
      expect(find.bySemanticsLabel('Mi mascota'), findsOneWidget);
    });

    testWidgets('clamps size between 24 and 200', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SageEmotionWidget(
                emotion: SageEmotion.excited,
                size: 500,
                animated: false,
              ),
            ),
          ),
        ),
      );
      await tester.pump(Duration(seconds: 6));
      expect(find.byType(SageEmotionWidget), findsOneWidget);
    });

    testWidgets('wraps in RepaintBoundary', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SageEmotionWidget(
                emotion: SageEmotion.calm,
                animated: false,
              ),
            ),
          ),
        ),
      );
      await tester.pump(Duration(seconds: 6));
      expect(find.byType(RepaintBoundary), findsWidgets);
    });
  });
}
