// lib/features/booking/screens/payment_screen.dart
import 'package:flutter/material.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';
import 'package:twende_bus_ui/features/booking/screens/payment_status_screen.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fare Summary Card
            Card(
              color: AppColors.cardColor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildFareRow("Fare Amount", "KES 100"),
                    const SizedBox(height: 8),
                    _buildFareRow("1 Seat", "KES 100"),
                    const Divider(height: 24),
                    _buildFareRow("Total", "KES 100", isTotal: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Payment Method Section
            Text(
              "Choose Payment Method",
              style: AppTextStyles.bodyText.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.credit_card, color: Colors.orange),
                title: const Text("Mastercard"),
                trailing: const Icon(Icons.more_horiz),
              ),
            ),
            Card(
              child: ListTile(
                leading: Image.asset(
                  'assets/images/mpesa_logo.png',
                  height: 24,
                ), // Add mpesa logo to assets
                title: const Text("M-Pesa"),
                trailing: const Icon(Icons.more_horiz),
              ),
            ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // This demonstrates navigation to the success screen.
                  // Change `isSuccess: true` to `false` to see the failure screen.
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const PaymentStatusScreen(isSuccess: true),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Pay KES. 100"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFareRow(String title, String value, {bool isTotal = false}) {
    final style = isTotal
        ? AppTextStyles.headline2.copyWith(fontSize: 18)
        : AppTextStyles.bodyText.copyWith(color: AppColors.subtleTextColor);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: style),
        Text(value, style: style.copyWith(color: AppColors.textColor)),
      ],
    );
  }
}
