// lib/core/models/ride_details_view_model.dart
import 'package:twende_bus_ui/core/models/booking_model.dart';
import 'package:twende_bus_ui/core/models/route_model.dart';
import 'package:twende_bus_ui/core/models/trip_model.dart';
import 'package:twende_bus_ui/core/models/user_model.dart';

// This class is just a container for all our data.
class RideDetailsViewModel {
  final BookingModel booking;
  final TripModel trip;
  final RouteModel route;
  final UserModel driver;

  RideDetailsViewModel({
    required this.booking,
    required this.trip,
    required this.route,
    required this.driver,
  });
}
