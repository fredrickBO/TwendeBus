// lib/features/tickets/screens/ticket_details_screen.dart
import 'package:flutter/material.dart';
import 'package:twende_bus_ui/core/models/booking_model.dart';
import 'package:twende_bus_ui/core/models/trip_model.dart'; // We already pass this
import 'package:twende_bus_ui/core/theme/app_theme.dart';

class TicketDetailsScreen extends StatelessWidget {
  final BookingModel booking;
  final TripModel trip;

  const TicketDetailsScreen({
    super.key,
    required this.booking,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("View Ticket")),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                "Ticket No: ${booking.id.substring(0, 8).toUpperCase()}",
                style: AppTextStyles.headline2.copyWith(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Image.asset('assets/images/bus_icon.png', height: 40),
              title: Text(
                trip.busPlate,
                style: AppTextStyles.headline2.copyWith(fontSize: 18),
              ),
              // THE FIX: The trip model does not have startPoint/endPoint.
              // We can show the bus company instead for context.
              subtitle: Text(trip.busCompany, style: AppTextStyles.labelText),
              trailing: Text(
                "KES ${booking.farePaid.toInt()}",
                style: AppTextStyles.bodyText.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
