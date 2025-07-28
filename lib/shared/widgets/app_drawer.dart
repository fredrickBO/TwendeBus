// lib/shared/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';
import 'package:twende_bus_ui/features/wallet/screens/wallet_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // The main container for the side menu.
    return Drawer(
      child: Column(
        children: [
          // The header area of the drawer.
          SizedBox(
            height: 200,
            child: DrawerHeader(
              decoration: const BoxDecoration(color: AppColors.cardColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(radius: 30, backgroundColor: Colors.grey),
                  const SizedBox(height: 8),
                  Text(
                    "Fredrick",
                    style: AppTextStyles.headline2.copyWith(fontSize: 20),
                  ),
                  Text("My profile", style: AppTextStyles.labelText),
                ],
              ),
            ),
          ),
          // A scrollable list for the menu items.
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
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
                    Navigator.pop(context); // Close the drawer first
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WalletScreen()),
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
          // This section is for the 'Invite & Earn' button at the bottom.
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
    );
  }

  // A reusable helper for each menu item.
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
