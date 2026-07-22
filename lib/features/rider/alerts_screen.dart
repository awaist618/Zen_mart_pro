import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../models/rider_notification_model.dart';
import '../../theme/app_colors.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(riderNotificationsProvider);
    final user = ref.watch(userModelProvider).asData?.value;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          if (notificationsAsync.asData?.value.isNotEmpty ?? false)
            TextButton(
              onPressed: () {
                // Logic to mark all as read could be added here
              },
              child: const Text('Mark all read', style: TextStyle(color: AppColors.rider)),
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
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _NotificationTile(
                notification: notification,
                onDelete: () => ref.read(riderServiceProvider).deleteNotification(user!.uid, notification.id),
                onTap: () {
                  ref.read(riderServiceProvider).markAsRead(user!.uid, notification.id);
                  if (notification.data?['orderId'] != null) {
                    context.push('/rider/order-details/${notification.data!['orderId']}');
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final RiderNotificationModel notification;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : AppColors.rider.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead ? Colors.transparent : AppColors.rider.withOpacity(0.1),
          ),
        ),
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: _getIconColor(notification.type).withOpacity(0.1),
            child: Icon(_getIcon(notification.type), color: _getIconColor(notification.type), size: 20),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
              fontSize: 14,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notification.message, style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.6))),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMM dd, h:mm a').format(notification.timestamp),
                style: TextStyle(fontSize: 10, color: Colors.black.withOpacity(0.4)),
              ),
            ],
          ),
          isThreeLine: true,
        ),
      ),
    );
  }

  IconData _getIcon(RiderNotificationType type) {
    switch (type) {
      case RiderNotificationType.newRequest: return Icons.delivery_dining_rounded;
      case RiderNotificationType.deliveryCancelled: return Icons.cancel_outlined;
      case RiderNotificationType.assignmentUpdated: return Icons.assignment_turned_in_outlined;
      case RiderNotificationType.paymentReceived: return Icons.account_balance_wallet_outlined;
      case RiderNotificationType.bonusEarned: return Icons.card_giftcard_rounded;
      case RiderNotificationType.systemAnnouncement: return Icons.campaign_outlined;
      default: return Icons.notifications_none_rounded;
    }
  }

  Color _getIconColor(RiderNotificationType type) {
    switch (type) {
      case RiderNotificationType.deliveryCancelled: return Colors.redAccent;
      case RiderNotificationType.paymentReceived:
      case RiderNotificationType.bonusEarned: return Colors.green;
      case RiderNotificationType.newRequest: return AppColors.rider;
      default: return Colors.blue;
    }
  }
}
