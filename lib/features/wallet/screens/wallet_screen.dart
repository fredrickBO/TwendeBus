// lib/features/wallet/screens/wallet_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:twende_bus_ui/core/providers.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';
import 'package:twende_bus_ui/features/wallet/screens/top_up_screen.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //watch providers for live data
    final userAsync = ref.watch(currentUserProvider);
    final transactionsAsync = ref.watch(userTransactionsProvider);
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
                //use live data to show balance
                userAsync.when(
                  data: (user) => Text(
                    "KES ${user?.walletBalance.toStringAsFixed(2) ?? '0.00'}",
                    style: AppTextStyles.headline1.copyWith(
                      color: Colors.white,
                      fontSize: 36,
                    ),
                  ),
                  loading: () =>
                      const CircularProgressIndicator(color: Colors.white),
                  error: (_, _) => Text(
                    "Error",
                    style: AppTextStyles.headline1.copyWith(
                      color: Colors.white,
                    ),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TopUpScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Money"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Use .when() to display the live transaction list.
          transactionsAsync.when(
            data: (transList) {
              if (transList.isEmpty) return const Text("No transactions yet.");
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transList.length,
                itemBuilder: (context, index) {
                  final trans = transList[index];
                  final isDeposit = trans.amount > 0;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isDeposit
                            ? AppColors.accentColor
                            : AppColors.errorColor,
                      ),
                      title: Text(trans.details),
                      subtitle: Text(
                        DateFormat('MMM d, yyyy').format(trans.timestamp),
                      ),
                      trailing: Text(
                        "${isDeposit ? '+' : ''}KES ${trans.amount.toInt()}",
                        style: TextStyle(
                          color: isDeposit
                              ? AppColors.accentColor
                              : AppColors.errorColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text("Could not load transactions."),
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
