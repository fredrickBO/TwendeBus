// lib/core/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:google_sign_in/google_sign_in.dart';

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

  // THIS IS THE NEW, CORRECT signInWithGoogle METHOD FOR WEB
  Future<String> signInWithGoogle() async {
    try {
      // 1. Create a new GoogleAuthProvider instance.
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();

      // 2. Call signInWithPopup. This is the web-specific method that
      //    handles the entire pop-up flow for you.
      final UserCredential userCredential = await _auth.signInWithPopup(
        googleProvider,
      );
      final User? user = userCredential.user;

      // 3. CRUCIAL: Check if this is a new user and create their profile.
      //    This logic remains the same and is still correct.
      if (user != null &&
          userCredential.additionalUserInfo?.isNewUser == true) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'firstName': user.displayName?.split(' ').first ?? '',
          'lastName': user.displayName?.split(' ').last ?? '',
          'email': user.email,
          'role': 'passenger',
          'createdAt': Timestamp.now(),
          'walletBalance': 0,
        });
      }
      return "Success";
    } on FirebaseAuthException catch (e) {
      // Handle potential errors like "popup-closed-by-user"
      if (e.code == 'popup-closed-by-user') {
        return 'Sign-in aborted by user.';
      }
      return e.message ?? "An error occurred.";
    } catch (e) {
      return "An unexpected error occurred: ${e.toString()}";
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
