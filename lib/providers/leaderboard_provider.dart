import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/app_logger.dart';

class LeaderboardEntry {
  final String uid;
  final String displayName;
  final int totalXp;
  final String? photoUrl;

  const LeaderboardEntry({
    required this.uid,
    required this.displayName,
    required this.totalXp,
    this.photoUrl,
  });
}

final leaderboardProvider = StreamProvider.autoDispose<List<LeaderboardEntry>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .orderBy('learning_total_xp', descending: true)
      .limit(50)
      .snapshots()
      .handleError((e) {
        AppLogger().error('leaderboardProvider stream error', e);
        return Stream<List<LeaderboardEntry>>.value([]);
      })
      .map((snapshot) => snapshot.docs.map((doc) {
        final data = doc.data();
        final firstName = data['firstName'] as String? ?? '';
        final lastName = data['lastName'] as String? ?? '';
        return LeaderboardEntry(
          uid: doc.id,
          displayName: '$firstName $lastName'.trim(),
          totalXp: data['learning_total_xp'] as int? ?? 0,
          photoUrl: data['photoUrl'] as String?,
        );
      }).toList());
});
