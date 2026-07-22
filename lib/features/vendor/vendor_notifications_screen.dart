import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/providers.dart';
import '../../models/vendor_notification_model.dart';
import '../../theme/app_colors.dart';

class VendorNotificationsScreen extends ConsumerWidget {
  const VendorNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(vendorNotificationsProvider);
    final user = ref.watch(userModelProvider).asData?.value;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Vendor Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
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
                  const Text('No alerts for your shop yet', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _VendorNotificationTile(
              notification: notifications[index],
              vendorId: user?.uid ?? '',
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _VendorNotificationTile extends ConsumerWidget {
  final VendorNotificationModel notification;
  final String vendorId;
  const _VendorNotificationTile({required this.notification, required this.vendorId});

  IconData _getIcon() {
    switch (notification.type) {
      case VendorNotificationType.newOrder: return Icons.shopping_bag_rounded;
      case VendorNotificationType.orderCancelled: return Icons.cancel_schedule_send_rounded;
      case VendorNotificationType.newReview: return Icons.rate_review_rounded;
      case VendorNotificationType.lowStock: return Icons.warning_amber_rounded;
      case VendorNotificationType.shopApproved: return Icons.verified_user_rounded;
      case VendorNotificationType.bannerUpdated: return Icons.photo_library_rounded;
      case VendorNotificationType.couponExpired: return Icons.confirmation_number_rounded;
      case VendorNotificationType.systemAnnouncement: return Icons.campaign_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _getColor() {
    switch (notification.type) {
      case VendorNotificationType.newOrder: return Colors.green;
      case VendorNotificationType.orderCancelled: return Colors.red;
      case VendorNotificationType.newReview: return Colors.blue;
      case VendorNotificationType.lowStock: return Colors.orange;
      case VendorNotificationType.shopApproved: return Colors.purple;
      case VendorNotificationType.bannerUpdated: return Colors.teal;
      case VendorNotificationType.couponExpired: return Colors.brown;
      case VendorNotificationType.systemAnnouncement: return Colors.indigo;
      default: return const Color(0xFF8B5CF6); // Vendor Primary
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        ref.read(vendorServiceProvider).deleteNotification(vendorId, notification.id);
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
            ref.read(vendorServiceProvider).markAsRead(vendorId, notification.id);
          }
          // TODO: Navigate to Order Details, Inventory, or Reviews based on type
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.white : const Color(0xFF8B5CF6).withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: notification.isRead 
                ? Border.all(color: Colors.grey.withOpacity(0.1)) 
                : Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.2)),
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
                          color: const Color(0xFF8B5CF6),
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
