// lib/features/booking/screens/cancellation_success_screen.dart
import 'package:flutter/material.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';
import 'package:twende_bus_ui/shared/widgets/bottom_nav_bar.dart';

class CancellationSuccessScreen extends StatelessWidget {
  const CancellationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            const Icon(
              Icons.check_circle,
              color: AppColors.primaryColor,
              size: 100,
            ),
            const SizedBox(height: 24),
            Text(
              'Cancelled! Your ride has been cancelled successfully',
              style: AppTextStyles.headline1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Your refund is being processed',
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.subtleTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const BottomNavBar()),
                  (route) => false,
                );
              },
              child: const Text("Done"),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                /* Could navigate to home screen */
              },
              child: const Text("Book Another Ride"),
            ),
          ],
        ),
      ),
    );
  }
}
