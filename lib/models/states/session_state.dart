/// Sealed state for the learning session lifecycle.
sealed class SessionState {
  const SessionState();
}

class SessionIdle extends SessionState {
  const SessionIdle();
}

class SessionActive extends SessionState {
  final String lessonId;
  const SessionActive(this.lessonId);
}

class SessionCompleted extends SessionState {
  final int score;
  final int totalXp;
  const SessionCompleted(this.score, this.totalXp);
}

class SessionError extends SessionState {
  final String message;
  const SessionError(this.message);
}
