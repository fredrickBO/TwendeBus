// lib/shared/widgets/drawer_menu.dart
import 'package:flutter/material.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFE0E1E6), // Match the holder's background
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 50),
              CircleAvatar(radius: 30, backgroundColor: Colors.grey),
              SizedBox(height: 12),
              Text(
                "Fredrick",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text("My profile"),
              SizedBox(height: 30),
              // We'll create a simple list of menu items here.
              // In a real app, you would use the _buildDrawerItem helper.
              Text("Home"),
              SizedBox(height: 20),
              Text("Wallet"),
              // ... add other menu items here
            ],
          ),
        ),
      ),
    );
  }
}
