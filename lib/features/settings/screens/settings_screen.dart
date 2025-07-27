// lib/features/settings/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // A section for account settings.
          Text(
            "Account",
            style: AppTextStyles.labelText.copyWith(
              color: AppColors.primaryColor,
            ),
          ),
          SwitchListTile(
            title: const Text("Push Notifications"),
            value: true, // Static value for UI
            onChanged: (bool value) {},
            secondary: const Icon(Icons.notifications),
          ),
          ListTile(
            leading: const Icon(Icons.lock_reset),
            title: const Text("Change Password"),
            onTap: () {},
          ),
          const Divider(),

          // A section for app preferences.
          Text(
            "Preferences",
            style: AppTextStyles.labelText.copyWith(
              color: AppColors.primaryColor,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("Language"),
            subtitle: const Text("English"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text("Dark Mode"),
            subtitle: const Text("System"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
