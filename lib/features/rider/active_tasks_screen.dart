import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/providers.dart';
import '../../models/order_model.dart';
import '../../theme/app_colors.dart';

class ActiveTasksScreen extends ConsumerWidget {
  const ActiveTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeOrdersAsync = ref.watch(activeRiderOrdersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Active Tasks', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: activeOrdersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text('No active deliveries in progress.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 20),
            itemBuilder: (context, index) => _ActiveTaskCard(order: orders[index], ref: ref),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _ActiveTaskCard extends StatelessWidget {
  final OrderModel order;
  final WidgetRef ref;
  const _ActiveTaskCard({required this.order, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Order #${order.id.substring(0, 8).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold)),
              _StatusChip(status: order.status),
            ],
          ),
          const Divider(height: 32),
          _AddressRow(label: 'PICKUP', name: order.shopName, address: order.pickupAddress, icon: Icons.storefront_rounded),
          const SizedBox(height: 20),
          _AddressRow(label: 'DELIVERY', name: order.customerName, address: order.deliveryAddress, icon: Icons.location_on_rounded),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ActionButton(
                icon: Icons.directions_rounded, 
                label: 'Navigate', 
                color: Colors.blue,
                onTap: () => launchUrl(Uri.parse('google.navigation:q=${order.deliveryAddress}')),
              ),
              _ActionButton(
                icon: Icons.chat_bubble_rounded, 
                label: 'Chat',
                onTap: () => context.push('/chat/${order.id}/${order.customerName}'),
              ),
              _ActionButton(
                icon: Icons.call_rounded, 
                label: 'Call',
                onTap: () => launchUrl(Uri.parse('tel:${order.customerPhone}')),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _NextStepButton(order: order, ref: ref),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final OrderStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: AppColors.rider.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(
        status.name.toUpperCase(),
        style: const TextStyle(color: AppColors.rider, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _AddressRow extends StatelessWidget {
  final String label;
  final String name;
  final String address;
  final IconData icon;

  const _AddressRow({required this.label, required this.name, required this.address, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(address, style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionButton({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: (color ?? AppColors.rider).withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color ?? AppColors.rider, size: 20),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color ?? AppColors.rider)),
        ],
      ),
    );
  }
}

class _NextStepButton extends StatelessWidget {
  final OrderModel order;
  final WidgetRef ref;
  const _NextStepButton({required this.order, required this.ref});

  @override
  Widget build(BuildContext context) {
    String text = 'Next Step';
    OrderStatus next;
    
    if (order.status == OrderStatus.accepted) {
      text = 'Mark as Reached Vendor';
      next = OrderStatus.reachedVendor;
    } else if (order.status == OrderStatus.reachedVendor) {
      text = 'Mark as Picked Up';
      next = OrderStatus.pickedUp;
    } else if (order.status == OrderStatus.pickedUp) {
      text = 'Out for Delivery';
      next = OrderStatus.outForDelivery;
    } else if (order.status == OrderStatus.outForDelivery) {
      text = 'Mark as Delivered';
      next = OrderStatus.delivered;
    } else {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (next == OrderStatus.delivered) {
            context.push('/rider/order-details/${order.id}');
          } else {
            ref.read(orderServiceProvider).updateStatus(order.id, next);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.rider,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
