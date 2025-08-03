// lib/features/booking/screens/payment_screen.dart
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twende_bus_ui/core/models/booking_model.dart';
import 'package:twende_bus_ui/core/providers.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';
import 'package:twende_bus_ui/features/booking/screens/ride_confirmation_screen.dart';

// STEP 1: Convert to a StatefulWidget to manage the selection state.
class PaymentScreen extends ConsumerStatefulWidget {
  final String bookingId;
  final double totalFare;
  const PaymentScreen({
    super.key,
    required this.bookingId,
    required this.totalFare,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _isProcessing = false;
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

  void _confirmPayment() async {
    setState(() => _isProcessing = true);

    // For now, we only implement the Wallet payment.
    if (_selectedPaymentMethod == "Wallet") {
      try {
        final functions = FirebaseFunctions.instance;
        final callable = functions.httpsCallable('processWalletPayment');

        final result = await callable.call(<String, dynamic>{
          'bookingId': widget.bookingId,
        });

        if (!mounted) return;

        if (result.data['success'] == true) {
          final BookingModel confirmedBooking = await ref
              .watch(firestoreServiceProvider)
              .getBookingDetails(widget.bookingId);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => RideConfirmationScreen(booking: confirmedBooking),
            ),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.data['message'] ?? 'Payment failed.'),
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
    } else {
      // Logic for M-Pesa or Card would go here.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("This payment method is not yet implemented."),
        ),
      );
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalFare = widget.totalFare;

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
              subtitle: "Pay with M-Pesa",
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
            _buildSummaryRow("Total Fare", "KES ${totalFare.toInt()}"),
            _buildSummaryRow("Discount", "KES 0"),
            const Divider(),
            _buildSummaryRow(
              "Total Payable",
              "KES ${totalFare.toInt()}",
              isTotal: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: _isProcessing
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _confirmPayment,
                      child: Text("Pay KES ${totalFare.toInt()}"),
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
