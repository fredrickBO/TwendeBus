// lib/features/wallet/screens/top_up_screen.dart
import 'package:flutter/material.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';

class TopUpScreen extends StatelessWidget {
  const TopUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Wallet")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Text("Enter amount", style: TextStyle(fontSize: 20)),
            // This TextField is styled to match the large, centered input design.
            const TextField(
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: "KES. ",
                prefixStyle: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.normal,
                  color: AppColors.subtleTextColor,
                ),
                hintText: "0",
                border: InputBorder.none, // Removes the default border
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
              ),
            ),
            const Spacer(), // Pushes the button to the bottom
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("Top Up"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
