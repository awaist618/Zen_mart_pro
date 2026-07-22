import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/providers.dart';
import '../../models/notification_model.dart';
import '../../theme/app_colors.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(adminNotificationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
            onPressed: () {
              // TODO: Mark all as read
            },
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none_rounded, size: 64, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text('No notifications yet', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _NotificationTile(notification: notifications[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final NotificationModel notification;
  const _NotificationTile({required this.notification});

  IconData _getIcon() {
    switch (notification.type) {
      case NotificationType.vendorRegistration: return Icons.person_add_rounded;
      case NotificationType.newOrder: return Icons.shopping_cart_rounded;
      case NotificationType.complaint: return Icons.report_problem_rounded;
      case NotificationType.riderRequest: return Icons.directions_bike_rounded;
      case NotificationType.paymentAlert: return Icons.payments_rounded;
      case NotificationType.lowStock: return Icons.warning_amber_rounded;
      case NotificationType.maintenance: return Icons.settings_rounded;
      case NotificationType.securityAlert: return Icons.security_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _getColor() {
    switch (notification.type) {
      case NotificationType.vendorRegistration: return Colors.blue;
      case NotificationType.newOrder: return Colors.green;
      case NotificationType.complaint: return Colors.red;
      case NotificationType.riderRequest: return Colors.orange;
      case NotificationType.paymentAlert: return Colors.teal;
      case NotificationType.lowStock: return Colors.amber;
      case NotificationType.maintenance: return Colors.blueGrey;
      case NotificationType.securityAlert: return Colors.deepOrange;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        ref.read(adminServiceProvider).deleteNotification(notification.id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            ref.read(adminServiceProvider).markAsRead(notification.id);
          }
          // TODO: Navigate based on type
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.white : Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: notification.isRead ? Border.all(color: Colors.grey.withOpacity(0.1)) : Border.all(color: Colors.blue.withOpacity(0.2)),
            boxShadow: [
              if (notification.isRead)
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getColor().withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(_getIcon(), color: _getColor(), size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                            fontSize: 15,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          DateFormat('h:mm a').format(notification.timestamp),
                          style: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('New', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
