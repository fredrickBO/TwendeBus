// lib/core/models/route_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:twende_bus_ui/core/models/stop_model.dart';

class RouteModel {
  final String id;
  final String startPoint;
  final String endPoint;
  final double fare;
  //final List<String> stops;
   final List<StopModel> boardingPoints;
   final List<StopModel> deboardingPoints;

  RouteModel({
    required this.id,
    required this.startPoint,
    required this.endPoint,
    required this.fare,

    // required this.stops,
    required this.boardingPoints,
    required this.deboardingPoints,
  });

  factory RouteModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // THE FIX: This is a robust helper function to parse the stops.
    List<StopModel> _parseStops(dynamic stopsData) {
      if (stopsData is List) {
        return stopsData.map((stop) {
          // If the item in the list is already a map (the new format), parse it.
          if (stop is Map<String, dynamic>) {
            return StopModel.fromMap(stop);
          }
          // If the item in the list is a string (the old format)...
          if (stop is String) {
            // ...create a StopModel from it with a default/empty location.
            return StopModel(name: stop, location: const LatLng(0, 0));
          }
          // Return an empty StopModel for any other unexpected type.
          return StopModel(name: 'Unknown', location: const LatLng(0, 0));
        }).toList();
      }
      // If the field doesn't exist or isn't a list, return an empty list.
      return [];
    }

    return RouteModel(
      id: doc.id,
      startPoint: data['startPoint'] ?? '',
      endPoint: data['endPoint'] ?? '',
      fare: (data['fare'] ?? 0).toDouble(),
      // Use the robust helper function for both fields.
      boardingPoints: _parseStops(data['boardingPoints']),
      deboardingPoints: _parseStops(data['deboardingPoints']),
    );
  }
}
