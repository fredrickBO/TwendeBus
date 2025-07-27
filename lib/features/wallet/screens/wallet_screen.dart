// lib/features/wallet/screens/wallet_screen.dart
import 'package:flutter/material.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Wallet")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // This container is for the main balance display.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              // Using a gradient to match the more complex background in the design.
              gradient: LinearGradient(
                colors: [AppColors.secondaryColor, AppColors.primaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  "Current Balance",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  "KES 2,560.00",
                  style: AppTextStyles.headline1.copyWith(
                    color: Colors.white,
                    fontSize: 36,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // The 'Add Money' button.
          Align(
            alignment: Alignment.center,
            child: ElevatedButton.icon(
              onPressed: () {
                /* This would trigger the M-Pesa top-up flow */
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Money"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Header for the transactions list.
          Text("Recent Transactions", style: AppTextStyles.headline2),
          const SizedBox(height: 12),

          // Static list of transactions for the UI.
          _buildTransactionTile(
            isDeposit: true,
            details: "Top up from M-Pesa",
            date: "Oct 25, 2024",
            amount: "500",
          ),
          _buildTransactionTile(
            isDeposit: false,
            details: "Fare for Westlands trip",
            date: "Oct 24, 2024",
            amount: "150",
          ),
          _buildTransactionTile(
            isDeposit: false,
            details: "Fare for Kasarani trip",
            date: "Oct 23, 2024",
            amount: "80",
          ),
        ],
      ),
    );
  }

  // A helper method to create a single transaction list item.
  Widget _buildTransactionTile({
    required bool isDeposit,
    required String details,
    required String date,
    required String amount,
  }) {
    // We use a final variable for the color to make the code cleaner.
    final color = isDeposit ? AppColors.accentColor : AppColors.errorColor;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
          color: color,
        ),
        title: Text(details),
        subtitle: Text(date),
        trailing: Text(
          "${isDeposit ? '+' : '-'}KES $amount",
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
