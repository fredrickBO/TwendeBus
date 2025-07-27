// lib/features/profile/screens/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // This Column centers the profile picture and the 'Change Picture' button.
          Column(
            children: [
              const CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.cardColor,
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: AppColors.subtleTextColor,
                ),
              ),
              TextButton(onPressed: () {}, child: const Text("Change Picture")),
            ],
          ),
          const SizedBox(height: 32),

          // We use TextFormFields with initialValue to pre-fill the form.
          // The `decoration` with `labelText` provides a floating label above the field.
          TextFormField(
            initialValue: 'Gloria',
            decoration: const InputDecoration(labelText: 'First Name'),
          ),
          const SizedBox(height: 20),
          TextFormField(
            initialValue: 'Mukhwana',
            decoration: const InputDecoration(labelText: 'Last Name'),
          ),
          const SizedBox(height: 20),
          TextFormField(
            initialValue: '2003-02-26',
            decoration: const InputDecoration(
              labelText: 'Date of Birth',
              suffixIcon: Icon(Icons.calendar_today),
            ),
          ),
          const SizedBox(height: 20),
          // We disable this field because email is usually not editable.
          TextFormField(
            initialValue: 'gloria@gmail.com',
            decoration: const InputDecoration(labelText: 'Email'),
            enabled: false,
          ),
          const SizedBox(height: 20),
          TextFormField(
            initialValue: '+254 759 158 714',
            decoration: const InputDecoration(labelText: 'Phone Number'),
          ),
          const SizedBox(height: 100),

          // A full-width button to save the changes.
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Later, this will save the form data to Firestore.
                Navigator.of(context).pop(); // Go back to the profile screen.
              },
              child: const Text("Save Changes"),
            ),
          ),
        ],
      ),
    );
  }
}
