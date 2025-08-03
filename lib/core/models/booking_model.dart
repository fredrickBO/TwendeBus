// lib/core/models/booking_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String userId;
  final String tripId;
  final List<String> seatNumbers;
  final String status;
  final DateTime bookingTime;
  final double farePaid;
  final String startStop;
  final String endStop;

  BookingModel({
    required this.id,
    required this.userId,
    required this.tripId,
    required this.seatNumbers,
    required this.status,
    required this.bookingTime,
    required this.farePaid,
    required this.startStop,
    required this.endStop,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      tripId: data['tripId'] ?? '',
      seatNumbers: List<String>.from(data['seatNumbers'] ?? []),
      status: data['status'] ?? 'confirmed',
      bookingTime: (data['bookingTime'] as Timestamp).toDate(),
      farePaid: (data['farePaid'] ?? 0).toDouble(),
      startStop: data['startStop'] ?? '',
      endStop: data['endStop'] ?? '',
    );
  }
}
