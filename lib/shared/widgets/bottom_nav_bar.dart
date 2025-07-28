// lib/shared/widgets/bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';
import 'package:twende_bus_ui/features/booking/screens/bookings_list_screen.dart';
import 'package:twende_bus_ui/features/home/screens/home_screen.dart';
import 'package:twende_bus_ui/features/map/screens/map_screen.dart';
//import 'package:twende_bus_ui/features/pooling/screens/pooling_screen.dart';
import 'package:twende_bus_ui/features/profile/screens/profile_screen.dart';
import 'package:twende_bus_ui/shared/widgets/drawer_menu.dart';

// This is the main stateful widget that will hold our entire app's navigation state.
class BottomNavBar extends StatefulWidget {
  // `const` constructor for a stateful widget.
  const BottomNavBar({super.key});

  // This creates the mutable state for this widget.
  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

// This is the State class where all the logic and UI for our BottomNavBar lives.
class _BottomNavBarState extends State<BottomNavBar> {
  // A private variable to keep track of which tab is currently selected.
  // It starts at 0, which corresponds to the 'Home' screen.
  int _selectedIndex = 0;

  // A static list of all the main screens in our app.
  // The order here MUST match the order of the BottomNavigationBarItems below.
  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(), // Index 0
    const MapScreen(), // Index 1
    const BookingsListScreen(), // Index 2
    //const PoolingScreen(),     // Index 3
    const ProfileScreen(), // Index 4
  ];

  // This function is called whenever a user taps on a navigation bar item.
  void _onItemTapped(int index) {
    // `setState` is a crucial Flutter method. It tells the framework that the state
    // of this widget has changed, and that it needs to rebuild the UI to reflect the change.
    setState(() {
      // We update our `_selectedIndex` to the new index that was tapped.
      _selectedIndex = index;
    });
  }

  // The build method is called every time the UI needs to be rendered.
  @override
  Widget build(BuildContext context) {
    // Scaffold is a basic material design visual layout structure.
    return ZoomDrawer(
      menuScreen: const DrawerMenu(),
      mainScreen: Scaffold(
        // The body of the scaffold will display the currently selected screen.
        // `_widgetOptions.elementAt(_selectedIndex)` gets the widget from our list
        // at the currently selected index.
        body: _widgetOptions.elementAt(_selectedIndex),

        // This is where we define the bottom navigation bar itself.
        bottomNavigationBar: BottomNavigationBar(
          // This ensures that all items are visible and don't slide, which is
          // essential when you have more than 3 items.
          type: BottomNavigationBarType.fixed,

          // This is the list of tappable items on the bar.
          items: const <BottomNavigationBarItem>[
            // Each BottomNavigationBarItem represents one tab.
            BottomNavigationBarItem(
              // The icon to show when the tab is NOT selected.
              icon: Icon(Icons.home_outlined),
              // The icon to show when this tab IS selected.
              activeIcon: Icon(Icons.home),
              // The text label for the tab.
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_number_outlined),
              activeIcon: Icon(Icons.confirmation_number),
              label: 'Booking',
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],

          // Tells the navigation bar which item is currently active.
          currentIndex: _selectedIndex,
          // The color for the icon and label of the selected item, from our theme.
          selectedItemColor: AppColors.primaryColor,
          // The color for the icons and labels of unselected items.
          unselectedItemColor: AppColors.subtleTextColor,
          // Ensures the labels for unselected items are always visible.
          showUnselectedLabels: true,
          // The function that gets called when a user taps an item.
          onTap: _onItemTapped,
        ),
      ),
      //*** */
      borderRadius: 24.0,
      showShadow: true,
      angle: 0.0, // No tilt
      mainScreenScale: 0.85, // Main screen shrinks slightly
      slideWidth: MediaQuery.of(context).size.width * 0.75, // Drawer width
      menuBackgroundColor: AppColors.cardColor,
      isRtl: true,
    );
  }
}
