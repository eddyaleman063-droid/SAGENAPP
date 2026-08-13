import 'package:sagen/providers/learning_provider.dart';

class MockLearningNotifier extends LearningNotifier {
  bool _built = false;

  set lessonsCompleted(int v) {
    if (!_built) return;
    state = state.copyWith(lessonsCompleted: v);
  }

  @override
  LearningState build() {
    _built = true;
    return const LearningState();
  }

  @override
  Future<void> addXp(int amount, {String? reason, String? lessonId}) async {
    final newXp = state.xp + amount;
    final newTotalXp = state.totalXpEarned + amount;
    final newLevel = (newTotalXp / 100).floor() + 1;
    state = state.copyWith(
      xp: newLevel > state.currentLevel ? 0 : newXp,
      totalXpEarned: newTotalXp,
      currentLevel: newLevel > state.currentLevel
          ? newLevel
          : state.currentLevel,
    );
  }
}
