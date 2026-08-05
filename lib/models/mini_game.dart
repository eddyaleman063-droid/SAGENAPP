/// Types of mini-games available in the game hub.
enum MiniGameType { wordMatch, speedSort, memoryFlip, patternTrace }

enum MiniGameDifficulty { easy, medium, hard }

/// Configuration for a mini-game session (type, difficulty, time).
class MiniGameConfig {
  final MiniGameType type;
  final MiniGameDifficulty difficulty;
  final Duration timeLimit;
  final int baseXpReward;

  const MiniGameConfig({
    required this.type,
    this.difficulty = MiniGameDifficulty.medium,
    this.timeLimit = const Duration(seconds: 60),
    this.baseXpReward = 50,
  });

  int get xpReward => baseXpReward * (1 + difficulty.index);
}
