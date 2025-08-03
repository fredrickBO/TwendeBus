// lib/features/booking/screens/points_selection_screen.dart
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:twende_bus_ui/core/models/route_model.dart';
import 'package:twende_bus_ui/core/models/trip_model.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';
import 'package:twende_bus_ui/features/booking/screens/payment_screen.dart';

// Convert the widget to a StatefulWidget to manage user selections.
class PointsSelectionScreen extends StatefulWidget {
  final RouteModel route;
  final TripModel trip;
  final List<String> selectedSeats;
  const PointsSelectionScreen({
    super.key,
    required this.route,
    required this.trip,
    required this.selectedSeats,
  });

  @override
  State<PointsSelectionScreen> createState() => _PointsSelectionScreenState();
}

class _PointsSelectionScreenState extends State<PointsSelectionScreen> {
  // These lists hold the data for the points. In a real app, this would come from Firestore.
  // final List<String> _boardingPoints = [
  //   "Githunguri",
  //   "Benedicter @ 6:20am",
  //   "AP",
  //   "Shooters",
  // ];
  // final List<String> _deboardingPoints = [
  //   "Chiromo @ 7:05am",
  //   "Naivas",
  //   "Safaricom",
  // ];

  // These state variables will store the user's selection. They are nullable.
  String? _selectedBoardingPoint;
  String? _selectedDeboardingPoint;
  bool _isProcessing = false;

  // This function is called when a user selects a boarding point.
  void _onBoardingPointSelected(String? point) {
    // setState tells Flutter to rebuild the widget with the new state.
    setState(() {
      _selectedBoardingPoint = point;
    });
  }

  // This function is called when a user selects a deboarding point.
  void _onDeboardingPointSelected(String? point) {
    setState(() {
      _selectedDeboardingPoint = point;
    });
  }

  // This is the new function that creates the pending booking.
  void _createBookingAndProceed() async {
    setState(() => _isProcessing = true);
    try {
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('createPendingBooking');

      final result = await callable.call(<String, dynamic>{
        'tripId': widget.trip.id,
        'selectedSeats': widget.selectedSeats,
        'startStop': _selectedBoardingPoint!,
        'endStop': _selectedDeboardingPoint!,
      });

      if (!mounted) return;

      if (result.data['success'] == true) {
        final bookingId = result.data['bookingId'];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentScreen(
              bookingId: bookingId,
              totalFare: widget.trip.fare * widget.selectedSeats.length,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.data['message'] ?? 'Could not create booking.',
            ),
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
    final List<String> boardingPoints = widget.route.boardingPoints;
    final List<String> deboardingPoints = widget.route.deboardingPoints;
    // Check if both points have been selected to enable the button.
    final bool canProceed =
        _selectedBoardingPoint != null && _selectedDeboardingPoint != null;

    return Scaffold(
      appBar: AppBar(title: const Text("Points")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Boarding points:", style: AppTextStyles.headline2),
            const SizedBox(height: 8),
            // We use `.map()` to dynamically create a list of widgets from our data list.
            ...boardingPoints.map(
              (point) => _buildPointTile(
                name: point,
                groupValue: _selectedBoardingPoint,
                onChanged: _onBoardingPointSelected,
              ),
            ),

            const SizedBox(height: 40),

            Text("Deboarding points:", style: AppTextStyles.headline2),
            const SizedBox(height: 8),
            ...deboardingPoints.map(
              (point) => _buildPointTile(
                name: point,
                groupValue: _selectedDeboardingPoint,
                onChanged: _onDeboardingPointSelected,
              ),
            ),

            const Spacer(), // Pushes the button to the bottom
            SizedBox(
              width: double.infinity,
              child: _isProcessing
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      // The button is only enabled if `canProceed` is true.
                      onPressed: canProceed
                          ? _createBookingAndProceed
                          : null, // Setting onPressed to null disables the button.
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        disabledBackgroundColor: AppColors.subtleTextColor
                            .withOpacity(0.5),
                      ),
                      child: const Text("Proceed to Payment"),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // A reusable helper widget for each selectable point.
  Widget _buildPointTile({
    required String name,
    required String? groupValue, // The currently selected value for the group.
    required void Function(String?)
    onChanged, // The function to call when tapped.
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(name, style: AppTextStyles.bodyText),
      leading: Radio<String>(
        value: name, // The value this specific radio button represents.
        groupValue: groupValue, // The currently selected value in the group.
        onChanged:
            onChanged, // The callback to execute when this radio is tapped.
        activeColor: AppColors.primaryColor,
      ),
      onTap: () => onChanged(name), // Allows tapping the whole row to select.
    );
  }
}
