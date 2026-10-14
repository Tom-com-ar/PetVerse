import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._service) {
    _user = _service.currentUser;
    _subscription = _service.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  final AuthService _service;
  late final StreamSubscription<User?> _subscription;
  User? _user;
  User? get user => _user;

  Future<void> register(String name, String email, String password) =>
      _service.register(name: name, email: email, password: password);
  Future<void> signIn(String email, String password) =>
      _service.signIn(email, password);
  Future<void> sendPasswordReset(String email) =>
      _service.sendPasswordReset(email);
  Future<void> signOut() => _service.signOut();

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
