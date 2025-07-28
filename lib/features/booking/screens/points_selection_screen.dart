// lib/features/booking/screens/points_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';
import 'package:twende_bus_ui/features/booking/screens/payment_screen.dart';

class PointsSelectionScreen extends StatelessWidget {
  const PointsSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Points")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Boarding points:", style: AppTextStyles.headline2),
            const SizedBox(height: 16),
            _buildPointTile("Githunguri", isSelected: false),
            _buildPointTile("Benedicter @ 6:20am", isSelected: true),
            _buildPointTile("AP", isSelected: false),
            _buildPointTile("Shooters", isSelected: false),

            const SizedBox(height: 40),

            Text("Deboarding points:", style: AppTextStyles.headline2),
            const SizedBox(height: 16),
            _buildPointTile("Chiromo @ 7:05am", isSelected: false),
            _buildPointTile("Naivas", isSelected: true),
            _buildPointTile("Safaricom", isSelected: false),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PaymentScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                ),
                child: const Text("Proceed"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointTile(String name, {required bool isSelected}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Radio<bool>(
        value: true,
        groupValue: isSelected,
        onChanged: (v) {},
        activeColor: AppColors.primaryColor,
      ),
      title: Text(name, style: AppTextStyles.bodyText),
    );
  }
}
