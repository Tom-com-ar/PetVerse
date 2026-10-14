import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile.dart';

class ProfileService {
  ProfileService(this._firestore);

  final FirebaseFirestore _firestore;

  Future<void> createProfile(User user, String name) =>
      _firestore.collection('users').doc(user.uid).set({
        'email': user.email ?? '',
        'name': name.trim(),
        'bio': '',
        'photoUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

  Future<void> createProfileIfMissing(User user) async {
    final reference = _firestore.collection('users').doc(user.uid);
    if ((await reference.get()).exists) return;
    final email = user.email ?? '';
    final name = user.displayName?.trim();
    await reference.set({
      'email': email,
      'name': name != null && name.isNotEmpty ? name : email.split('@').first,
      'bio': '',
      'photoUrl': user.photoURL ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<UserProfile> watchProfile(User user) =>
      _firestore.collection('users').doc(user.uid).snapshots().map((snapshot) {
        final data = snapshot.data();
        if (data == null) {
          return UserProfile(
            uid: user.uid,
            email: user.email ?? '',
            name: user.displayName ?? '',
            bio: '',
            photoUrl: user.photoURL ?? '',
          );
        }
        return UserProfile.fromMap(user.uid, data);
      });

  Future<void> saveProfile({
    required String uid,
    required String name,
    required String bio,
    required String photoUrl,
  }) => _firestore.collection('users').doc(uid).set({
    'name': name.trim(),
    'bio': bio.trim(),
    'photoUrl': photoUrl.trim(),
    'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
}
