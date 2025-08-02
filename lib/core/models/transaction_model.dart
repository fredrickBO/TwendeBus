// lib/core/models/transaction_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final double amount;
  final String type; // e.g., 'deposit', 'deduction', 'refund'
  final String details;
  final DateTime timestamp;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.details,
    required this.timestamp,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      amount: (data['amount'] ?? 0).toDouble(),
      type: data['type'] ?? '',
      details: data['details'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}
