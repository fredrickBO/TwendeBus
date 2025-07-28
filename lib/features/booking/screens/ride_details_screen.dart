// lib/features/booking/screens/ride_details_screen.dart
import 'package:flutter/material.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';
import 'package:twende_bus_ui/features/booking/screens/cancel_ride_screen.dart';

class RideDetailsScreen extends StatelessWidget {
  const RideDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ride Details")),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // Date header
          Text("21 November 2024", style: AppTextStyles.bodyText),
          const SizedBox(height: 16),

          // The vertical journey timeline widget.
          _buildJourneyTimeline(),
          const Divider(height: 32),

          // Price summary row.
          _buildDetailRow("Total fare", "KES 150.00"),
          const Divider(height: 32),

          // Driver info section.
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage("https://placehold.co/100x100/png"),
            ),
            title: Text(
              "John Kamau",
              style: AppTextStyles.bodyText.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Contact John"),
            trailing: const Icon(Icons.phone, color: AppColors.primaryColor),
          ),
        ],
      ),
      // We use a `bottomNavigationBar` to pin the action buttons to the bottom of the screen.
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize
              .min, // This makes the Column take up minimum vertical space.
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("Track Ride"),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CancelRideScreen()),
                  );
                },
                child: const Text("Cancel Ride"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // A helper method to build the journey timeline UI element.
  Widget _buildJourneyTimeline() {
    return Row(
      children: [
        Column(
          children: const [
            Icon(Icons.circle, size: 12, color: AppColors.primaryColor),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                "⋮",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.subtleTextColor,
                ),
              ),
            ),
            Icon(Icons.location_on, size: 16, color: AppColors.secondaryColor),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("03:30", style: AppTextStyles.labelText),
            Text(
              "Westlands",
              style: AppTextStyles.bodyText.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text("The Mall", style: AppTextStyles.labelText),
            const SizedBox(height: 20),
            Text("03:50", style: AppTextStyles.labelText),
            Text(
              "Utawala",
              style: AppTextStyles.bodyText.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text("Airways", style: AppTextStyles.labelText),
          ],
        ),
      ],
    );
  }

  // A reusable helper for displaying a row of details.
  Widget _buildDetailRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.bodyText),
        Text(
          value,
          style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
