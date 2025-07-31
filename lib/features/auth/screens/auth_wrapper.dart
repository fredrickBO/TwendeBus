// lib/features/auth/screens/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twende_bus_ui/core/providers.dart';
import 'package:twende_bus_ui/features/auth/screens/login_screen.dart';
import 'package:twende_bus_ui/features/auth/screens/onboarding_screen.dart';
import 'package:twende_bus_ui/shared/widgets/bottom_nav_bar.dart';

// A ConsumerWidget can listen to providers.
class AuthWrapper extends ConsumerWidget {
  final bool hasSeenOnboarding;
  const AuthWrapper({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We watch the authStateProvider. This widget will rebuild whenever the state changes.
    final authState = ref.watch(authStateProvider);

    // The .when() method is a clean way to handle the different states of a stream.
    return authState.when(
      // This is called when we have data from the stream.
      data: (user) {
        // If the user object is not null, the user is logged in.
        if (user != null) {
          // So, we show the main app.
          return const BottomNavBar();
        }
        // If the user object is null, the user is logged out.
        // We check if the user has seen the onboarding screen.
        // If they have, we show the login screen.
        if (hasSeenOnboarding) {
          // If the user has seen the onboarding, we show the login screen.
          return const LoginScreen();
        } else {
          // If the user has not seen the onboarding, we show the onboarding screen.
          return const OnboardingScreen();
        }
      },
      // This is shown while Firebase is checking the initial auth state.
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      // This is shown if there's an error connecting to Firebase.
      error: (error, stack) =>
          Scaffold(body: Center(child: Text("Something went wrong: $error"))),
    );
  }
}
