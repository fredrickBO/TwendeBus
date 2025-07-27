// lib/features/support/screens/faq_support_screen.dart
import 'package:flutter/material.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';

class FaqSupportScreen extends StatelessWidget {
  const FaqSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FAQs & Support")),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Using ExpansionTile for a classic FAQ accordion style.
          ExpansionTile(
            title: const Text("How do I book a ticket?"),
            children: <Widget>[
              ListTile(
                title: Text(
                  "Navigate to the home screen, select a route, choose an upcoming trip, select your seat, and confirm your booking by paying from your wallet.",
                  style: AppTextStyles.labelText,
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: const Text("How do I top up my wallet?"),
            children: <Widget>[
              ListTile(
                title: Text(
                  "Go to Profile > Wallet, and tap the 'Add Money' button. You will be prompted to enter an amount and confirm via M-Pesa.",
                  style: AppTextStyles.labelText,
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: const Text("What is the cancellation policy?"),
            children: <Widget>[
              ListTile(
                title: Text(
                  "You can cancel a ride up to 2 hours before departure for a full refund. Cancellations made less than 2 hours before departure will incur a 50% fee.",
                  style: AppTextStyles.labelText,
                ),
              ),
            ],
          ),
          const Divider(height: 40),
          Center(
            child: Text(
              "Need more help?",
              style: AppTextStyles.headline2.copyWith(fontSize: 18),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.email, color: AppColors.primaryColor),
            title: const Text("Email Us"),
            subtitle: const Text("support@twendebus.com"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.phone, color: AppColors.primaryColor),
            title: const Text("Call Us"),
            subtitle: const Text("+254 712 345 678"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
