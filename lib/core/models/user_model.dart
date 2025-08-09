// lib/core/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final double walletBalance;
  final String? profilePictureUrl;
  final bool notificationsEnabled;

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.walletBalance,
    required this.profilePictureUrl,
    required this.notificationsEnabled,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      walletBalance: (data['walletBalance'] ?? 0).toDouble(),
      profilePictureUrl: data['profilePictureUrl'],
      notificationsEnabled:
          data['notificationsEnabled'] ?? true, // Default to true
    );
  }
}
