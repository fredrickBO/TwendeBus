// lib/features/about/screens/about_us_screen.dart
import 'package:flutter/material.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About Us")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            //TwendeBus logo
            Image.asset('assets/images/onboarding_main.png', width: 160),
            const SizedBox(height: 16),
            Text("TwendeBus", style: AppTextStyles.headline1),
            Text("Version 1.0.0", style: AppTextStyles.labelText),
            const SizedBox(height: 24),
            Text(
              "TwendeBus is a modern mobility solution designed for the commuters of Nairobi. Our mission is to provide a reliable, convenient, and safe bus booking experience, simplifying daily travel for everyone.",
              style: AppTextStyles.bodyText,
              textAlign: TextAlign.center,
            ),
            const Spacer(), // Pushes the following content to the bottom
            Text(
              "© 2024 TwendeBus Inc. All Rights Reserved.",
              style: AppTextStyles.labelText,
            ),
            const SizedBox(height: 8),
            Text(
              "Terms of Service | Privacy Policy",
              style: AppTextStyles.labelText,
            ),
          ],
        ),
      ),
    );
  }
}
