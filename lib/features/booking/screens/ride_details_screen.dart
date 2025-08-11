// lib/features/booking/screens/ride_details_screen.dart
import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:twende_bus_ui/core/models/booking_model.dart';
import 'package:twende_bus_ui/core/models/route_model.dart';
import 'package:twende_bus_ui/core/models/trip_model.dart';
import 'package:twende_bus_ui/core/providers.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';
import 'package:twende_bus_ui/features/booking/screens/cancel_ride_screen.dart';
import 'package:twende_bus_ui/core/models/stop_model.dart';

class RideDetailsScreen extends ConsumerStatefulWidget {
  final BookingModel booking;

  const RideDetailsScreen({super.key, required this.booking});

  @override
  ConsumerState<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends ConsumerState<RideDetailsScreen> {
 
  final Set<Polyline> _polylines = {};
  String _eta = "Calculating...";
  bool _userHasBoarded = false; // Tracks if the user is on the bus
  GoogleMapController? _mapController;
  StreamSubscription? _tripSubscription;

   @override
  void initState() {
    super.initState();
    // This listener correctly listens for trip updates.
    _tripSubscription = ref.read(tripStreamProvider(widget.booking.tripId).stream)
      .listen((trip) async {
      if (trip.currentLocation != null && mounted) {
        // Fetch the associated route to pass it along.
        final route = await ref.read(routeDetailsProvider(trip.routeId).future);
        // This call will now work correctly.
        _fetchDirectionsAndUpdateUI(trip, route);
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(LatLng(trip.currentLocation!.latitude, trip.currentLocation!.longitude)),
        );
      }
    });
  }

  @override
  void dispose() {
    _tripSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchDirectionsAndUpdateUI(TripModel trip, RouteModel route) async {
    print("Fetching directions for trip ${trip.id}...");
    final startStopName = widget.booking.startStop;
    final endStopName = widget.booking.endStop;

    StopModel? startStop;
    StopModel? endStop;
    try {
      startStop = route.boardingPoints.firstWhere((p) => p.name == startStopName);
      endStop = route.deboardingPoints.firstWhere((p) => p.name == endStopName);
    } catch (e) {
      // This catch block will run if .firstWhere finds no element.
      print("Error: Stop models not found in route data for '$startStopName' or '$endStopName'.");
      if (mounted) setState(() => _eta = "Unavailable");
      return;
    }

    final LatLng origin = LatLng(trip.currentLocation!.latitude, trip.currentLocation!.longitude);
    final LatLng destination = _userHasBoarded ? endStop.location : startStop.location;

    try {
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('getDirections');
      final result = await callable.call(<String, dynamic>{
        'originLat': origin.latitude,
        'originLng': origin.longitude,
        'destLat': destination.latitude,
        'destLng': destination.longitude,
      });

      if (mounted && result.data['success'] == true) {
        List<PointLatLng> points = PolylinePoints().decodePolyline(
          result.data['points'],
        );
        final List<LatLng> polylineCoordinates = points
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList();

        setState(() {
          _eta = result.data['durationText'];
          _polylines.clear();
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              color: Colors.blue,
              width: 5,
              points: polylineCoordinates,
            ),
          );
        });

        // Check for arrival
        if (!_userHasBoarded &&
            (result.data['durationText'] as String).contains('1 min')) {
          _showArrivalAlert();
        }
      }
    } catch (e) {
      print("Error fetching directions: $e");
    }
  }

  void _showArrivalAlert() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Bus Arriving!"),
        content: const Text("Your bus is arriving at your boarding point now."),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            child: const Text("I Have Boarded"),
            onPressed: () {
              setState(() => _userHasBoarded = true);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tripAsync = ref.watch(tripStreamProvider(widget.booking.tripId));

    return Scaffold(
      appBar: AppBar(title: const Text("Ride Details")),
      // THE FIX: Use a nested .when() structure to safely load all data.
      body: tripAsync.when(
        data: (trip) {

         final routeAsync = ref.watch(routeDetailsProvider(trip.routeId));

          return routeAsync.when(
            data: (route) {
              // Find the start and end stop models from the route.
               final driverAsyncValue = trip.driverId.isNotEmpty ? ref.watch(userDetailsProvider(trip.driverId)) : null;
              final busLocation = LatLng(trip.currentLocation?.latitude ?? -1.286389, trip.currentLocation?.longitude ?? 36.817223);
             
             final startStop = route.boardingPoints.where((p) => p.name == widget.booking.startStop).isNotEmpty
    ? route.boardingPoints.firstWhere((p) => p.name == widget.booking.startStop)
    : null;
          final endStop = route.deboardingPoints.where((p) => p.name == widget.booking.endStop).isNotEmpty
    ? route.deboardingPoints.firstWhere((p) => p.name == widget.booking.endStop)
    : null;

              // Your Stack-based UI is excellent.
              return Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(target: busLocation, zoom: 14.0),
                    polylines: _polylines,
                    // THE FIX: Markers are now generated dynamically and safely from route data.
                    markers: {
                      Marker(markerId: MarkerId(trip.id), position: busLocation),
                      if (startStop != null)
                        Marker(markerId: const MarkerId("start"), position: startStop.location, infoWindow: InfoWindow(title: "Your Pickup: ${startStop.name}"), icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)),
                      if (endStop != null)
                        Marker(markerId: const MarkerId("end"), position: endStop.location, infoWindow: InfoWindow(title: "Your Dropoff: ${endStop.name}"), icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)),
                    },
                    onMapCreated: (controller) => _mapController = controller,
                    padding: const EdgeInsets.only(bottom: 250),
                  ),
                  DraggableScrollableSheet(
                    initialChildSize: 0.35,
                    minChildSize: 0.35,
                    maxChildSize: 0.8,
                    builder:
                        (
                          BuildContext context,
                          ScrollController scrollController,
                        ) {
                          return Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(24.0),
                                topRight: Radius.circular(24.0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 10.0,
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                            child: ListView(
                              controller: scrollController,
                              padding: const EdgeInsets.all(16.0),
                              children: [
                                Center(
                                  child: Container(
                                    width: 40,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildEtaCard(),
                                const SizedBox(height: 16),
                                // THE FIX: Pass the loaded data to the helper.
                                _buildDynamicDetails(context, ref, trip, route),
                              ],
                            ),
                          );
                        },
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
    );
  }

  // This helper now receives the loaded data as parameters, preventing null errors.
  Widget _buildDynamicDetails(
    BuildContext context,
    WidgetRef ref,
    TripModel trip,
    RouteModel route,
  ) {
     if (trip.driverId.isEmpty) {
      return const ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text("No driver has been assigned to this trip yet."),
      );
    }
    // We fetch the driver's details here.
    final driverAsyncValue = ref.watch(userDetailsProvider(trip.driverId));

    return driverAsyncValue.when(
      data: (driver) => Column(
        children: [
          Text(
            DateFormat('d MMMM yyyy').format(trip.departureTime),
            style: AppTextStyles.bodyText,
          ),
          const SizedBox(height: 16),
          _buildJourneyTimeline(
            trip: trip,
            booking: widget.booking,
            route: route,
          ),
          const Divider(height: 32),
          _buildDetailRow(
            "Total price for ${widget.booking.seatNumbers.length} passenger(s)",
            "KES ${widget.booking.farePaid.toInt()}",
          ),
          const Divider(height: 32),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundImage:
                  (driver.profilePictureUrl != null &&
                      driver.profilePictureUrl!.isNotEmpty)
                  ? NetworkImage(driver.profilePictureUrl!)
                  : null,
            ),
            title: Text("${driver.firstName} ${driver.lastName}"),
            trailing: const Icon(Icons.phone, color: AppColors.primaryColor),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CancelRideScreen(booking: widget.booking),
                ),
              ),
              child: const Text("Cancel Ride"),
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) =>
          const Center(child: Text("Could not load driver details.")),
    );
  }

  // Helper method now uses live data passed to it.
  Widget _buildEtaCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              _userHasBoarded
                  ? "Arriving at your destination in:"
                  : "Bus arrives at your pickup in:",
              style: AppTextStyles.labelText,
            ),
            const SizedBox(height: 8),
            Text(_eta, style: AppTextStyles.headline1),
          ],
        ),
      ),
    );
  }

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
