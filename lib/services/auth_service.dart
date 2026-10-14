import 'package:firebase_auth/firebase_auth.dart';

import 'profile_service.dart';

class AuthService {
  AuthService(this._auth, this._profiles);

  final FirebaseAuth _auth;
  final ProfileService _profiles;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) throw StateError('No se pudo crear la cuenta.');
    await user.updateDisplayName(name.trim());
    await _profiles.createProfile(user, name);
  }

  Future<void> signIn(String email, String password) async =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  Future<void> signInWithGoogle() async {
    final credential = await _auth.signInWithPopup(GoogleAuthProvider());
    final user = credential.user;
    if (user == null) throw StateError('No se pudo iniciar sesión con Google.');
    await _profiles.createProfileIfMissing(user);
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  Future<void> signOut() => _auth.signOut();
}
