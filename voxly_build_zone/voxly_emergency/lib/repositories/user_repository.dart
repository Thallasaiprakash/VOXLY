import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import 'auth_repository.dart';

final userRepositoryProvider = Provider((ref) => UserRepository(FirebaseFirestore.instance));

final userProfileProvider = StreamProvider<UserModel?>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(userRepositoryProvider).getUserProfile(user.uid);
});

class UserRepository {
  final FirebaseFirestore _firestore;
  UserRepository(this._firestore);

  CollectionReference get _users => _firestore.collection('users');

  Stream<UserModel?> getUserProfile(String uid) {
    return _users.doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
    });
  }

  Future<void> createUserProfile(UserModel user) async {
    await _users.doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  Future<void> updateName(String uid, String name) async {
    await _users.doc(uid).update({'name': name});
  }

  Future<void> logMood(String uid, String date, int mood) async {
    await _users.doc(uid).update({
      'moodLog.$date': mood,
    });
  }

  Future<void> updateSettings(String uid, Map<String, dynamic> settings) async {
    await _users.doc(uid).update({'settings': settings});
  }

  Future<void> incrementStreak(String uid) async {
     await _users.doc(uid).update({'streakCount': FieldValue.increment(1)});
  }
}
