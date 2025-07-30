// lib/features/booking/widgets/booking_card.dart
import 'package:flutter/material.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';
//import 'package:twende_bus_ui/features/tickets/screens/ticket_details_screen.dart';
import 'package:twende_bus_ui/features/tickets/ticket_details_screen.dart'; // We will create this next

// A reusable stateless widget for displaying booking information.
class BookingCard extends StatelessWidget {
  // These are the properties the widget will accept.

  final String busName;
  final String startPoint;
  final String endPoint;
  final String fare;

  // The constructor requires these properties to be provided.
  const BookingCard({
    super.key,
    required this.busName,
    required this.startPoint,
    required this.endPoint,
    required this.fare,
  });

  @override
  Widget build(BuildContext context) {
    // The main container widget for the card.
    return Card(
      // Adds a margin at the bottom to separate cards in a list.
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      // The content of the card.
      child: Padding(
        padding: const EdgeInsets.all(11.0),
        // A Column to arrange the card's content vertically.
        child: Column(
          children: [
            // This Row holds the top part of the card (bus info and price).
            Row(
              children: [
                // A container for the bus image.
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.subtleTextColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset('assets/images/bus_icon.png', height: 30),
                ),
                const SizedBox(width: 12),
                // A Column for the bus name and route.
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      busName,
                      style: AppTextStyles.headline2.copyWith(fontSize: 14),
                    ),
                    Text(
                      "$startPoint -- $endPoint",
                      style: AppTextStyles.labelText.copyWith(fontSize: 12),
                    ),
                  ],
                ),
                // Pushes the fare to the far right.
                const Spacer(),
                Text(
                  "KES $fare",
                  style: AppTextStyles.headline2.copyWith(
                    color: AppColors.primaryColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // The button to view the ticket details.
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // When pressed, navigates to the TicketDetailsScreen.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TicketDetailsScreen(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('View Ticket'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
