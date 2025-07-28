// lib/features/notifications/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          NotificationItem(
            date: "02 July 2025",
            time: "08:52 AM",
            title: "Confirmation Alert",
            body:
                "Your recent booking was canceled. Your refund is being processed. This should take at least 2 hours.",
          ),
          NotificationItem(
            date: "17 June 2025",
            time: "08:30 AM",
            title: "Confirmation Alert",
            body:
                "Your refund is being processed. This should take at least 2 hours.",
          ),
        ],
      ),
    );
  }
}

// A reusable widget for a single notification item.
class NotificationItem extends StatelessWidget {
  final String date, time, title, body;
  const NotificationItem({
    super.key,
    required this.date,
    required this.time,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(date, style: AppTextStyles.labelText),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.cardColor,
                  child: Icon(Icons.person, color: AppColors.subtleTextColor),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.bodyText.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(time, style: AppTextStyles.labelText),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(body, style: AppTextStyles.labelText),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
