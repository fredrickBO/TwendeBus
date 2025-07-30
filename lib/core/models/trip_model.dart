// lib/core/models/trip_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TripModel {
  final String id;
  final String routeId;
  final String busCompany; // e.g., "Super Metro"
  final String busPlate; // e.g., "KDR 145G"
  final DateTime departureTime;
  final int availableSeats;
  final double rating;
  final double fare;
  // In a real app, you might also have a list of booked seat numbers.

  TripModel({
    required this.id,
    required this.routeId,
    required this.busCompany,
    required this.busPlate,
    required this.departureTime,
    required this.availableSeats,
    required this.rating,
    required this.fare,
  });

  factory TripModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return TripModel(
      id: doc.id,
      routeId: data['routeId'] ?? '',
      busCompany: data['busCompany'] ?? 'Unknown Bus',
      busPlate: data['busPlate'] ?? 'Unknown Plate',
      // Timestamps from Firestore need to be converted to DateTime
      departureTime: (data['departureTime'] as Timestamp).toDate(),
      availableSeats: data['availableSeats'] ?? 0,
      rating: (data['rating'] ?? 0.0).toDouble(),
      fare: (data['fare'] ?? 0).toDouble(),
    );
  }
}
