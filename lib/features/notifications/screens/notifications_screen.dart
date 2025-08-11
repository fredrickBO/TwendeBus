// lib/features/notifications/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:twende_bus_ui/core/providers.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});
  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // After the screen is built, mark all notifications as read.
    // We add a small delay to ensure the user is logged in.
    Future.delayed(const Duration(seconds: 1), () {
      final uid = ref.read(authServiceProvider).currentUser?.uid;
      if (uid != null) {
        ref.read(firestoreServiceProvider).markNotificationsAsRead(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(userNotificationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(child: Text("You have no notifications."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return NotificationItem(
                // Pass the live data to the item widget
                date: DateFormat('d MMMM yyyy').format(notif.timestamp),
                time: DateFormat('h:mm a').format(notif.timestamp),
                title: notif.title,
                body: notif.body,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, __) =>
            const Center(child: Text("Could not load notifications.")),
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
