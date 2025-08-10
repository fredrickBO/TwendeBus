// lib/features/booking/screens/cancel_ride_screen.dart
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:twende_bus_ui/core/models/booking_model.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';
import 'package:twende_bus_ui/shared/widgets/bottom_nav_bar.dart';

class CancelRideScreen extends StatefulWidget {
  final BookingModel booking;
  const CancelRideScreen({super.key, required this.booking});
  @override
  State<CancelRideScreen> createState() => _CancelRideScreenState();
}

class _CancelRideScreenState extends State<CancelRideScreen> {
  // A state variable to track if the checkbox is ticked.
  bool _agreedToPolicy = false;
  bool _isCancelling = false;

  void _confirmCancellation() async {
    setState(() => _isCancelling = true);
    try {
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('cancelBooking');
      final result = await callable.call(<String, dynamic>{
        'bookingId': widget.booking.id,
      });

      if (mounted && result.data['success'] == true) {
        // Show the success message from the backend.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.data['message']),
            backgroundColor: AppColors.accentColor,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const BottomNavBar(),
          ), // Go back to main app
          (route) => false,
        );
      }
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Cancellation failed.'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cancel Ride")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Cancellation Policy", style: AppTextStyles.headline2),
            const SizedBox(height: 16),
            _buildPolicyPoint(
              "100% Refund: Cancel At Least 5 Hours Before Departure Time.",
            ),
            _buildPolicyPoint(
              "50% Refund: Cancel At Least 1 Hour Before Departure Time.",
            ),
            _buildPolicyPoint(
              "No Refund: Cancellations Made After Departure Time Will Not Be Eligible For A Refund.",
            ),
            // Spacer pushes the content below it to the bottom of the screen.
            const Spacer(),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                "I Have Read And Agree With The Cancellation Policies.",
              ),
              value: _agreedToPolicy,
              // When the checkbox is changed, we update the state.
              onChanged: (bool? value) {
                setState(() {
                  _agreedToPolicy = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppColors.primaryColor,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: _isCancelling
                  ? const Center(child: CircularProgressIndicator())
                  : OutlinedButton(
                      // The button is only enabled if the user has agreed to the policy.
                      onPressed: _agreedToPolicy ? _confirmCancellation : null,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: _agreedToPolicy
                              ? AppColors.errorColor
                              : AppColors.subtleTextColor,
                        ),
                        foregroundColor: _agreedToPolicy
                            ? AppColors.errorColor
                            : AppColors.subtleTextColor,
                      ),
                      child: const Text("Cancel Now"),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // A helper to build each bullet point for the policy.
  Widget _buildPolicyPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "• ",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(text, style: AppTextStyles.bodyText)),
        ],
      ),
    );
  }
}
