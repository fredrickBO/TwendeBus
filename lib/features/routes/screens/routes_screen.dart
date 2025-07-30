// lib/features/routes/screens/routes_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twende_bus_ui/core/providers.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';

class RoutesScreen extends ConsumerWidget {
  const RoutesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routesAsyncValue = ref.watch(routesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text("Routes")),
      body: routesAsyncValue.when(
        //data to be displayed when the data is available and successfully fetched
        data: (routes) {
          if (routes.isEmpty) {
            return const Center(
              child: Text("No routes available at the moment."),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: routes.length,
            itemBuilder: (context, index) {
              final route = routes[index];

              //passing the route data to a reusable widget
              //to display the route information
              return RouteListItem(
                startPoint: route.startPoint,
                endPoint: route.endPoint,
                fare: route.fare,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text("Error: $error")),
      ),
    );
  }
}

class RouteListItem extends StatelessWidget {
  final String startPoint;
  final String endPoint;
  final double fare;

  const RouteListItem({
    super.key,
    required this.startPoint,
    required this.endPoint,
    required this.fare,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Row(
          children: [
            Column(
              children: const [
                Icon(Icons.circle, size: 12, color: AppColors.primaryColor),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    "⋮",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.subtleTextColor,
                    ),
                  ),
                ),
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppColors.secondaryColor,
                ),
              ],
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  startPoint,
                  style: AppTextStyles.bodyText.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  endPoint,
                  style: AppTextStyles.bodyText.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              "KES $fare",
              style: AppTextStyles.headline2.copyWith(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
// // A reusable widget for a single item in the routes list.
// class RouteListItem extends StatelessWidget {
//   const RouteListItem({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
//         child: Row(
//           children: [
//             Column(
//               children: const [
//                 Icon(Icons.circle, size: 12, color: AppColors.primaryColor),
//                 Padding(
//                   padding: EdgeInsets.symmetric(vertical: 4.0),
//                   child: Text(
//                     "⋮",
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.subtleTextColor,
//                     ),
//                   ),
//                 ),
//                 Icon(
//                   Icons.location_on,
//                   size: 16,
//                   color: AppColors.secondaryColor,
//                 ),
//               ],
//             ),
//             const SizedBox(width: 16),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Westlands",
//                   style: AppTextStyles.bodyText.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   "Utawala",
//                   style: AppTextStyles.bodyText.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             const Spacer(),
//             Text(
//               "KES 150",
//               style: AppTextStyles.headline2.copyWith(fontSize: 18),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
