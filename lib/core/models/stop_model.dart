// lib/core/models/stop_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StopModel {
  final String name;
  final LatLng location;

  StopModel({required this.name, required this.location});

  factory StopModel.fromMap(Map<String, dynamic> data) {
    final geoPoint = data['location'] as GeoPoint? ?? const GeoPoint(0, 0);
    return StopModel(
      name: data['name'] ?? '',
      location: LatLng(geoPoint.latitude, geoPoint.longitude),
    );
  }
}