// lib/features/profile/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twende_bus_ui/core/providers.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';
import 'package:twende_bus_ui/features/about/screens/about_us_screen.dart';
import 'package:twende_bus_ui/features/profile/screens/edit_profile_screen.dart';
import 'package:twende_bus_ui/features/settings/screens/settings_screen.dart';
import 'package:twende_bus_ui/features/support/screens/faq_support_screen.dart';
import 'package:twende_bus_ui/features/tickets/tickets_list_screen.dart';
import 'package:twende_bus_ui/features/wallet/screens/wallet_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  // This is a private helper method to avoid repeating code for the stat columns.
  // It builds the "Rides", "Routes", and "Tickets" widgets.
  Widget _buildStatColumn(String title, String value) {
    return Column(
      children: [
        // Displays the large number, e.g., "360".
        Text(value, style: AppTextStyles.headline2),
        // Displays the label below the number, e.g., "Rides".
        Text(title, style: AppTextStyles.labelText),
      ],
    );
  }

  // This is another helper method to create the list items like "Bookings", "Wallet", etc.
  // It makes the main build method much cleaner and easier to read.
  Widget _buildProfileMenuItem(
    BuildContext context, {
    required IconData icon, // The icon to display on the left.
    required String title, // The text for the list item.
    Color?
    color, // An optional color for the icon and text (used for "Sign Out").
    required VoidCallback
    onTap, // The function to call when the item is tapped.
  }) {
    // ListTile is a perfect widget for creating a row with a leading icon,
    // a title, and a trailing element.
    return ListTile(
      // The icon on the far left.
      leading: Icon(icon, color: color ?? AppColors.primaryColor),
      // The main text of the list item.
      title: Text(
        title,
        style: AppTextStyles.bodyText.copyWith(
          color: color ?? AppColors.textColor,
        ),
      ),
      // The small arrow icon on the far right.
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      // The action to perform when the ListTile is tapped.
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    return Scaffold(
      appBar: AppBar(
        // The title of the screen.
        title: const Text("Profile"),
        // `actions` are the widgets displayed on the right side of the AppBar.
        actions: [
          IconButton(
            onPressed: () {
              // Navigate to edit screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
            icon: const Icon(Icons.edit_outlined),
          ),
          const SizedBox(width: 8), // Adds a little space
        ],
      ),
      // A ListView to make the content scrollable.
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // This Column holds the main profile picture and user info.
          Column(
            children: [
              // A circular widget perfect for profile pictures.
              const CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.cardColor,
                // A placeholder person icon.
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: AppColors.subtleTextColor,
                ),
              ),
              const SizedBox(height: 12),
              // The user's name.
              Text('Gloria Mukhwana', style: AppTextStyles.headline2),
              // The user's email address.
              Text('gloria@gmail.com', style: AppTextStyles.labelText),
            ],
          ),
          const SizedBox(height: 24),

          // The stats row.
          Row(
            // `spaceAround` distributes the free space evenly between the children.
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // We call our helper method to create each stat column.
              _buildStatColumn("Rides", "360"),
              _buildStatColumn("Routes", "238"),
              _buildStatColumn("Tickets", "20"),
            ],
          ),
          const SizedBox(height: 24),
          // A visual divider line.
          const Divider(),

          // Here we call our menu item helper for each row in the list.
          _buildProfileMenuItem(
            context,
            icon: Icons.confirmation_number,
            title: "Tickets",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TicketsListScreen()),
              );
            },
          ),
          _buildProfileMenuItem(
            context,
            icon: Icons.account_balance_wallet,
            title: "Wallet",
            onTap: () {
              // Navigate to wallet screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WalletScreen()),
              );
            },
          ),
          _buildProfileMenuItem(
            context,
            icon: Icons.local_offer,
            title: "Settings",
            onTap: () {
              // Navigate to settings screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          _buildProfileMenuItem(
            context,
            icon: Icons.support_agent,
            title: "FAQs & Support",
            onTap: () {
              // Navigate to FAQs and support screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FaqSupportScreen()),
              );
            },
          ),
          _buildProfileMenuItem(
            context,
            icon: Icons.info_outline,
            title: "About Us",
            onTap: () {
              // Navigate to about us screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutUsScreen()),
              );
            },
          ),
          const Divider(),
          _buildProfileMenuItem(
            context,
            icon: Icons.logout,
            title: "Sign Out",
            // We pass a specific color for the "Sign Out" option.
            color: AppColors.errorColor,
            onTap: () {
              authService.signOut();
            },
          ),
        ],
      ),
    );
  }
}
