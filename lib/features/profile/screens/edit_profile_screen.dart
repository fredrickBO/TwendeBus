// lib/features/profile/screens/edit_profile_screen.dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:twende_bus_ui/core/providers.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill the form fields with the current user's data when the screen loads.
    final user = ref.read(currentUserProvider).asData?.value;
    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _phoneController.text = user.phoneNumber;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final user = ref.read(currentUserProvider).asData?.value;
    if (user == null) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _isLoading = true);
      final firestoreService = ref.read(firestoreServiceProvider);

      if (kIsWeb) {
        await firestoreService.uploadProfileImageFromBytes(
          user.uid,
          await image.readAsBytes(),
        );
      } else {
        await firestoreService.uploadProfileImageFromFile(
          user.uid,
          File(image.path),
        );
      }

      // THE FIX: Force the currentUserProvider to refetch its data.
      // This will make the UI update with the new image URL.
      ref.invalidate(currentUserProvider);

      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile picture updated!")),
        );
      }
    }
  }

  void _saveChanges() async {
    final user = ref.read(currentUserProvider).asData?.value;
    if (user == null) return;

    setState(() => _isLoading = true);
    final firestoreService = ref.read(firestoreServiceProvider);
    await firestoreService.updateUserData(
      user.uid,
      _firstNameController.text,
      _lastNameController.text,
      _phoneController.text,
    );
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider to get live updates for the profile picture.
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text("User not found."));
          final imageUrl = user.profilePictureUrl;
          final hasImage = imageUrl != null && imageUrl.isNotEmpty;

          return ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              // This Column centers the profile picture and the 'Change Picture' button.
              Center(
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.cardColor,
                        // Display the live profile picture URL.
                        backgroundImage: hasImage
                            ? NetworkImage(imageUrl)
                            : null,
                        child: !hasImage
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: AppColors.subtleTextColor,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 22,

                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              //color: Colors.blue,
                              size: 20,
                            ),
                            onPressed: _isLoading ? null : _pickImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // We use TextFormFields with initialValue to pre-fill the form.
              // The `decoration` with `labelText` provides a floating label above the field.
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: user?.email,
                decoration: const InputDecoration(labelText: 'Email'),
                enabled: false,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              const SizedBox(height: 100),

              // A full-width button to save the changes.
              SizedBox(
                width: double.infinity,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _saveChanges,
                        child: const Text("Save Changes"),
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            const Center(child: Text("Error loading profile.")),
      ),
    );
  }
}
