// lib/features/auth/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';
import 'package:twende_bus_ui/features/auth/screens/login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  // Create a new function to handle the button press.
  void _onGetStarted(BuildContext context) async {
    // Get an instance of SharedPreferences.
    final prefs = await SharedPreferences.getInstance();
    // Set our flag to true. The device will now remember this.
    await prefs.setBool('hasSeenOnboarding', true);

    // After setting the flag, navigate to the next screen.
    // We check `context.mounted` as a best practice in async functions.
    if (context.mounted) {
      Navigator.pushReplacement(
        // Use pushReplacement to prevent going back to onboarding
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Image.asset('assets/images/onboarding_main.png', height: 250),
              const SizedBox(height: 40),
              Text(
                'Your Travel, Simplified',
                style: AppTextStyles.headline1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Plan your journey, book tickets, and manage everything in one place.',
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.subtleTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _onGetStarted(context),
                  child: const Text('Get Started'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
