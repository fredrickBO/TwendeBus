// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twende_bus_ui/core/providers.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';
import 'package:twende_bus_ui/features/booking/screens/search_results_screen.dart';
import 'package:twende_bus_ui/features/notifications/screens/notifications_screen.dart';
import 'package:twende_bus_ui/features/routes/screens/routes_screen.dart';
import 'package:twende_bus_ui/shared/widgets/app_drawer.dart';
import 'package:twende_bus_ui/core/models/route_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  //add controllers for the search fields.
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  // The logic for the search button.
  void _searchBuses() {
    // Read the current list of routes from the provider.
    final routes = ref.read(routesProvider).asData?.value;
    if (routes == null || routes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Routes are not available yet.")),
      );
      return;
    }

    final fromText = _fromController.text.trim();
    final toText = _toController.text.trim();

    if (fromText.isEmpty || toText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a starting point and destination."),
        ),
      );
      return;
    }

    RouteModel? matchingRoute;
    try {
      // Find the first route that matches the search criteria (case-insensitive).
      matchingRoute = routes.firstWhere(
        (route) =>
            route.startPoint.toLowerCase() == fromText.toLowerCase() &&
            route.endPoint.toLowerCase() == toText.toLowerCase(),
      );
    } catch (e) {
      matchingRoute =
          null; // .firstWhere throws an error if no element is found.
    }

    if (matchingRoute != null) {
      // If a route is found, navigate and pass the route object.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SearchResultsScreen(route: matchingRoute!),
        ),
      );
    } else {
      // If no route is found, show an error.
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No direct route found.")));
    }
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsyncValue = ref.watch(currentUserProvider);
    final routesAsyncValue = ref.watch(routesProvider);
    // Scaffold provides the basic structure of the visual interface.
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: const AppDrawer(),
      // SafeArea ensures that the app's content is not obscured by system intrusions
      // like the notch on an iPhone or the status bar on Android.
      body: SafeArea(
        // ListView makes its content scrollable if it exceeds the screen height.
        child: ListView(
          // Adds padding to all sides of the scrollable content.
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          children: [
            // This Padding widget is only for the header elements.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  // This Column holds the welcome text.
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome',
                        style: AppTextStyles.bodyText.copyWith(
                          color: AppColors.subtleTextColor,
                        ),
                      ),
                      // The user's name is displayed here.
                      userAsyncValue.when(
                        data: (user) => Text(
                          user?.firstName ?? 'User',
                          style: AppTextStyles.headline1.copyWith(fontSize: 24),
                        ),
                        loading: () => const SizedBox(
                          height: 28,
                          width: 28,
                          child: CircularProgressIndicator(),
                        ),
                        error: (error, stack) => Text('Error: $error'),
                      ),
                    ],
                  ),
                  // Spacer expands to fill the available space, pushing the icons to the right.
                  const Spacer(),
                  // An icon button for notifications.
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_outlined,
                      size: 28,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  // An icon button for a side menu or drawer.
                  IconButton(
                    icon: const Icon(Icons.menu, size: 28),
                    onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                  ),
                ],
              ),
            ),
            // A SizedBox provides a fixed amount of space between widgets.
            const SizedBox(height: 24),

            // The main search card.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 10,
                shadowColor: Colors.black12,
                color: AppColors.cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // A text field for the starting location.
                      TextField(
                        controller: _fromController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.trip_origin),
                          hintText: 'From',

                          //border outline
                          border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                            borderSide: BorderSide(
                              color: const Color.fromARGB(255, 231, 233, 233),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      //adding arrow icon image between the two text fields
                      Image.asset(
                        'assets/images/arrow.png',
                        height: 24,

                        //move the image to the right
                        alignment: Alignment.centerRight,
                      ),
                      const SizedBox(height: 12),
                      // A text field for the destination.
                      TextField(
                        controller: _toController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.location_on),
                          hintText: 'To',
                          //border outline
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                              color: const Color.fromARGB(255, 231, 233, 233),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // A text field for the date.
                      const TextField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.calendar_today),
                          hintText: 'Date',
                          //border outline
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 231, 233, 233),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // A button that spans the full width of the card.
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _searchBuses,
                          child: const Text('Search Buses'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Header for the "Routes" section.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Routes", style: AppTextStyles.bodyText),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RoutesScreen()),
                    ),
                    child: const Text("See more"),
                  ),
                ],
              ),
            ),

            // This SizedBox constrains the height of the horizontal ListView.
            // A horizontal ListView inside a vertical ListView needs a fixed height.
            SizedBox(
              height: 100,
              // ListView.builder is an efficient way to create lists.
              child: routesAsyncValue.when(
                data: (routes) => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 16.0),
                  itemCount: routes.length,
                  itemBuilder: (context, index) {
                    final route = routes[index];
                    return RouteCard(
                      route: route,
                      //startPoint: route.startPoint,
                      //endPoint: route.endPoint,
                      //fare: route.fare.toInt().toString(),
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// A smaller, reusable widget for displaying a single route.
class RouteCard extends StatelessWidget {
  final RouteModel route;
  // final String startPoint;
  // final String endPoint;
  // final String fare;

  const RouteCard({
    super.key,
    required this.route,
    // required this.startPoint,
    // required this.endPoint,
    // required this.fare,
  });

  @override
  Widget build(BuildContext context) {
    // A Container to set a specific width for the card.
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          // Pass the selected route to the next screen
          MaterialPageRoute(builder: (_) => SearchResultsScreen(route: route)),
        );
      },
      child: Container(
        width: 250,
        margin: const EdgeInsets.only(right: 12.0),
        child: Card(
          color: AppColors.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.route, color: AppColors.primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        route.startPoint,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        route.endPoint,
                        style: const TextStyle(
                          color: AppColors.subtleTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "KES ${route.fare.toInt()}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
