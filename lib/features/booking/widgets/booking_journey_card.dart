// lib/features/booking/widgets/booking_journey_card.dart
import 'package:flutter/material.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';
import 'package:twende_bus_ui/features/booking/screens/ride_details_screen.dart';

class BookingJourneyCard extends StatelessWidget {
  final String startPoint,
      startStop,
      endPoint,
      endStop,
      time,
      date,
      passengerCount,
      fare;
  final bool isCancelled;

  const BookingJourneyCard({
    super.key,
    required this.startPoint,
    required this.startStop,
    required this.endPoint,
    required this.endStop,
    required this.time,
    required this.date,
    required this.passengerCount,
    required this.fare,
    this.isCancelled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isCancelled) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RideDetailsScreen()),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Top Row: The journey route
              Row(
                children: [
                  _buildPoint(startPoint, startStop),
                  const Spacer(),
                  _buildDottedLine(),
                  Column(
                    children: [
                      const Icon(
                        Icons.directions_bus,
                        color: AppColors.subtleTextColor,
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.subtleTextColor,
                        ),
                      ),
                    ],
                  ),
                  _buildDottedLine(),
                  const Spacer(),
                  _buildPoint(endPoint, endStop, alignRight: true),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              // Bottom Row: Date, Passengers, and Fare
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.subtleTextColor,
                  ),
                  const SizedBox(width: 4),
                  Text(date, style: AppTextStyles.labelText),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.person,
                    size: 16,
                    color: AppColors.subtleTextColor,
                  ),
                  const SizedBox(width: 4),
                  Text(passengerCount, style: AppTextStyles.labelText),
                  const Spacer(),
                  Text(
                    "KES. $fare",
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
        ),
      ),
    );
  }

  // Helper for the dotted line
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

  // Helper for the start and end point text
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
}
