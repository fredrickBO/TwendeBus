// lib/features/booking/screens/bookings_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twende_bus_ui/core/models/booking_model.dart';
import 'package:twende_bus_ui/core/models/trip_model.dart';
import 'package:twende_bus_ui/core/providers.dart';
import 'package:twende_bus_ui/features/booking/widgets/booking_journey_card.dart';

class BookingsListScreen extends ConsumerWidget {
  const BookingsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            // THE FIX: We create a list of FutureBuilders to fetch trip details for filtering.
            // This is an advanced pattern but necessary to get the departure times.
            final confirmedBookings = bookings
                .where((b) => b.status == 'active' || b.status == 'confirmed')
                .toList();
            final cancelledBookings = bookings
                .where((b) => b.status == 'cancelled')
                .toList();

            return TabBarView(
              children: [
                // Active Tab
                BookingListView(
                  bookings: confirmedBookings,
                  filter: BookingFilter.active,
                ),
                // Completed Tab
                BookingListView(
                  bookings: confirmedBookings,
                  filter: BookingFilter.completed,
                ),
                // Cancelled Tab
                BookingListView(
                  bookings: cancelledBookings,
                  filter: BookingFilter.cancelled,
                ),
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

// An enum to define our filters
enum BookingFilter { active, completed, cancelled }

class BookingListView extends ConsumerWidget {
  final List<BookingModel> bookings;
  final BookingFilter filter;
  const BookingListView({
    super.key,
    required this.bookings,
    required this.filter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (bookings.isEmpty) {
      return Center(child: Text("No bookings found in this category."));
    }

    // We build the list based on the filter.
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];

        // For Active/Completed, we need to check the trip's departure time.
        if (filter == BookingFilter.active ||
            filter == BookingFilter.completed) {
          final tripFuture = ref
              .watch(firestoreServiceProvider)
              .getTripDetails(booking.tripId);
          return FutureBuilder<TripModel>(
            future: tripFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink(); // Don't show while loading
              }
              final trip = snapshot.data!;
              final now = DateTime.now();

              if (filter == BookingFilter.active &&
                  trip.departureTime.isAfter(now)) {
                return BookingJourneyCard(booking: booking);
              }
              if (filter == BookingFilter.completed &&
                  trip.departureTime.isBefore(now)) {
                return BookingJourneyCard(booking: booking);
              }
              return const SizedBox.shrink(); // Hide if it doesn't match the time filter
            },
          );
        } else {
          // For Cancelled, we don't need to check the time.
          return BookingJourneyCard(booking: booking);
        }
      },
    );
  }
}
