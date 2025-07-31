// lib/core/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
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

  //Get a stream of trips for a specific route.
  Stream<List<TripModel>> streamTripsForRoute({
    required String routeId,
    required DateTime date,
  }) {
    //calculate the start of the day selected day
    final startOfDay = DateTime.utc(date.year, date.month, date.day);

    //calculate the end of the day selected day
    //final endOfDay = DateTime.utc(date.year, date.month, date.day + 1);

    // --- ADD THIS DEBUGGING BLOCK ---
    print('--- Firestore Query Debug ---');
    print('Querying for routeId: $routeId');
    print('Start of Day (UTC): $startOfDay');
    //print('End of Day (UTC): $endOfDay');
    print('---------------------------');
    // ---------------------------------

    return _db
        .collection('trips')
        // This is the query: find all trips where routeId matches.
        .where('routeId', isEqualTo: routeId)
        // This is a filter: only show trips that haven't departed yet.
        .where(
          'departureTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        //.where('departureTime', isLessThan: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TripModel.fromFirestore(doc)).toList(),
        );
  }
}
