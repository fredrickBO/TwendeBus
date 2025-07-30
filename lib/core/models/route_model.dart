// lib/core/models/route_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class RouteModel {
  final String id;
  final String startPoint;
  final String endPoint;
  final double fare;
  //final List<String> stops;
  final List<String> boardingPoints;
  final List<String> deboardingPoints;

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
    Map data = doc.data() as Map<String, dynamic>;
    return RouteModel(
      id: doc.id,
      startPoint: data['startPoint'] ?? '',
      endPoint: data['endPoint'] ?? '',
      fare: (data['fare'] ?? 0).toDouble(),
      //stops: List<String>.from(data['stops'] ?? []),
      boardingPoints: List<String>.from(data['boardingPoints'] ?? []),
      deboardingPoints: List<String>.from(data['deboardingPoints'] ?? []),
    );
  }
}
