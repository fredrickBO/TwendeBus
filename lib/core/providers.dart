// lib/core/providers.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twende_bus_ui/core/services/auth_service.dart';

// Provides a global instance of our AuthService class.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Provides a real-time stream of the user's authentication state.
// The UI will listen to this to know if the user is logged in or out.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});
