// lib/features/home/widgets/route_card.dart
import 'package:flutter/material.dart';
import 'package:twende_bus_ui/core/models/route_model.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';
import 'package:twende_bus_ui/features/booking/screens/search_results_screen.dart';

class RouteCard extends StatelessWidget {
  final RouteModel route;

  const RouteCard({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          // Pass the selected route to the next screen
          MaterialPageRoute(builder: (_) => SearchResultsScreen(route: route)),
        );
      },
      child: Container(
        width: 250,
        margin: const EdgeInsets.only(right: 12.0),
        child: Card(
          color: AppColors.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.route, color: AppColors.primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        route.startPoint,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        route.endPoint,
                        style: const TextStyle(
                          color: AppColors.subtleTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "KES ${route.fare.toInt()}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
