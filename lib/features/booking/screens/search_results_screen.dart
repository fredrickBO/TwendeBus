// lib/features/booking/screens/search_results_screen.dart
import 'package:flutter/material.dart';
import 'package:twende_bus_ui/core/models/trip_model.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';
import 'package:twende_bus_ui/features/booking/screens/seat_selection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twende_bus_ui/core/models/route_model.dart';
import 'package:twende_bus_ui/core/providers.dart';

class SearchResultsScreen extends ConsumerWidget {
  final RouteModel route;
  const SearchResultsScreen({super.key, required this.route});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsyncValue = ref.watch(tripsForRouteProvider(route.id));
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
        title: const Text("Booking"),
      ),
      body: Stack(
        children: [
          // 1. Map Placeholder (takes up the full screen)
          Container(
            color: const Color(
              0xFFE5E5E5,
            ), // A light grey for the map placeholder
            child: const Center(
              child: Icon(Icons.map, size: 100, color: Colors.grey),
            ),
          ),
          // 2. DraggableScrollableSheet for the slide-up panel
          DraggableScrollableSheet(
            initialChildSize: 0.45, // Starts at 45% of the screen height
            minChildSize: 0.45, // Can't be dragged lower than 45%
            maxChildSize: 0.8, // Can be dragged up to 80%
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0),
                  ),
                ),
                child: Column(
                  children: [
                    // Handle for the draggable sheet
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    // The list of buses
                    Expanded(
                      child: tripsAsyncValue.when(
                        data: (trips) {
                          if (trips.isEmpty) {
                            return const Center(
                              child: Text("No trips available for this route."),
                            );
                          }
                          return ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.all(16.0),
                            itemCount: trips.length,
                            itemBuilder: (context, index) {
                              final trip = trips[index];
                              return BusInfoCard(
                                trip: trip,
                                route: route,
                                isRecommended:
                                    index == 0, // Highlight the first one
                              );
                            },
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, stack) =>
                            Center(child: Text("Error: $error")),
                      ),
                    ),
                    // // Continue Button
                    // Padding(
                    //   padding: const EdgeInsets.all(16.0),
                    //   child: SizedBox(
                    //     width: double.infinity,
                    //     child: ElevatedButton(
                    //       onPressed: () {
                    //         Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //             builder: (_) => const SeatSelectionScreen(),
                    //           ),
                    //         );
                    //       },
                    //       child: const Text('Continue'),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              );
            },
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
  // final String busCompany;
  // final int fare;
  // final int seats;
  final bool isRecommended;

  const BusInfoCard({
    super.key,
    required this.trip,
    required this.route,
    // required this.busCompany,
    // required this.fare,
    // required this.seats,
    this.isRecommended = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SeatSelectionScreen(route: route)),
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
                      const Text("1:00 A.M."),
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
                      Text("${trip.availableSeats}"),
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
