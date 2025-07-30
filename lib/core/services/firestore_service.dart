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
  Stream<List<TripModel>> streamTripsForRoute(String routeId) {
    return _db
        .collection('trips')
        // This is the query: find all trips where routeId matches.
        .where('routeId', isEqualTo: routeId)
        // This is a filter: only show trips that haven't departed yet.
        .where('departureTime', isGreaterThan: Timestamp.now())
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TripModel.fromFirestore(doc)).toList(),
        );
  }
}
