import 'package:flutter/material.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forget Password")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Reset your password", style: AppTextStyles.headline1),
            const SizedBox(height: 8),
            Text(
              "Enter your email to receive a password reset link.",
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.subtleTextColor,
              ),
            ),
            const SizedBox(height: 40),
            const TextField(decoration: InputDecoration(labelText: 'Email')),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  /* Functionality to be added later */
                },
                child: const Text(
                  'Login',
                ), // Design shows "Login", can be "Send Link"
              ),
            ),
          ],
        ),
      ),
    );
  }
}
