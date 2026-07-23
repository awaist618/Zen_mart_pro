import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/providers.dart';
import '../../models/notification_model.dart';
import '../../theme/app_colors.dart';
import '../../core/localization.dart';

class CustomerNotificationsScreen extends ConsumerWidget {
  const CustomerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userModelProvider).asData?.value;
    if (user == null) return const Scaffold(backgroundColor: AppColors.background, body: Center(child: CircularProgressIndicator(color: AppColors.primary)));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: ref.read(customerServiceProvider).getNotifications(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: AppColors.error)));
          
          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.notifications_none_rounded, size: 64, color: AppColors.surface),
                  const SizedBox(height: 16),
                  Text('no_notifications'.tr(ref), style: const TextStyle(color: AppColors.textHint, fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return _NotificationTile(notif: notif);
            },
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notif;
  const _NotificationTile({required this.notif});

  @override
  Widget build(BuildContext context) {
    final bool isRead = notif.isRead;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead ? AppColors.surface.withOpacity(0.5) : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: isRead ? null : Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isRead ? AppColors.background : AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIcon(notif.type), 
              color: isRead ? AppColors.textDisabled : AppColors.primary, 
              size: 20
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notif.title, 
                  style: TextStyle(
                    fontWeight: FontWeight.w800, 
                    fontSize: 15, 
                    color: isRead ? AppColors.textSecondary : Colors.white
                  )
                ),
                const SizedBox(height: 6),
                Text(
                  notif.message, 
                  style: TextStyle(
                    color: isRead ? AppColors.textDisabled : AppColors.textSecondary, 
                    fontSize: 13, 
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  )
                ),
                const SizedBox(height: 10),
                Text(
                  DateFormat('MMM dd • h:mm a').format(notif.timestamp),
                  style: const TextStyle(color: AppColors.textHint, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          if (!isRead)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 8, 
              height: 8, 
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)
            ),
        ],
      ),
    );
  }

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.orderStatus: return Icons.shopping_bag_rounded;
      case NotificationType.offer: return Icons.local_offer_rounded;
      case NotificationType.supportTicket: return Icons.forum_rounded;
      default: return Icons.notifications_rounded;
    }
  }
}
