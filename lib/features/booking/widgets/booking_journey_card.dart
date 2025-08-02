// lib/features/booking/widgets/booking_journey_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:twende_bus_ui/core/models/booking_model.dart';
import 'package:twende_bus_ui/core/models/trip_model.dart';
import 'package:twende_bus_ui/core/providers.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';
import 'package:twende_bus_ui/features/booking/screens/ride_details_screen.dart';

class BookingJourneyCard extends ConsumerWidget {
  final BookingModel booking;

  const BookingJourneyCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This code remains the same, but it's now calling the centralized provider.
    final tripDetailsFuture = ref
        .watch(firestoreServiceProvider)
        .getTripDetails(booking.tripId);
    final isCancelled = booking.status == 'cancelled';

    return GestureDetector(
      onTap: () {
        if (!isCancelled) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RideDetailsScreen(booking: booking),
            ),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: FutureBuilder<TripModel>(
          future: tripDetailsFuture,
          builder: (context, tripSnapshot) {
            if (tripSnapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 140,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (tripSnapshot.hasError || !tripSnapshot.hasData) {
              return const SizedBox(
                height: 140,
                child: Center(child: Text("Could not load trip details.")),
              );
            }

            final trip = tripSnapshot.data!;
            // This now correctly calls the provider from its central location.
            final routeDetails = ref.watch(routeDetailsProvider(trip.routeId));

            return routeDetails.when(
              data: (route) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildPoint(route.startPoint, booking.startStop),
                          const Spacer(),
                          _buildDottedLine(),
                          Column(
                            children: [
                              const Icon(
                                Icons.directions_bus,
                                color: AppColors.subtleTextColor,
                              ),
                              Text(
                                DateFormat('h:mm a').format(trip.departureTime),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.subtleTextColor,
                                ),
                              ),
                            ],
                          ),
                          _buildDottedLine(),
                          const Spacer(),
                          _buildPoint(
                            route.endPoint,
                            booking.endStop,
                            alignRight: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: AppColors.subtleTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat(
                              'MMM d, yyyy',
                            ).format(trip.departureTime),
                            style: AppTextStyles.labelText,
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.person,
                            size: 16,
                            color: AppColors.subtleTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${booking.seatNumbers.length}",
                            style: AppTextStyles.labelText,
                          ),
                          const Spacer(),
                          Text(
                            "KES. ${booking.farePaid.toInt()}",
                            style: AppTextStyles.bodyText.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isCancelled
                                  ? AppColors.errorColor
                                  : AppColors.textColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox(
                height: 140,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => const SizedBox(
                height: 140,
                child: Center(child: Text("Could not load route details.")),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Your excellent helper methods are preserved and unchanged.
Widget _buildDottedLine() {
  return const Expanded(
    child: Text(
      '...................',
      maxLines: 1,
      style: TextStyle(color: AppColors.subtleTextColor),
      textAlign: TextAlign.center,
    ),
  );
}

Widget _buildPoint(String title, String subtitle, {bool alignRight = false}) {
  return Column(
    crossAxisAlignment: alignRight
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold),
      ),
      Text(subtitle, style: AppTextStyles.labelText),
    ],
  );
}
