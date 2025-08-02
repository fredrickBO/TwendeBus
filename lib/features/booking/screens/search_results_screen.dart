// lib/features/booking/screens/search_results_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:twende_bus_ui/core/models/trip_model.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';
import 'package:twende_bus_ui/features/booking/screens/seat_selection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twende_bus_ui/core/models/route_model.dart';
import 'package:twende_bus_ui/core/providers.dart';
import 'package:twende_bus_ui/core/models/search_params.dart';

class SearchResultsScreen extends ConsumerWidget {
  final RouteModel route;
  final String searchDateString;
  const SearchResultsScreen({
    super.key,
    required this.route,
    required this.searchDateString,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchParams = SearchParams(
      routeId: route.id,
      dateString: searchDateString,
    );
    final tripsAsyncValue = ref.watch(tripsForRouteProvider(searchParams));

    return Scaffold(
      extendBodyBehindAppBar: true, // Allows the body to go behind the AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Makes AppBar transparent
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: BackButton(color: AppColors.textColor),
          ),
        ),
        title: const Text("Available Buses"),
      ),
      // THE FIX: Replace Stack with a simpler Column layout
      body: Column(
        children: [
          // 1. Map Placeholder with a fixed height
          Container(
            height: 250,
            color: const Color(0xFFE5E5E5),
            child: const Center(
              child: Icon(Icons.map, size: 100, color: Colors.grey),
            ),
          ),
          // 2. Header for the list
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Buses for on ${DateFormat('EEEE, MMMM d').format(DateTime.parse(searchDateString))}",
              style: AppTextStyles.headline2,
            ),
          ),
          // 3. The list of buses, wrapped in an Expanded widget
          Expanded(
            child: tripsAsyncValue.when(
              data: (trips) {
                if (trips.isEmpty) {
                  return const Center(
                    child: Text("No trips and buses available for now"),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    final trip = trips[index];
                    return BusInfoCard(trip: trip, route: route);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text("Error: $error")),
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable card for each bus in the list
class BusInfoCard extends StatelessWidget {
  final TripModel trip;
  final RouteModel route;
  final bool isRecommended;

  const BusInfoCard({
    super.key,
    required this.trip,
    required this.route,
    this.isRecommended = true,
  });

  @override
  Widget build(BuildContext context) {
    final int actualAvailableSeats =
        trip.capacity - 1 - trip.bookedSeats.length;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SeatSelectionScreen(route: route, trip: trip),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isRecommended
                ? AppColors.secondaryColor
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Image.asset('assets/images/bus_icon.png', height: 50),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.busCompany,
                    style: AppTextStyles.bodyText.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      //trim departure time to only show hours and minutes, show in 12-hour format
                      Text(
                        "${trip.departureTime.hour % 12}:${trip.departureTime.minute.toString().padLeft(2, '0')} ${trip.departureTime.hour >= 12 ? 'P.M.' : 'A.M.'}",
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text("${trip.rating}"),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "KES. ${trip.fare.toInt()}",
                    style: AppTextStyles.bodyText.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.person,
                        color: AppColors.subtleTextColor,
                        size: 16,
                      ),
                      Text("$actualAvailableSeats"),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
