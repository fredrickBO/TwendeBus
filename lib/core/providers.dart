// lib/core/providers.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twende_bus_ui/core/models/booking_model.dart';
import 'package:twende_bus_ui/core/models/route_model.dart';
import 'package:twende_bus_ui/core/models/transaction_model.dart';
import 'package:twende_bus_ui/core/models/trip_model.dart';
import 'package:twende_bus_ui/core/models/user_model.dart';
import 'package:twende_bus_ui/core/services/auth_service.dart';
import 'package:twende_bus_ui/core/services/firestore_service.dart';
import 'package:twende_bus_ui/core/models/search_params.dart';

// Provides a global instance of our AuthService class.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Provides a real-time stream of the user's authentication state.
// The UI will listen to this to know if the user is logged in or out.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// --- FIRESTORE PROVIDERS (New) ---
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// Provides the UserModel data for the currently logged-in user.
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  // Watch the auth state to get the current user's UID.
  final authState = ref.watch(authStateProvider);
  final uid = authState.asData?.value?.uid;

  if (uid != null) {
    // If we have a UID, stream the user's document from Firestore.
    return ref.watch(firestoreServiceProvider).streamUser(uid);
  }
  // If no user is logged in, provide a null stream.
  return Stream.value(null);
});

// Provides a list of all bus routes from Firestore.
final routesProvider = StreamProvider<List<RouteModel>>((ref) {
  return ref.watch(firestoreServiceProvider).streamRoutes();
});
//Provides a list of trips for a specific route.
// The `.family` allows us to pass in the routeId.
final tripsForRouteProvider =
    StreamProvider.family<List<TripModel>, SearchParams>((ref, searchParams) {
      final firestoreService = ref.watch(firestoreServiceProvider);
      // Pass the string directly to the service
      return firestoreService.streamTripsForRoute(
        routeId: searchParams.routeId,
        departureDay: searchParams.dateString,
      );
    });

// EXPLANATION: This is a new provider specifically to get a LIVE stream of a SINGLE trip.
// It watches a single document in Firestore for any changes.
final tripStreamProvider = StreamProvider.family<TripModel, String>((
  ref,
  tripId,
) {
  // In a larger app, you'd put this logic in FirestoreService, but for clarity, it's here.
  return FirebaseFirestore.instance
      .collection('trips')
      .doc(tripId)
      .snapshots() // .snapshots() creates the real-time stream
      .map((doc) => TripModel.fromFirestore(doc));
});

final userBookingsProvider = StreamProvider<List<BookingModel>>((ref) {
  final authState = ref.watch(authStateProvider);
  final uid = authState.asData?.value?.uid;
  if (uid != null) {
    return ref.watch(firestoreServiceProvider).streamUserBookings(uid);
  }
  return Stream.value([]);
});

final routeDetailsProvider = FutureProvider.family<RouteModel, String>((
  ref,
  routeId,
) {
  // This is a simplified service call. In a real app, you'd add this to FirestoreService.
  return FirebaseFirestore.instance
      .collection('routes')
      .doc(routeId)
      .get()
      .then((doc) => RouteModel.fromFirestore(doc));
});

// NEW: A provider for the current user's transaction history.
final userTransactionsProvider = StreamProvider<List<TransactionModel>>((ref) {
  final uid = ref.watch(authStateProvider).asData?.value?.uid;
  if (uid != null) {
    return ref.watch(firestoreServiceProvider).streamUserTransactions(uid);
  }
  return Stream.value([]);
});
