// lib/features/booking/screens/seat_selection_screen.dart
import 'package:flutter/material.dart';
//import 'package:flutter_svg/flutter_svg.dart';
import 'package:twende_bus_ui/core/models/route_model.dart';
import 'package:twende_bus_ui/core/models/trip_model.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';
import 'package:twende_bus_ui/features/booking/screens/points_selection_screen.dart';

// We convert this to a StatefulWidget to manage the user's seat selection.
class SeatSelectionScreen extends StatefulWidget {
  final TripModel trip;
  final RouteModel route;
  const SeatSelectionScreen({
    super.key,
    required this.trip,
    required this.route,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  // This set will hold the seat numbers that the user has selected.
  // Using a Set is efficient as it automatically handles duplicates.
  final Set<String> _selectedSeats = {};
  // This set represents seats that are already booked by others.
  late final Set<String> _bookedSeats;

  // The precise layout map for a Super Metro bus.
  // We use 5 columns to accommodate the back row.
  late final List<String> _seatLayout;

  @override
  void initState() {
    super.initState();
    // Initialize the booked seats from the trip model.
    _bookedSeats = widget.trip.bookedSeats.toSet();
    // Define the seat layout for the bus.
    _seatLayout = _generateSeatLayout(widget.trip.capacity);
  }

  // This function generates the seat layout based on the bus capacity.
  List<String> _generateSeatLayout(int capacity) {
    List<String> layout = [];
    //adding the steering wheel row
    layout.addAll(["", "AISLE", "", "AISLE", "DRV"]);

    //driver seat row
    layout.addAll(["A1", "A2", "AISLE", "", "DRIVER"]);

    //middle rows
    //calculate hoe many seats are left to be drawn in the middle and back rows
    //Total passenger seats = capacity -1(driver's seat)
    //Seats Already drawn = 2(A1, A2)
    //seats in the back row = 5
    int middleSeatsToDraw = (capacity - 1) - 2 - 5;
    int middleRows = middleSeatsToDraw ~/ 4; // 4 seats per row

    //define characters for the middle rows
    List<String> rowChars = ["B", "B", "C", "D", "E", "F", "G"];

    //loop to add middle rows
    for (int i = 0; i < middleRows; i++) {
      String char = rowChars[i];
      layout.addAll(["${char}1", "${char}2", "AISLE", "${char}3", "${char}4"]);
    }
    //back row
    String lastChar = rowChars[middleRows];
    layout.addAll([
      "${lastChar}1",
      "${lastChar}2",
      "${lastChar}5",
      "${lastChar}3",
      "${lastChar}4",
    ]);
    return layout;
  }

  // This function handles the logic when a user taps a seat.
  void _onSeatTapped(String seatNumber) {
    // A user cannot select a seat that is already booked.
    if (_bookedSeats.contains(seatNumber)) {
      return; // Do nothing
    }

    // `setState` is called to rebuild the UI with the new selection state.
    setState(() {
      // If the seat is already in our selected set, tapping it again removes it (deselects).
      if (_selectedSeats.contains(seatNumber)) {
        _selectedSeats.remove(seatNumber);
      } else {
        // Otherwise, we add it to the set of selected seats.
        _selectedSeats.add(seatNumber);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.trip.busCompany), centerTitle: true),
      body: Column(
        children: [
          // Subtitle and legend section
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "${widget.trip.busPlate} ${widget.route.startPoint} - ${widget.route.endPoint}",
                  style: AppTextStyles.labelText,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLegendItem("Available", const Color(0xFFE0E0E0)),
                    _buildLegendItem("Selected", AppColors.secondaryColor),
                    _buildLegendItem("Booked", AppColors.primaryColor),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 24),

          // The main grid for the bus layout
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                // We define the grid with 5 columns.
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                // The number of items is the length of our layout map.
                itemCount: _seatLayout.length,
                itemBuilder: (context, index) {
                  final seatLabel = _seatLayout[index];

                  // Based on the label in our map, we build the correct widget.
                  if (seatLabel == "DRV") {
                    return Image.asset(
                      'assets/images/steering_wheel.png',
                      height: 40,
                    ); // Steering wheel icon
                  } else if (seatLabel == "DRIVER") {
                    return SeatWidget(
                      label: "A3",
                      isBooked: true,
                      isSelected: false,
                      isDriver: true,
                      onTap: () {},
                    ); // Render an empty space.
                  } else if (seatLabel == "AISLE" || seatLabel.isEmpty) {
                    return const SizedBox.shrink(); // Render an empty space.
                  } else {
                    // For a normal seat, we build the SeatWidget.
                    return SeatWidget(
                      label: seatLabel,
                      // We check if the seat is in our booked or selected sets.
                      isBooked: _bookedSeats.contains(seatLabel),
                      isSelected: _selectedSeats.contains(seatLabel),
                      // We pass the tap handler function to the widget.
                      onTap: () => _onSeatTapped(seatLabel),
                    );
                  }
                },
              ),
            ),
          ),
          // The bottom confirm button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // The button is disabled if no seats are selected.
                onPressed: _selectedSeats.isNotEmpty
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PointsSelectionScreen(route: widget.route),
                          ),
                        );
                      }
                    : null, // Setting onPressed to null disables the button.
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  // The button is visually de-emphasized when disabled.
                  disabledBackgroundColor: AppColors.subtleTextColor
                      .withOpacity(0.5),
                ),
                child: const Text("Confirm"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for the legend items.
  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: AppColors.subtleTextColor.withOpacity(0.5),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(text, style: AppTextStyles.labelText),
      ],
    );
  }
}

// Reusable Seat Widget for this new design
class SeatWidget extends StatelessWidget {
  final String label;
  final bool isBooked;
  final bool isSelected;
  final bool isDriver;
  final VoidCallback onTap;

  const SeatWidget({
    super.key,
    required this.label,
    required this.isBooked,
    required this.isSelected,
    this.isDriver = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the color based on the seat's state.
    Color color = isBooked
        ? AppColors.primaryColor
        : isSelected
        ? AppColors.secondaryColor
        : const Color(0xFFE0E0E0); // Light grey for available
    Color textColor = isBooked || isSelected
        ? Colors.white
        : AppColors.textColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: isDriver
              ? Icon(Icons.person, color: textColor, size: 20)
              : Text(
                  label,
                  style: AppTextStyles.bodyText.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
        ),
      ),
    );
  }
}
