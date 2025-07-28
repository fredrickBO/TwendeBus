// lib/features/booking/screens/payment_status_screen.dart
import 'package:flutter/material.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';
import 'package:twende_bus_ui/features/booking/screens/ride_confirmation_screen.dart';
import 'package:twende_bus_ui/shared/widgets/bottom_nav_bar.dart';

class PaymentStatusScreen extends StatelessWidget {
  final bool isSuccess;
  const PaymentStatusScreen({super.key, required this.isSuccess});

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
            // The success or failure icon
            isSuccess
                ? const Icon(
                    Icons.check_circle,
                    color: AppColors.primaryColor,
                    size: 100,
                  )
                : Icon(Icons.cancel, color: AppColors.errorColor, size: 100),
            const SizedBox(height: 24),
            // The main text message
            Text(
              isSuccess ? "Paid\nKES 100.00" : "Payment Failed",
              style: AppTextStyles.headline1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // The sub-text message
            Text(
              isSuccess
                  ? "to Super Metro"
                  : "Your payment failed due to some problem. Please try again later",
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.subtleTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // The "View Ticket Details" text button
            if (isSuccess)
              TextButton(
                onPressed: () {},
                child: const Text("View Ticket Details"),
              ),
            const Spacer(),
            // The main action button
            ElevatedButton(
              onPressed: () {
                if (isSuccess) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RideConfirmationScreen(),
                    ),
                  );
                } else {
                  // Go back to the main app screen
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const BottomNavBar()),
                    (route) => false,
                  );
                }
              },
              child: Text(isSuccess ? "Done" : "Go back"),
            ),
          ],
        ),
      ),
    );
  }
}
