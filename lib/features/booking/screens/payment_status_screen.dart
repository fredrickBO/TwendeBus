// lib/features/booking/screens/payment_status_screen.dart
import 'package:flutter/material.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';
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
            Icon(
              isSuccess ? Icons.check_circle : Icons.cancel,
              color: isSuccess ? AppColors.primaryColor : AppColors.errorColor,
              size: 100,
            ),
            const SizedBox(height: 24),
            Text(
              isSuccess ? "Paid" : "Payment Failed",
              style: AppTextStyles.headline1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isSuccess
                  ? "Your payment was successful."
                  // This is now the only responsibility of the failure case.
                  : "Your payment failed due to some problem. Please try again later.",
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.subtleTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // Always navigate back to the main app screen from this page.
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const BottomNavBar()),
                  (route) => false,
                );
              },
              child: Text(isSuccess ? "Done" : "Go back"),
            ),
          ],
        ),
      ),
    );
  }
}
