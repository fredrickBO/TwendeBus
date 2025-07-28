// lib/features/booking/screens/points_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';
import 'package:twende_bus_ui/features/booking/screens/payment_screen.dart';

// Convert the widget to a StatefulWidget to manage user selections.
class PointsSelectionScreen extends StatefulWidget {
  const PointsSelectionScreen({super.key});

  @override
  State<PointsSelectionScreen> createState() => _PointsSelectionScreenState();
}

class _PointsSelectionScreenState extends State<PointsSelectionScreen> {
  // These lists hold the data for the points. In a real app, this would come from Firestore.
  final List<String> _boardingPoints = [
    "Githunguri",
    "Benedicter @ 6:20am",
    "AP",
    "Shooters",
  ];
  final List<String> _deboardingPoints = [
    "Chiromo @ 7:05am",
    "Naivas",
    "Safaricom",
  ];

  // These state variables will store the user's selection. They are nullable.
  String? _selectedBoardingPoint;
  String? _selectedDeboardingPoint;

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

  @override
  Widget build(BuildContext context) {
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
            ..._boardingPoints.map(
              (point) => _buildPointTile(
                name: point,
                groupValue: _selectedBoardingPoint,
                onChanged: _onBoardingPointSelected,
              ),
            ),

            const SizedBox(height: 40),

            Text("Deboarding points:", style: AppTextStyles.headline2),
            const SizedBox(height: 8),
            ..._deboardingPoints.map(
              (point) => _buildPointTile(
                name: point,
                groupValue: _selectedDeboardingPoint,
                onChanged: _onDeboardingPointSelected,
              ),
            ),

            const Spacer(), // Pushes the button to the bottom
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // The button is only enabled if `canProceed` is true.
                onPressed: canProceed
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PaymentScreen(),
                          ),
                        );
                      }
                    : null, // Setting onPressed to null disables the button.
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  disabledBackgroundColor: AppColors.subtleTextColor
                      .withOpacity(0.5),
                ),
                child: const Text("Proceed"),
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
