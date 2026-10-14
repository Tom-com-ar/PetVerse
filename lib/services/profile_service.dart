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

  // PV3 will add pets here. PV2 already shows the owner's live list.
  Stream<List<PetSummary>> watchPets(String uid) => _firestore
      .collection('users')
      .doc(uid)
      .collection('pets')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => PetSummary.fromMap(doc.id, doc.data()))
            .toList(),
      );
}
