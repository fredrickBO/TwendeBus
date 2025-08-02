// lib/features/booking/screens/ride_confirmation_screen.dart
import 'package:flutter/material.dart';
import 'package:twende_bus_ui/core/models/booking_model.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';
//import 'package:twende_bus_ui/features/booking/screens/cancel_ride_screen.dart';
import 'package:twende_bus_ui/features/booking/screens/ride_details_screen.dart';
import 'package:twende_bus_ui/shared/widgets/bottom_nav_bar.dart';

class RideConfirmationScreen extends StatelessWidget {
  final BookingModel booking;
  const RideConfirmationScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            const Icon(
              Icons.check_circle,
              color: AppColors.primaryColor,
              size: 100,
            ),
            const SizedBox(height: 24),
            Text(
              'Booked! Your ride has been confirmed',
              style: AppTextStyles.headline1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Your driver will wait only 5mins',
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.subtleTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const BottomNavBar()),
                  (route) => false,
                );
              },
              child: const Text("Done"),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RideDetailsScreen(booking: booking),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.secondaryColor),
              ),
              child: const Text("View Ride Details"),
            ),
          ],
        ),
      ),
    );
  }
}
