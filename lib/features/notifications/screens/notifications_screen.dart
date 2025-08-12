// lib/features/notifications/screens/notifications_screen.dart
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:twende_bus_ui/core/models/notification_model.dart';
import 'package:twende_bus_ui/core/providers.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';
import 'package:twende_bus_ui/features/notifications/screens/notification_details_screen.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});
  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> with SingleTickerProviderStateMixin {

  late TabController _tabController;
  bool _isSelectionMode = false;
  final Set<String> _selectedNotificationIds = {};
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _markAsreadOnOpen();
  
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // This function marks all notifications as read when the screen is opened.
  void _markAsreadOnOpen(){
    Future.delayed(const Duration(seconds: 1), () {
      final uid = ref.read(authServiceProvider).currentUser?.uid;
      if (uid != null) {
        ref.read(firestoreServiceProvider).markSingleNotificationAsRead(uid);
      }
    });
  }

  // This function is now the central point for handling a tap.
  void _onNotificationTap(NotificationModel notification) {
    if (_isSelectionMode) {
      // Logic for selection mode is unchanged.
      setState(() {
        if (_selectedNotificationIds.contains(notification.id)) {
          _selectedNotificationIds.remove(notification.id);
          if (_selectedNotificationIds.isEmpty) _isSelectionMode = false;
        } else {
          _selectedNotificationIds.add(notification.id);
        }
      });
    } else {

      if (!notification.isRead) {
        ref.read(firestoreServiceProvider).markSingleNotificationAsRead(notification.id);
      }
      // Navigate to the details screen if not in selection mode.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NotificationDetailsScreen(notification: notification),
        ),
      );
    }
  }

  void _toggleSelectionMode(String notificationId) {
    setState(() {
      _isSelectionMode = true;
      _selectedNotificationIds.add(notificationId);
    });
  }

  Future<void> _deleteSelected() async {
    try {
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('deleteNotifications');
      await callable.call({'notificationIds': _selectedNotificationIds.toList()});
      
      setState(() {
        _selectedNotificationIds.clear();
        _isSelectionMode = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Notifications deleted.")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not delete notifications."), backgroundColor: AppColors.errorColor));
      }
    }
  }

  @override
Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(userNotificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isSelectionMode ? "${_selectedNotificationIds.length} selected" : "Notifications"),
        leading: _isSelectionMode 
          ? IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() { _isSelectionMode = false; _selectedNotificationIds.clear(); }))
          : const BackButton(),
        actions: _isSelectionMode
          ? [IconButton(icon: const Icon(Icons.delete_outline), onPressed: _deleteSelected)]
          : [],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: "All"), Tab(text: "Unread"), Tab(text: "Read")],
        ),
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          final unread = notifications.where((n) => !n.isRead).toList();
          final read = notifications.where((n) => n.isRead).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _NotificationListView(
                notifications: notifications,
                onTap: _onNotificationTap,
                onLongPress: _toggleSelectionMode,
                isSelectionMode: _isSelectionMode,
                selectedIds: _selectedNotificationIds,
              ),
              _NotificationListView(notifications: unread, onTap: _onNotificationTap, onLongPress: _toggleSelectionMode, isSelectionMode: _isSelectionMode, selectedIds: _selectedNotificationIds),
              _NotificationListView(notifications: read, onTap: _onNotificationTap, onLongPress: _toggleSelectionMode, isSelectionMode: _isSelectionMode, selectedIds: _selectedNotificationIds),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, __) => const Center(child: Text("Could not load notifications.")),
      ),
    );
  }
}

class _NotificationListView extends StatelessWidget {
  final List<NotificationModel> notifications;
  final Function(NotificationModel) onTap;
  final Function(String) onLongPress;
  final bool isSelectionMode;
  final Set<String> selectedIds;

  const _NotificationListView({
    required this.notifications, required this.onTap, required this.onLongPress,
    required this.isSelectionMode, required this.selectedIds,
  });

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) return const Center(child: Text("No notifications here."));
    
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notif = notifications[index];
        final isSelected = selectedIds.contains(notif.id);

        return Card(
          color: isSelected ? AppColors.primaryColor.withOpacity(0.2)
          : !notif.isRead ? AppColors.primaryColor.withOpacity(0.1) : null,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            onTap: () => onTap(notif),
            onLongPress: () => onLongPress(notif.id),
            leading: isSelectionMode 
              ? Checkbox(value: isSelected, onChanged: (val) => onTap(notif))
              //add visual indicator for unread messages
              : CircleAvatar(child: const Icon(Icons.person)),
            title: Text(notif.title, style: TextStyle(fontWeight: !notif.isRead ? FontWeight.bold : FontWeight.normal)),
            subtitle: Text(notif.body, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Text(DateFormat('h:mm a').format(notif.timestamp), style: AppTextStyles.labelText),
          ),
        );
      },
    );
  }
}