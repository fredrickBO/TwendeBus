// lib/shared/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';
import 'package:twende_bus_ui/features/wallet/screens/wallet_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the screen width to determine the drawer's width.
    final screenWidth = MediaQuery.of(context).size.width;

    // The root widget is a standard Drawer.
    return Drawer(
      // CRITICAL: Make the drawer's own background transparent.
      backgroundColor: Colors.transparent,
      // Remove the default shadow.
      elevation: 0,
      child: Row(
        children: [
          // This Spacer pushes our custom drawer to the right.
          const Spacer(),
          // This ClipPath will shape our visible drawer content.
          ClipPath(
            clipper: _DrawerClipper(),
            child: Container(
              // Define the width of our visible drawer.
              width: screenWidth * 0.8, // Drawer takes 80% of the screen width.
              // Set the background color of our custom-shaped container.
              color: AppColors.cardColor,
              // Use SafeArea to avoid UI elements drawing under the status bar.
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // The header area.
                    Container(
                      padding: const EdgeInsets.only(
                        top: 24.0,
                        left: 24.0,
                        bottom: 24.0,
                        right: 24.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Fredrick",
                            style: AppTextStyles.headline2.copyWith(
                              fontSize: 20,
                            ),
                          ),
                          Text("My profile", style: AppTextStyles.labelText),
                        ],
                      ),
                    ),
                    // The list of menu items.
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        children: <Widget>[
                          _buildDrawerItem(
                            icon: Icons.home_outlined,
                            text: 'Home',
                            onTap: () {},
                          ),
                          _buildDrawerItem(
                            icon: Icons.account_balance_wallet_outlined,
                            text: 'Wallet',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const WalletScreen(),
                                ),
                              );
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.confirmation_number_outlined,
                            text: 'Bookings',
                            onTap: () {},
                          ),
                          const Divider(),
                          _buildDrawerItem(
                            icon: Icons.settings_outlined,
                            text: 'Settings',
                            onTap: () {},
                          ),
                          _buildDrawerItem(
                            icon: Icons.support_outlined,
                            text: 'Support',
                            onTap: () {},
                          ),
                          _buildDrawerItem(
                            icon: Icons.info_outline,
                            text: 'About',
                            onTap: () {},
                          ),
                          const Divider(),
                          _buildDrawerItem(
                            icon: Icons.logout,
                            text: 'Sign Out',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    // The bottom 'Invite & Earn' section.
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildDrawerItem(
                        icon: Icons.card_giftcard,
                        text: 'Invite & Earn',
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method is unchanged.
  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.subtleTextColor),
      title: Text(text, style: AppTextStyles.bodyText),
      onTap: onTap,
    );
  }
}

// The CustomClipper class remains exactly the same as before.
class _DrawerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    const double radius = 0.0;
    path.moveTo(radius, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(radius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
