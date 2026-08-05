# Plan: Add Local Data Integrity Validation

## Context
The Flutter app uses SharedPreferences to store learning progress, gamification data, and streaks locally. A current checksum system in `LearningRepository` silently re-saves when tampering is detected, which effectively allows tampering to persist. Additionally, `StreakService` has no integrity validation at all.

## Changes

### 1. `lib/repositories/learning_repository.dart`

**Add field and getter** (after line 56):
```dart
bool _needsServerReconciliation = false;
bool get needsServerReconciliation => _needsServerReconciliation;
```

**Add method** (after `_saveChecksum`):
```dart
void markReconciled() {
  _needsServerReconciliation = false;
  _saveChecksum();
}
```

**Change checksum failure behavior** (lines 128-130). Replace:
```dart
} else if (!_verifyChecksum()) {
  AppLogger().warning('Integrity check failed — keeping loaded values, re-saving checksum');
  _saveChecksum();
}
```
With:
```dart
} else if (!_verifyChecksum()) {
  AppLogger().warning('Integrity check failed — possible data tampering');
  _needsServerReconciliation = true;
}
```

**Update abstract class** to expose the new member:
- Add `bool get needsServerReconciliation;` to the abstract `LearningRepository` class.
- Add `void markReconciled();` to the abstract class.

### 2. `lib/repositories/gamification_repository.dart`

No changes needed. Clock manipulation detection at lines 68-76 already throws `PlatformException` with code `CLOCK_MANIPULATION`. Verified in place.

### 3. `lib/repositories/streak_repository.dart`

**Add to abstract `StreakRepository`:**
- `bool get needsServerReconciliation;`
- `bool verifyIntegrity();`
- `void markReconciled();`

**Add to `StreakRepositoryImpl`:**
- `static const _checksumSalt = 'sagen_streak_v1';`
- `bool _needsServerReconciliation = false;`
- `bool get needsServerReconciliation => _needsServerReconciliation;`
- `_computeChecksum()` — hashes `currentStreak`, `longestStreak`, `lastActivityDate`, `streakFreezes` with salt.
- `_saveChecksum()` — stores to SharedPreferences key `streak_integrity`.
- `bool verifyIntegrity()` — compares stored vs computed checksum. On mismatch, sets `_needsServerReconciliation = true`, logs warning, returns false.
- `void markReconciled()` — sets `_needsServerReconciliation = false`, calls `_saveChecksum()`.
- Update `saveAll()` to call `_saveChecksum()` at the end.

### 4. `lib/services/streak_service.dart`

Two changes:

**a) Add getter:** `bool get needsServerReconciliation => _repo.needsServerReconciliation;`

**b) In `load()`:** After reading streak values (around line 56), call `_repo.verifyIntegrity()`. If it returns false, log: `AppLogger().warning('Streak integrity check failed — possible data tampering')`. The flag is already set inside `verifyIntegrity()`, so the caller (streak_provider) can check `needsServerReconciliation`.

### 5. `lib/providers/learning_provider.dart`

Two changes:

**a) In `_load()` (after line 305):** After `repo.load()` and setting state, check `repo.needsServerReconciliation`. If true:
- Log: `AppLogger().warning('Learning data integrity violation detected — scheduling server reconciliation')`
- The existing `cloudSyncServiceProvider` handles the actual server reconciliation on its next cycle.

**b) In `_reconcileWithServer()` (around line 157):** After successfully applying server values and calling `_save()`, add:
```dart
_repo.markReconciled();
```

### 6. `lib/providers/streak_provider.dart`

**In `build()` (after line 114):** After `_service.load()`, check if the underlying repository has `needsServerReconciliation` true. Since `StreakNotifier` doesn't directly hold a repo reference (it uses `StreakService`), add a `bool get needsServerReconciliation` getter to `StreakService` that delegates to `_repo.needsServerReconciliation`. Then in `build()`:
```dart
if (_service.needsServerReconciliation) {
  AppLogger().warning('Streak data integrity violation detected — scheduling server reconciliation');
  _syncStreakToFirestore();
}
```

### 7. Verify

Run `dart analyze lib/` to ensure no errors.

## Files to modify
1. `lib/repositories/learning_repository.dart`
2. `lib/repositories/streak_repository.dart`
3. `lib/services/streak_service.dart`
4. `lib/providers/learning_provider.dart`
5. `lib/providers/streak_provider.dart`
