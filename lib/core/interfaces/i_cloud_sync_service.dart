import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Abstract interface for cloud sync operations.
/// Enables dependency injection and testability.
abstract class ICloudSyncService {
  bool get isInitialized;
  bool get isSyncing;
  DateTime? get lastSync;
  Future<void> init(SharedPreferences prefs);
  Future<bool> saveAll(String uid, SharedPreferences prefs);
  Future<bool> loadAll(String uid, SharedPreferences prefs);
  Future<void> clearLocal(SharedPreferences prefs);
  Future<bool> deleteCloudData(String uid);
  void startListening(String uid, SharedPreferences prefs);
  void stopListening();
  void notifyFieldChanged(String spKey, Object? value);
  Stream<DocumentSnapshot> get userDocStream;
}
