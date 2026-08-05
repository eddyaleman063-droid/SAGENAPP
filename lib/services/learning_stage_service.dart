import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/learning/stage.dart';

/// Manages learning stage progression and unlocking logic.
class LearningStageService {
  const LearningStageService();

  Future<List<Stage>> fetchStages() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('learning_stages')
          .orderBy(FieldPath.documentId)
          .get(const GetOptions(source: Source.serverAndCache))
          .timeout(const Duration(seconds: 10));
      return snapshot.docs.map((doc) => Stage.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to fetch learning stages: $e');
    }
  }

  // NOTE: seedDefaultContent intentionally removed.
  // Firestore Security Rules block client writes to `learning_stages`:
  //   match /{document=**} { allow read, write: if false; }
  // Content seeding must be done via Firebase Admin SDK (Cloud Function or script).
}
