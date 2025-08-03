// lib/core/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:twende_bus_ui/core/models/booking_model.dart';
import 'package:twende_bus_ui/core/models/transaction_model.dart';
import 'package:twende_bus_ui/core/models/trip_model.dart';
import 'package:twende_bus_ui/core/models/user_model.dart';
import 'package:twende_bus_ui/core/models/route_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get a real-time stream of a single user's data.
  Stream<UserModel> streamUser(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) => UserModel.fromFirestore(snapshot));
  }

  // Get a real-time stream of all available routes.
  Stream<List<RouteModel>> streamRoutes() {
    return _db
        .collection('routes')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RouteModel.fromFirestore(doc))
              .toList(),
        );
  }

  // //Get a stream of trips for a specific route.
  Stream<List<TripModel>> streamTripsForRoute({
    required String routeId,
    required String departureDay,
  }) {
    //calculate the start of the day selected day
    //final startOfDay = DateTime.utc(date.year, date.month, date.day);

    //calculate the end of the day selected day
    //final endOfDay = DateTime.utc(date.year, date.month, date.day + 1);

    return _db
        .collection('trips')
        // This is the query: find all trips where routeId matches.
        .where('routeId', isEqualTo: routeId)
        // This is a filter: only show trips that haven't departed yet.
        .where(
          'departureDay',
          isEqualTo: departureDay, // Use the string date directly),
        )
        //.where('departureDay', isLessThan: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TripModel.fromFirestore(doc)).toList(),
        );
  }

  // This function fetches the details for a single trip, one time.
  Future<TripModel> getTripDetails(String tripId) async {
    final docSnapshot = await _db.collection('trips').doc(tripId).get();
    if (docSnapshot.exists) {
      return TripModel.fromFirestore(docSnapshot);
    } else {
      throw Exception("Trip not found");
    }
  }

  Future<BookingModel> getBookingDetails(String bookingId) async {
    final docSnapshot = await _db.collection('bookings').doc(bookingId).get();
    if (docSnapshot.exists) {
      return BookingModel.fromFirestore(docSnapshot);
    } else {
      throw Exception("Newly created booking not found");
    }
  }

  Stream<List<BookingModel>> streamUserBookings(String uid) {
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: uid)
        .orderBy('bookingTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BookingModel.fromFirestore(doc))
              .toList(),
        );
  }

  // NEW: Get a live stream of a user's transactions.
  Stream<List<TransactionModel>> streamUserTransactions(String uid) {
    return _db
        .collection('transactions')
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .limit(20) // Get the last 20 transactions
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TransactionModel.fromFirestore(doc))
              .toList(),
        );
  }
}
