// lib/core/services/firestore_service.dart
import 'dart:io';
import 'dart:typed_data'; // Needed for web bytes
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:twende_bus_ui/core/models/booking_model.dart';
import 'package:twende_bus_ui/core/models/notification_model.dart';
import 'package:twende_bus_ui/core/models/transaction_model.dart';
import 'package:twende_bus_ui/core/models/trip_model.dart';
import 'package:twende_bus_ui/core/models/user_model.dart';
import 'package:twende_bus_ui/core/models/route_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage =
      FirebaseStorage.instance; // Create an instance of Firebase Storage

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
        .where('departureTime', isGreaterThan: Timestamp.now())

        .orderBy('departureTime', descending: false) // Show the earliest trips first
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TripModel.fromFirestore(doc)).toList(),
        );
  }

  // --- NEW: Method to upload a user's profile image ---
  // For mobile platforms (Android/iOS)
  Future<String> uploadProfileImageFromFile(String uid, File image) async {
    try {
      final ref = _storage.ref().child('profile_images').child('$uid.jpg');
      final uploadTask = await ref.putFile(image);
      final String downloadUrl = await uploadTask.ref.getDownloadURL();

      // THE FIX: This is the critical missing line.
      // It saves the new image URL to the user's document in Firestore.
      await _db.collection('users').doc(uid).update({
        'profilePictureUrl': downloadUrl,
      });

      return downloadUrl;
    } catch (e) {
      print("Error uploading profile image from file: $e");
      return "";
    }
  }

  // For the web platform
  Future<String> uploadProfileImageFromBytes(
    String uid,
    Uint8List imageBytes,
  ) async {
    try {
      final ref = _storage.ref().child('profile_images').child('$uid.jpg');
      final uploadTask = await ref.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final String downloadUrl = await uploadTask.ref.getDownloadURL();

      // THE FIX: This is the critical missing line.
      // It saves the new image URL to the user's document in Firestore.
      await _db.collection('users').doc(uid).update({
        'profilePictureUrl': downloadUrl,
      });

      return downloadUrl;
    } catch (e) {
      print("Error uploading profile image from bytes: $e");
      return "";
    }
  }

  // --- NEW: Method to update user's profile data ---
  Future<void> updateUserData(
    String uid,
    String firstName,
    String lastName,
    String phoneNumber,
  ) async {
    try {
      await _db.collection('users').doc(uid).update({
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
      });
    } catch (e) {
      print("Error updating user data: $e");
    }
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

  // NEW: Get a stream of all trips that have a status of 'in-progress'.
  Stream<List<TripModel>> streamAllActiveTrips() {
    return _db
        .collection('trips')
        // In a real app, you would have a status field like 'in-progress'
        // For now, we'll just get all trips. You can add the .where() clause later.
        // .where('status', isEqualTo: 'in-progress')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TripModel.fromFirestore(doc)).toList(),
        );
  }

  // THE FIX: Add this new method to fetch a single user's details.
  Future<UserModel> getUserDetails(String uid) async {

     // --- THIS IS THE CRITICAL DEBUGGING BLOCK ---
    print('--- FirestoreService DEBUG: GROUND TRUTH ---');
    print('Attempting to get user document with this EXACT ID: |$uid|');
    print('-------------------------------------------');
    // ---------------------------------------------

    final docSnapshot = await _db.collection('users').doc(uid).get();
    if (docSnapshot.exists) {
      print('SUCCESS: Found user document for ID: $uid');
      return UserModel.fromFirestore(docSnapshot);
    } else {
      print('!!! FAILURE: User document NOT FOUND for ID: $uid');
      // Throw an error if the user (driver) document is not found.
      throw Exception("User not found for ID: $uid");
    }
  }

  // THE FIX: Add this missing method to get a single route's details.
  Future<RouteModel> getRouteDetails(String routeId) async {
    final docSnapshot = await _db.collection('routes').doc(routeId).get();
    if (docSnapshot.exists) {
      return RouteModel.fromFirestore(docSnapshot);
    } else {
      throw Exception("Route not found for ID: $routeId");
    }
  }

  // NEW: Update the user's notification preference.
  Future<void> updateNotificationSetting(String uid, bool isEnabled) async {
    await _db.collection('users').doc(uid).update({
      'notificationsEnabled': isEnabled,
    });
  }

  // NEW: Get a real-time stream of a user's notifications.
  Stream<List<NotificationModel>> streamUserNotifications(String uid) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .limit(30) // Get the last 30 notifications
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .toList(),
        );
  }

  // NEW: Mark all unread notifications as read.
  Future<void> markNotificationsAsRead(String uid) async {
    final querySnapshot = await _db
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _db.batch();
    for (final doc in querySnapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
