import 'package:cloud_firestore/cloud_firestore.dart';

/// Abstract interface for Firestore operations.
/// Enables dependency injection and testability.
abstract class IFirestoreService {
  Future<void> createUserProfile({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
    required int age,
  });
  Future<void> updateField(String uid, String field, Object? value);
  Future<void> updateFields(String uid, Map<String, dynamic> data);
  Stream<DocumentSnapshot> streamUserDoc(String uid);
}
