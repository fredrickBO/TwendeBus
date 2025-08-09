// lib/features/settings/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twende_bus_ui/core/providers.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final firestoreService = ref.read(firestoreServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text("User not found."));
          return ListView(
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
                value: user.notificationsEnabled,
                onChanged: (bool value) {
                  //call service to update the value in Firestore
                  firestoreService.updateNotificationSetting(user.uid, value);
                },
                secondary: const Icon(Icons.notifications),
              ),
              ListTile(
                leading: const Icon(Icons.lock_reset),
                title: const Text("Change Password"),
                onTap: () {
                  // Show a confirmation dialog first.
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Change Password"),
                      content: const Text(
                        "A password reset link will be sent to your email address. Do you want to continue?",
                      ),
                      actions: [
                        TextButton(
                          child: const Text("Cancel"),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        ElevatedButton(
                          child: const Text("Continue"),
                          onPressed: () {
                            // Get the auth service and the user's email.
                            final authService = ref.read(authServiceProvider);
                            final userEmail = user.email;

                            // Call the forgot password function.
                            authService.forgotPassword(email: userEmail);

                            // Close the dialog and show a confirmation snackbar.
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  "Password reset link sent! Check your email.",
                                ),
                                backgroundColor: AppColors.accentColor,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Divider(),

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
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Select Language"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RadioListTile(
                            title: const Text("English"),
                            value: "en",
                            groupValue: "en",
                            onChanged: (v) {},
                          ),
                          RadioListTile(
                            title: const Text("Swahili"),
                            value: "sw",
                            groupValue: "en",
                            onChanged: (v) {},
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          child: const Text("Done"),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text("Dark Mode"),
                subtitle: const Text("System"),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Choose Theme"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RadioListTile(
                            title: const Text("Light"),
                            value: "light",
                            groupValue: "system",
                            onChanged: (v) {},
                          ),
                          RadioListTile(
                            title: const Text("Dark"),
                            value: "dark",
                            groupValue: "system",
                            onChanged: (v) {},
                          ),
                          RadioListTile(
                            title: const Text("System Default"),
                            value: "system",
                            groupValue: "system",
                            onChanged: (v) {},
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          child: const Text("Done"),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text("Error loading settings.")),
      ),
    );
  }
}
