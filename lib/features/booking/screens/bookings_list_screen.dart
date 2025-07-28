// lib/features/booking/screens/bookings_list_screen.dart
import 'package:flutter/material.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';
import 'package:twende_bus_ui/features/booking/widgets/booking_journey_card.dart'; // We will create this next

class BookingsListScreen extends StatefulWidget {
  const BookingsListScreen({super.key});

  @override
  State<BookingsListScreen> createState() => _BookingsListScreenState();
}

class _BookingsListScreenState extends State<BookingsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondaryColor,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.subtleTextColor,

          // Customizing the tab indicator
          //width
          indicatorWeight: 1,
          //height
          indicatorPadding: const EdgeInsets.symmetric(horizontal: 10.0),
          //background color
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color.fromARGB(255, 32, 159, 239),
            //
          ),
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Content for "Active" tab
          _buildActiveBookings(),
          // Content for "Completed" tab
          _buildCompletedBookings(),
          // Content for "Cancelled" tab
          _buildCancelledBookings(),
        ],
      ),
    );
  }

  // Helper widget for the "Active" tab
  Widget _buildActiveBookings() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: const [
        BookingJourneyCard(
          startPoint: "Utawala",
          startStop: "Shooters",
          endPoint: "Westlands",
          endStop: "Naivas",
          time: "6:30am",
          date: "Today",
          passengerCount: "1",
          fare: "150",
          isCancelled: false,
        ),
        BookingJourneyCard(
          startPoint: "Utawala",
          startStop: "Shooters",
          endPoint: "Westlands",
          endStop: "Naivas",
          time: "6:30am",
          date: "Tomorrow",
          passengerCount: "1",
          fare: "150",
          isCancelled: false,
        ),
      ],
    );
  }

  // Helper widget for the "Completed" tab
  Widget _buildCompletedBookings() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: const [
        // This card will also be tappable to view past ride details
        BookingJourneyCard(
          startPoint: "CBD",
          startStop: "Kencom",
          endPoint: "Ngong",
          endStop: "Racecourse",
          time: "2:00pm",
          date: "Yesterday",
          passengerCount: "1",
          fare: "120",
          isCancelled: false, // isCancelled is false for completed rides
        ),
      ],
    );
  }

  // Helper widget for the "Cancelled" tab, matching the design
  Widget _buildCancelledBookings() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: const [
        BookingJourneyCard(
          startPoint: "Utawala",
          startStop: "Shooters",
          endPoint: "Westlands",
          endStop: "Naivas",
          time: "6:30am",
          date: "Today",
          passengerCount: "1",
          fare: "-150",
          isCancelled: true,
        ),
        BookingJourneyCard(
          startPoint: "Utawala",
          startStop: "Shooters",
          endPoint: "Westlands",
          endStop: "Naivas",
          time: "6:30am",
          date: "Tomorrow",
          passengerCount: "1",
          fare: "-75", // Example of different fare
          isCancelled: true,
        ),
      ],
    );
  }
}
