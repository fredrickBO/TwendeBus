// lib/features/notifications/screens/notification_details_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:twende_bus_ui/core/models/notification_model.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';

class NotificationDetailsScreen extends StatelessWidget {
  final NotificationModel notification;
  const NotificationDetailsScreen({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 25, child: Icon(Icons.notifications)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notification.title, style: AppTextStyles.headline2),
                      Text(DateFormat('d MMM yyyy, h:mm a').format(notification.timestamp), style: AppTextStyles.labelText),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 48),
            Text(notification.body, style: AppTextStyles.bodyText),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(onPressed: (){}, icon: const Icon(Icons.delete_outline, color: AppColors.errorColor)),
                const SizedBox(width: 40),
                IconButton(onPressed: (){}, icon: const Icon(Icons.share_outlined, color: AppColors.primaryColor)),
              ],
            )
          ],
        ),
      ),
    );
  }
}