import 'dart:async';

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

final leaderboardProvider = StreamProvider.autoDispose<List<LeaderboardEntry>>((
  ref,
) {
  return FirebaseFirestore.instance
      .collection('leaderboards')
      .orderBy('learning_total_xp', descending: true)
      .limit(50)
      .snapshots()
      // Do NOT swallow errors into an empty list — propagate them so the
      // StreamProvider enters its error state and the UI can show a retry.
      .transform(
        StreamTransformer<
          QuerySnapshot<Map<String, dynamic>>,
          QuerySnapshot<Map<String, dynamic>>
        >.fromHandlers(
          handleError: (e, st, sink) {
            AppLogger().error('leaderboardProvider stream error', e);
            sink.addError(e, st);
          },
        ),
      )
      .map(
        (snapshot) => snapshot.docs.map((doc) {
          final data = doc.data();
          final firstName = data['firstName'] as String? ?? '';
          final lastName = data['lastName'] as String? ?? '';
          return LeaderboardEntry(
            uid: doc.id,
            displayName: '$firstName $lastName'.trim(),
            totalXp: data['learning_total_xp'] as int? ?? 0,
            photoUrl: data['photoUrl'] as String?,
          );
        }).toList(),
      );
});
