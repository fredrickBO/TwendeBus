// lib/features/map/screens/map_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:twende_bus_ui/core/providers.dart';

// Change to ConsumerWidget to access providers
class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  // Set the initial camera position to center on Nairobi
  static const CameraPosition _nairobiPosition = CameraPosition(
    target: LatLng(-1.286389, 36.817223),
    zoom: 12,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the new provider to get the list of all active buses.
    final activeTripsAsync = ref.watch(allActiveTripsProvider);

    return Scaffold(
      body: activeTripsAsync.when(
        data: (trips) {
          // Create a set of markers from the list of trips.
          final Set<Marker> markers = trips
              .where(
                (trip) => trip.currentLocation != null,
              ) // Only include trips that have a location
              .map((trip) {
                return Marker(
                  markerId: MarkerId(trip.id),
                  position: LatLng(
                    trip.currentLocation!.latitude,
                    trip.currentLocation!.longitude,
                  ),
                  infoWindow: InfoWindow(
                    title: trip.busCompany,
                    snippet: trip.busPlate,
                  ),
                );
              })
              .toSet();

          return GoogleMap(
            initialCameraPosition: _nairobiPosition,
            markers: markers,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            const Center(child: Text("Could not load map data.")),
      ),
    );
  }
}
