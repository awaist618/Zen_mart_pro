import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: Text('notifications'.tr(ref), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: ref.read(customerServiceProvider).getNotifications(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          
          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none_rounded, size: 64, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text('no_notifications'.tr(ref), style: const TextStyle(color: Colors.grey)),
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
        color: isRead ? Theme.of(context).cardTheme.color : AppColors.accent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isRead ? Colors.grey.withOpacity(0.1) : AppColors.accent.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isRead ? Colors.grey.withOpacity(0.1) : AppColors.accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIcon(notif.type), 
              color: isRead ? Colors.grey : AppColors.accent, 
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isRead ? Colors.grey[600] : null)
                ),
                const SizedBox(height: 4),
                Text(
                  notif.message, 
                  style: TextStyle(color: isRead ? Colors.grey : Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13, height: 1.4)
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('MMM dd, h:mm a').format(notif.timestamp),
                  style: TextStyle(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          if (!isRead)
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
        ],
      ),
    );
  }

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.orderStatus: return Icons.shopping_bag_rounded;
      case NotificationType.offer: return Icons.local_offer_rounded;
      case NotificationType.supportTicket: return Icons.info_rounded;
      default: return Icons.notifications_rounded;
    }
  }
}
