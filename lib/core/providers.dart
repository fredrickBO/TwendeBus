// lib/core/providers.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twende_bus_ui/core/models/route_model.dart';
import 'package:twende_bus_ui/core/models/trip_model.dart';
import 'package:twende_bus_ui/core/models/user_model.dart';
import 'package:twende_bus_ui/core/services/auth_service.dart';
import 'package:twende_bus_ui/core/services/firestore_service.dart';

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
final tripsForRouteProvider = StreamProvider.family<List<TripModel>, String>((
  ref,
  routeId,
) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.streamTripsForRoute(routeId);
});
