// lib/core/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // A stream that emits the user object when auth state changes (login/logout).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign Up with Email & Password
  Future<String> signUp({
    required String email,
    required String password,
    required String firstName,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );
      User? user = userCredential.user;
      if (user != null) {
        // After creating the user in Auth, create a corresponding document in Firestore.
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'firstName': firstName,
          'email': email,
          'role': 'passenger',
          'createdAt': Timestamp.now(),
          'walletBalance': 0, // Initialize wallet balance
        });
        return "Success";
      }
      return "An unexpected error occurred.";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Authentication Failed.";
    }
  }

  // Sign In with Email & Password
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return "Success";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Authentication Failed.";
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
