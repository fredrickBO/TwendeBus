// lib/features/tickets/screens/tickets_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twende_bus_ui/core/providers.dart';
import 'package:twende_bus_ui/features/tickets/widgets/ticket_card.dart'; // The card from your first design

class TicketsListScreen extends ConsumerWidget {
  const TicketsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //watch live list of user's bookings
    final bookingsAsync = ref.watch(userBookingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text("Tickets")),
      body: bookingsAsync.when(
        data: (bookings) {
          // For this screen, we only show active/confirmed tickets.
          final activeBookings = bookings
              .where((b) => b.status == 'active' || b.status == 'confirmed')
              .toList();
          if (activeBookings.isEmpty) {
            return const Center(child: Text("You have no active tickets."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: activeBookings.length,
            itemBuilder: (context, index) {
              return TicketCard(booking: activeBookings[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }
}
