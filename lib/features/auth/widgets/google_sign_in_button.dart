// lib/features/auth/widgets/google_sign_in_button.dart
import 'package:flutter/material.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  const GoogleSignInButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: Image.asset('assets/images/google_logo.png', height: 24.0),
      onPressed: onPressed,
      label: const Text(
        "Sign in with Google",
        style: TextStyle(color: AppColors.textColor),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}
