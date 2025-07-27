// lib/features/tickets/screens/tickets_list_screen.dart
import 'package:flutter/material.dart';
import 'package:twende_bus_ui/features/booking/widgets/booking_card.dart'; // The card from your first design

class TicketsListScreen extends StatelessWidget {
  const TicketsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tickets")),
      // We reuse the first BookingCard widget here as it matches the design for this page.
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          BookingCard(
            busName: "Jade KDR 145G",
            startPoint: "Westlands",
            endPoint: "Utawala",
            fare: "100",
          ),
          BookingCard(
            busName: "KDG 145T",
            startPoint: "Utawala",
            endPoint: "Westlands",
            fare: "100",
          ),
        ],
      ),
    );
  }
}
