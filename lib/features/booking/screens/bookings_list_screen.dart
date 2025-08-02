// lib/features/booking/screens/bookings_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twende_bus_ui/core/models/booking_model.dart';
import 'package:twende_bus_ui/core/providers.dart';
import 'package:twende_bus_ui/features/booking/widgets/booking_journey_card.dart';

class BookingsListScreen extends ConsumerWidget {
  const BookingsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This line will now work correctly.
    final bookingsAsync = ref.watch(userBookingsProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Bookings"),
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            tabs: [
              Tab(text: "Active"),
              Tab(text: "Completed"),
              Tab(text: "Cancelled"),
            ],
          ),
        ),
        body: bookingsAsync.when(
          data: (bookings) {
            // Because the provider now has a type, the compiler knows that 'b' is a BookingModel,
            // so `b.status` is a valid property. The error is gone.
            final active = bookings.where((b) => b.status == 'active').toList();
            final completed = bookings
                .where((b) => b.status == 'completed')
                .toList();
            final cancelled = bookings
                .where((b) => b.status == 'cancelled')
                .toList();

            return TabBarView(
              children: [
                BookingListView(bookings: active),
                BookingListView(bookings: completed),
                BookingListView(bookings: cancelled),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text("Error: $err")),
        ),
      ),
    );
  }
}

class BookingListView extends StatelessWidget {
  final List<BookingModel> bookings;
  const BookingListView({super.key, required this.bookings});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return const Center(child: Text("No bookings found in this category."));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return BookingJourneyCard(booking: bookings[index]);
      },
    );
  }
}
