// lib/features/booking/screens/ride_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:twende_bus_ui/core/models/booking_model.dart';
import 'package:twende_bus_ui/core/models/route_model.dart';
import 'package:twende_bus_ui/core/models/trip_model.dart';
import 'package:twende_bus_ui/core/providers.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';
import 'package:twende_bus_ui/features/booking/screens/cancel_ride_screen.dart';

class RideDetailsScreen extends ConsumerWidget {
  final BookingModel booking;

  const RideDetailsScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsyncValue = ref.watch(tripStreamProvider(booking.tripId));

    return Scaffold(
      appBar: AppBar(title: const Text("Ride Details")),
      body: tripAsyncValue.when(
        data: (trip) {
          final routeAsyncValue = ref.watch(routeDetailsProvider(trip.routeId));

          return routeAsyncValue.when(
            data: (route) {
              // We calculate the bus location from the live trip data.
              final LatLng busLocation = LatLng(
                trip.currentLocation?.latitude ??
                    -1.286389, // Default to Nairobi CBD if null
                trip.currentLocation?.longitude ?? 36.817223,
              );

              return Column(
                // Changed to Column for better structure
                children: [
                  // The map container
                  SizedBox(
                    height: 300,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: busLocation,
                        zoom: 14.0,
                      ),
                      // THE FIX: Use the 'busLocation' variable here.
                      markers: {
                        Marker(
                          markerId: MarkerId(trip.id),
                          position: busLocation,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueAzure,
                          ),
                        ),
                      },
                    ),
                  ),
                  // The rest of the details in a scrollable list
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(24.0),
                      children: [
                        Text(
                          DateFormat('d MMMM yyyy').format(trip.departureTime),
                          style: AppTextStyles.bodyText,
                        ),
                        const SizedBox(height: 16),
                        // THE FIX: Pass all required data to the helper method.
                        _buildJourneyTimeline(
                          trip: trip,
                          booking: booking,
                          route: route,
                        ),
                        const Divider(height: 32),
                        _buildDetailRow(
                          "Total price for ${booking.seatNumbers.length} passenger(s)",
                          "KES ${booking.farePaid.toInt()}",
                        ),
                        const Divider(height: 32),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            radius: 25,
                            backgroundColor: AppColors.cardColor,
                          ),
                          title: Text(
                            "John Kamau",
                            style: AppTextStyles.bodyText.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text("Contact John"),
                          trailing: const Icon(
                            Icons.phone,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) =>
                const Center(child: Text("Could not load route details.")),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            const Center(child: Text("Could not load trip details.")),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("Track Ride"),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CancelRideScreen(booking: booking),
                  ),
                ),
                child: const Text("Cancel Ride"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method now uses live data passed to it.
  Widget _buildJourneyTimeline({
    required TripModel trip,
    required BookingModel booking,
    required RouteModel route,
  }) {
    return Row(
      children: [
        Column(
          children: const [
            Icon(Icons.circle, size: 12, color: AppColors.primaryColor),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                "⋮",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.subtleTextColor,
                ),
              ),
            ),
            Icon(Icons.location_on, size: 16, color: AppColors.secondaryColor),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('h:mm a').format(trip.departureTime),
              style: AppTextStyles.labelText,
            ),
            Text(
              route.startPoint,
              style: AppTextStyles.bodyText.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(booking.startStop, style: AppTextStyles.labelText),
            const SizedBox(height: 20),
            Text(
              DateFormat(
                'h:mm a',
              ).format(trip.departureTime.add(const Duration(minutes: 20))),
              style: AppTextStyles.labelText,
            ),
            Text(
              route.endPoint,
              style: AppTextStyles.bodyText.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(booking.endStop, style: AppTextStyles.labelText),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.bodyText),
        Text(
          value,
          style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
