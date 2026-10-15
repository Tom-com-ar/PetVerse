import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile.dart';

class ProfileService {
  ProfileService(this._firestore);

  final FirebaseFirestore _firestore;

  Future<void> createProfile(User user, String name) =>
      _savePublicProfile(user.uid, {
        'email': user.email ?? '',
        'name': name.trim(),
        'bio': '',
        'photoUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

  Future<void> createProfileIfMissing(User user) async {
    final reference = _firestore.collection('users').doc(user.uid);
    final existing = await reference.get();
    if (existing.exists) {
      await _syncPublicProfile(user.uid, existing.data() ?? {});
      return;
    }
    final email = user.email ?? '';
    final name = user.displayName?.trim();
    await _savePublicProfile(user.uid, {
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
  }) => _savePublicProfile(uid, {
    'name': name.trim(),
    'bio': bio.trim(),
    'photoUrl': photoUrl.trim(),
    'updatedAt': FieldValue.serverTimestamp(),
  }, merge: true);

  CollectionReference<Map<String, dynamic>> get _publicProfiles =>
      _firestore.collection('public_profiles');

  Stream<List<UserProfile>> watchPublicProfiles(String currentUserId) =>
      _publicProfiles.orderBy('name').snapshots().map(
        (snapshot) => snapshot.docs
            .where((doc) => doc.id != currentUserId)
            .map((doc) => UserProfile.fromMap(doc.id, doc.data()))
            .toList(),
      );

  Future<void> ensurePublicProfile(User user) async {
    final document = await _firestore.collection('users').doc(user.uid).get();
    final data = document.data();
    if (data != null) await _syncPublicProfile(user.uid, data);
  }

  Future<void> _syncPublicProfile(
    String uid,
    Map<String, dynamic> source,
  ) => _publicProfiles.doc(uid).set({
    'name': source['name'] ?? '',
    'bio': source['bio'] ?? '',
    'photoUrl': source['photoUrl'] ?? '',
  }, SetOptions(merge: true));

  Future<void> _savePublicProfile(
    String uid,
    Map<String, dynamic> values, {
    bool merge = false,
  }) async {
    final batch = _firestore.batch();
    batch.set(
      _firestore.collection('users').doc(uid),
      values,
      SetOptions(merge: merge),
    );
    batch.set(
      _publicProfiles.doc(uid),
      {
        if (values.containsKey('name')) 'name': values['name'],
        if (values.containsKey('bio')) 'bio': values['bio'],
        if (values.containsKey('photoUrl')) 'photoUrl': values['photoUrl'],
      },
      SetOptions(merge: true),
    );
    await batch.commit();
  }
}
