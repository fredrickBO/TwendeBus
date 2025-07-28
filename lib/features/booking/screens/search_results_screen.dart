// lib/features/booking/screens/search_results_screen.dart
import 'package:flutter/material.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';
import 'package:twende_bus_ui/features/booking/screens/seat_selection.dart';

class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                      child: ListView(
                        controller: scrollController, // Important for scrolling
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: const [
                          BusInfoCard(
                            busCompany: 'Super Metro',
                            fare: 100,
                            seats: 30,
                          ),
                          BusInfoCard(
                            busCompany: 'Metro Trans',
                            fare: 130,
                            seats: 12,
                            isRecommended: false,
                          ),
                          BusInfoCard(
                            busCompany: 'Enabled',
                            fare: 150,
                            seats: 24,
                            isRecommended: false,
                          ),
                        ],
                      ),
                    ),
                    // Continue Button
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SeatSelectionScreen(),
                              ),
                            );
                          },
                          child: const Text("Continue"),
                        ),
                      ),
                    ),
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
  final String busCompany;
  final int fare;
  final int seats;
  final bool isRecommended;

  const BusInfoCard({
    super.key,
    required this.busCompany,
    required this.fare,
    required this.seats,
    this.isRecommended = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isRecommended ? AppColors.secondaryColor : Colors.transparent,
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
                  busCompany,
                  style: AppTextStyles.bodyText.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Text("1:00 A.M."),
                    SizedBox(width: 8),
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Text("4.6"),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "KES. $fare",
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
                    Text("$seats"),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
