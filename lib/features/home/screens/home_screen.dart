// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold provides the basic structure of the visual interface.
    return Scaffold(
      // SafeArea ensures that the app's content is not obscured by system intrusions
      // like the notch on an iPhone or the status bar on Android.
      body: SafeArea(
        // ListView makes its content scrollable if it exceeds the screen height.
        child: ListView(
          // Adds padding to all sides of the scrollable content.
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          children: [
            // This Padding widget is only for the header elements.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  // This Column holds the welcome text.
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome',
                        style: AppTextStyles.bodyText.copyWith(
                          color: AppColors.subtleTextColor,
                        ),
                      ),
                      Text(
                        'Gloria',
                        style: AppTextStyles.headline1.copyWith(fontSize: 24),
                      ),
                    ],
                  ),
                  // Spacer expands to fill the available space, pushing the icons to the right.
                  const Spacer(),
                  // An icon button for notifications.
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_outlined,
                      size: 28,
                    ),
                    onPressed: () {},
                  ),
                  // An icon button for a side menu or drawer.
                  IconButton(
                    icon: const Icon(Icons.menu, size: 28),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            // A SizedBox provides a fixed amount of space between widgets.
            const SizedBox(height: 24),

            // The main search card.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 10,
                shadowColor: Colors.black12,
                color: AppColors.cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // A text field for the starting location.
                      const TextField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.trip_origin),
                          hintText: 'From',
                        ),
                      ),
                      const SizedBox(height: 12),
                      // A text field for the destination.
                      const TextField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.location_on),
                          hintText: 'To',
                        ),
                      ),
                      const SizedBox(height: 12),
                      // A text field for the date.
                      const TextField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.calendar_today),
                          hintText: 'Date',
                        ),
                      ),
                      const SizedBox(height: 20),
                      // A button that spans the full width of the card.
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            /* Search logic will be added later */
                          },
                          child: const Text('Search Buses'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Header for the "Routes" section.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Routes", style: AppTextStyles.bodyText),
                  TextButton(onPressed: () {}, child: const Text("See more")),
                ],
              ),
            ),

            // This SizedBox constrains the height of the horizontal ListView.
            // A horizontal ListView inside a vertical ListView needs a fixed height.
            SizedBox(
              height: 100,
              // ListView.builder is an efficient way to create lists.
              child: ListView.builder(
                // This makes the list scroll horizontally.
                scrollDirection: Axis.horizontal,
                // Adds padding to the left of the list so it doesn't touch the edge.
                padding: const EdgeInsets.only(left: 16.0),
                // We are creating 4 static cards for the UI demonstration.
                itemCount: 4,
                itemBuilder: (context, index) {
                  // Returns a reusable card widget for each item in the list.
                  return const RouteCard(
                    startPoint: 'Westlands',
                    endPoint: 'Utawala',
                    fare: '150',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// A smaller, reusable widget for displaying a single route.
class RouteCard extends StatelessWidget {
  final String startPoint;
  final String endPoint;
  final String fare;

  const RouteCard({
    super.key,
    required this.startPoint,
    required this.endPoint,
    required this.fare,
  });

  @override
  Widget build(BuildContext context) {
    // A Container to set a specific width for the card.
    return Container(
      width: 250,
      // Adds margin to the right of each card.
      margin: const EdgeInsets.only(right: 12.0),
      // The Card widget provides the material design card look with elevation.
      child: Card(
        color: AppColors.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          // A Row to layout the card's content horizontally.
          child: Row(
            children: [
              const Icon(Icons.route, color: AppColors.primaryColor),
              const SizedBox(width: 12),
              // Expanded makes the Column take up all available horizontal space.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      startPoint,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      endPoint,
                      style: const TextStyle(color: AppColors.subtleTextColor),
                    ),
                  ],
                ),
              ),
              // The price text is at the end of the row.
              Text(
                "KES $fare",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
