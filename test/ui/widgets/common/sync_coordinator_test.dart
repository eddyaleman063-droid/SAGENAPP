import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/ui/widgets/common/sync_coordinator.dart';

class _FakeAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthState(status: AuthStatus.unauthenticated);
}

void main() {
  testWidgets('SyncCoordinator se monta sin crashear (ref.listen en build)', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer(
      overrides: [
        prefsProvider.overrideWithValue(await SharedPreferences.getInstance()),
        authProvider.overrideWith(_FakeAuthNotifier.new),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: SyncCoordinator(child: Text('child-content')),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('child-content'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
