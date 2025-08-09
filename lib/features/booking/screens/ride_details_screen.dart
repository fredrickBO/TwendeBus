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

class RideDetailsScreen extends ConsumerStatefulWidget {
  final BookingModel booking;

  const RideDetailsScreen({super.key, required this.booking});

  @override
  ConsumerState<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends ConsumerState<RideDetailsScreen> {
  // A map of stop names to their coordinates. In a real app, this would come from Firestore.
  final Map<String, LatLng> stopCoordinates = {
    "Kencom": const LatLng(-1.2855, 36.8219),
    "Ngara": const LatLng(-1.2755, 36.8262),
    "Kasarani": const LatLng(-1.2225, 36.9022),
    "Mwiki": const LatLng(-1.2175, 36.9328),
    "Westlands": const LatLng(-1.2646, 36.8049),
    "Utawala": const LatLng(-1.2954, 36.9534),
    "Shooters": const LatLng(-1.2954, 36.9534),
    "Naivas": const LatLng(-1.2646, 36.8049),
  };

  final Set<Polyline> _polylines = {};
  String _eta = "Calculating...";
  bool _userHasBoarded = false; // Tracks if the user is on the bus
  GoogleMapController? _mapController;
  StreamSubscription? _tripSubscription;

  @override
  void initState() {
    super.initState();
    _tripSubscription = ref
        .read(tripStreamProvider(widget.booking.tripId).stream)
        .listen((trip) {
          if (trip.currentLocation != null) {
            _fetchDirectionsAndUpdateUI(trip);
            _mapController?.animateCamera(
              CameraUpdate.newLatLng(
                LatLng(
                  trip.currentLocation!.latitude,
                  trip.currentLocation!.longitude,
                ),
              ),
            );
          }
        });
  }

  @override
  void dispose() {
    _tripSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchDirectionsAndUpdateUI(TripModel trip) async {
    final startStopName = widget.booking.startStop;
    final endStopName = widget.booking.endStop;

    if (!stopCoordinates.containsKey(startStopName) ||
        !stopCoordinates.containsKey(endStopName)) {
      print(
        "Error: Stop coordinates not found for '$startStopName' or '$endStopName'. Please update the map.",
      );
      setState(() {
        _eta = "Calculating....";
      });
      return; // Stop the function if we don't have the coordinates.
    }

    final LatLng origin = LatLng(
      trip.currentLocation!.latitude,
      trip.currentLocation!.longitude,
    );
    // Determine the destination based on whether the user has boarded
    final LatLng destination = _userHasBoarded
        ? stopCoordinates[endStopName]!
        : stopCoordinates[startStopName]!;

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
    final tripAsyncValue = ref.watch(tripStreamProvider(widget.booking.tripId));

    return Scaffold(
      appBar: AppBar(title: const Text("Ride Details")),
      // THE FIX: Use a nested .when() structure to safely load all data.
      body: tripAsyncValue.when(
        data: (trip) {
          // Now that we have the trip, we can fetch the route details.
          final routeAsyncValue = ref.watch(routeDetailsProvider(trip.routeId));

          return routeAsyncValue.when(
            data: (route) {
              final busLocation = LatLng(
                trip.currentLocation?.latitude ?? -1.286389,
                trip.currentLocation?.longitude ?? 36.817223,
              );

              // Your Stack-based UI is excellent.
              return Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: busLocation,
                      zoom: 14.0,
                    ),
                    polylines: _polylines,
                    markers: {
                      Marker(
                        markerId: MarkerId(trip.id),
                        position: busLocation,
                      ),
                      if (stopCoordinates.containsKey(widget.booking.startStop))
                        Marker(
                          markerId: MarkerId(widget.booking.startStop),
                          position: stopCoordinates[widget.booking.startStop]!,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueGreen,
                          ),
                        ),
                      if (stopCoordinates.containsKey(widget.booking.endStop))
                        Marker(
                          markerId: MarkerId(widget.booking.endStop),
                          position: stopCoordinates[widget.booking.endStop]!,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRed,
                          ),
                        ),
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
