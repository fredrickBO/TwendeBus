// lib/features/wallet/screens/top_up_screen.dart
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isProcessing = false;

  void _initiateTopUp() async {
    final amount = int.tryParse(_amountController.text);
    final phone = _phoneController.text.trim();

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid amount.")),
      );
      return;
    }
    if (phone.isEmpty || phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid phone number.")),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('initiateMpesaTopUp');

      final result = await callable.call(<String, dynamic>{
        'amount': amount,
        'phoneNumber': phone,
      });

      if (!mounted) return;

      if (result.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.data['message']),
            backgroundColor: AppColors.accentColor,
          ),
        );
        Navigator.of(context).pop(); // Go back to wallet screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.data['message'] ?? 'Failed.'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'An error occurred.'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Top Up Wallet")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Text("Enter amount", style: TextStyle(fontSize: 20)),
            TextField(
              controller: _amountController,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixText: "KES. ",
                hintText: "0",
              ),
            ),
            const SizedBox(height: 10),
            const Text("Phone Number", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 24),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'M-Pesa Phone Number',
                hintText: '254...',
              ),
              keyboardType: TextInputType.phone,
            ),

            // This TextField is styled to match the large, centered input design.
            const Spacer(), // Pushes the button to the bottom
            SizedBox(
              width: double.infinity,
              child: _isProcessing
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _initiateTopUp,
                      child: const Text("Top Up"),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
