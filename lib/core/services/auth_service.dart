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
    required String lastName,
  }) async {
    final String cleanEmail = email.trim();
    // print('--- DEBUG START ---');
    // print('Sending email to Firebase: |$cleanEmail|');
    // print('Email as character codes: ${cleanEmail.codeUnits}');
    // print('--- DEBUG END ---');

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: cleanEmail,
            password: password.trim(),
          );
      User? user = userCredential.user;
      if (user != null) {
        // After creating the user in Auth, create a corresponding document in Firestore.
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'firstName': firstName,
          'lastName': lastName,
          'email': cleanEmail,
          'role': 'passenger',
          'createdAt': Timestamp.now(),
          'walletBalance': 0, // Initialize wallet balance
        });
        return "Success";
      }
      return "An unexpected error occurred.";
    } on FirebaseAuthException catch (e) {
      //print('FIREBASE AUTH EXCEPTION: Code: ${e.code}, Message: ${e.message}');

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

  //forgot password
  Future<String> forgotPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      // If the above line doesn't throw an error, it was successful.
      return "Success";
    } on FirebaseAuthException catch (e) {
      // Return the specific error message from Firebase.
      return e.message ?? "An error occurred.";
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
