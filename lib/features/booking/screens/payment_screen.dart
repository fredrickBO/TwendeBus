// lib/features/booking/screens/payment_screen.dart
import 'package:flutter/material.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';
import 'package:twende_bus_ui/features/booking/screens/payment_status_screen.dart';

// STEP 1: Convert to a StatefulWidget to manage the selection state.
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // STEP 2: Create a state variable to hold the currently selected payment method.
  // We initialize it with "Wallet" as the default.
  String _selectedPaymentMethod = "Wallet";

  // STEP 3: Create a function that updates the state when the user makes a selection.
  void _onPaymentMethodChanged(String? newMethod) {
    if (newMethod != null) {
      // setState() tells Flutter to rebuild the UI with the new value.
      setState(() {
        _selectedPaymentMethod = newMethod;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select Payment Method", style: AppTextStyles.headline2),
            const SizedBox(height: 24),

            // STEP 4: Connect the state to the UI widgets.
            _buildPaymentMethodTile(
              methodName: "Wallet",
              icon: Icons.account_balance_wallet,
              subtitle: "Available Balance: KES 2,560",
              // `isSelected` is now dynamically calculated.
              isSelected: _selectedPaymentMethod == "Wallet",
              onChanged: _onPaymentMethodChanged,
            ),

            _buildPaymentMethodTile(
              methodName: "M-Pesa",
              imageAsset: 'assets/images/mpesa_logo.png',
              subtitle: "Pay with M-Pesa Express",
              isSelected: _selectedPaymentMethod == "M-Pesa",
              onChanged: _onPaymentMethodChanged,
            ),

            _buildPaymentMethodTile(
              methodName: "Card",
              icon: Icons.credit_card,
              subtitle: "Pay with Visa or Mastercard",
              isSelected: _selectedPaymentMethod == "Card",
              onChanged: _onPaymentMethodChanged,
            ),

            const Spacer(),
            const Divider(),
            _buildSummaryRow("Total Fare", "KES 150.00"),
            _buildSummaryRow("Discount", "KES 0.00"),
            const Divider(),
            _buildSummaryRow("Total Payable", "KES 150.00", isTotal: true),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const PaymentStatusScreen(isSuccess: true),
                    ),
                  );
                },
                child: const Text("Pay KES 150"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Updated helper widget to be fully interactive.
  Widget _buildPaymentMethodTile({
    required String methodName,
    String? imageAsset,
    IconData? icon,
    required String subtitle,
    required bool isSelected,
    required void Function(String?) onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primaryColor : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: ListTile(
        onTap: () => onChanged(methodName), // Make the whole tile tappable.
        leading: imageAsset != null
            ? Image.asset(imageAsset, height: 24)
            : Icon(icon, color: AppColors.primaryColor),
        title: Text(
          methodName,
          style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle, style: AppTextStyles.labelText),
        trailing: Radio<String>(
          value: methodName, // The value this radio button represents.
          groupValue:
              _selectedPaymentMethod, // The currently selected value for the entire group.
          onChanged: onChanged, // The function to call when tapped.
          activeColor: AppColors.primaryColor,
        ),
      ),
    );
  }

  // Helper for summary rows remains the same.
  Widget _buildSummaryRow(String title, String value, {bool isTotal = false}) {
    // ... (This function remains unchanged)
    final style = isTotal
        ? AppTextStyles.headline2.copyWith(fontSize: 18)
        : AppTextStyles.bodyText;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
