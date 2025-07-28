// lib/features/booking/screens/seat_selection_screen.dart
import 'package:flutter/material.dart';
//import 'package:flutter_svg/flutter_svg.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';
import 'package:twende_bus_ui/features/booking/screens/points_selection_screen.dart';

// We convert this to a StatefulWidget to manage the user's seat selection.
class SeatSelectionScreen extends StatefulWidget {
  const SeatSelectionScreen({super.key});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  // This set will hold the seat numbers that the user has selected.
  // Using a Set is efficient as it automatically handles duplicates.
  final Set<String> _selectedSeats = {};
  // This set represents seats that are already booked by others.
  final Set<String> _bookedSeats = {"C2", "E4", "G4"};

  // The precise layout map for a Super Metro bus.
  // We use 5 columns to accommodate the back row.
  final List<String> seatLayout = [
    // Steering wheel row
    "", "AISLE", "", "AISLE", "DRV",
    // Front passenger row
    "A1", "A2", "AISLE", "AISLE", "DRIVER",
    // Middle rows
    "B1", "B2", "AISLE", "B3", "B4",
    "C1", "C2", "AISLE", "C3", "C4",
    "D1", "D2", "AISLE", "D3", "D4",
    "E1", "E2", "AISLE", "E3", "E4",
    "F1", "F2", "AISLE", "F3", "F4",
    // Back row with 5 seats
    "G1", "G2", "G5", "G3", "G4",
  ];

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
      appBar: AppBar(title: const Text("Super Metro"), centerTitle: true),
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
                  "KDR 145G Utawala - Westlands",
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
                itemCount: seatLayout.length,
                itemBuilder: (context, index) {
                  final seatLabel = seatLayout[index];

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
                            builder: (_) => const PointsSelectionScreen(),
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
