// lib/features/routes/screens/routes_screen.dart
import 'package:flutter/material.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';

class RoutesScreen extends StatelessWidget {
  const RoutesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Routes")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 6, // Show 6 static routes for the UI
        itemBuilder: (context, index) {
          return const RouteListItem();
        },
      ),
    );
  }
}

// A reusable widget for a single item in the routes list.
class RouteListItem extends StatelessWidget {
  const RouteListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Row(
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
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppColors.secondaryColor,
                ),
              ],
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Westlands",
                  style: AppTextStyles.bodyText.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Utawala",
                  style: AppTextStyles.bodyText.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              "KES 150",
              style: AppTextStyles.headline2.copyWith(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
