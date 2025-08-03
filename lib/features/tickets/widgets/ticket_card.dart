// lib/features/tickets/widgets/ticket_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twende_bus_ui/core/models/booking_model.dart';
import 'package:twende_bus_ui/core/models/trip_model.dart';
import 'package:twende_bus_ui/core/providers.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';
//import 'package:twende_bus_ui/features/tickets/screens/ticket_details_screen.dart';
import 'package:twende_bus_ui/features/tickets/ticket_details_screen.dart';

class TicketCard extends ConsumerWidget {
  final BookingModel booking;
  const TicketCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch the trip details for this booking.
    final tripDetailsFuture = ref
        .watch(firestoreServiceProvider)
        .getTripDetails(booking.tripId);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      // THE FIX: Use a FutureBuilder to wait for trip details.
      child: FutureBuilder<TripModel>(
        future: tripDetailsFuture,
        builder: (context, tripSnapshot) {
          if (!tripSnapshot.hasData)
            return const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            );
          final trip = tripSnapshot.data!;

          // THE FIX: Now fetch the route details using the trip's routeId.
          final routeDetails = ref.watch(routeDetailsProvider(trip.routeId));

          return routeDetails.when(
            data: (route) {
              return Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Image.asset(
                      'assets/images/bus_icon.png',
                      height: 40,
                    ),
                    title: Text(
                      trip.busCompany,
                      style: AppTextStyles.bodyText.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // THE FIX: Use the route data for start/end points.
                    subtitle: Text("${route.startPoint} -- ${route.endPoint}"),
                    trailing: Text(
                      "KES ${booking.farePaid.toInt()}",
                      style: AppTextStyles.bodyText.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          // THE FIX: Pass both the booking and trip objects.
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TicketDetailsScreen(
                                booking: booking,
                                trip: trip,
                              ),
                            ),
                          );
                        },
                        child: const Text("View Ticket"),
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => const SizedBox(
              height: 100,
              child: Center(child: Text("Error")),
            ),
          );
        },
      ),
    );
  }
}
