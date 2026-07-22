import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/providers.dart';
import '../../models/order_model.dart';
import '../../theme/app_colors.dart';

class OrderDetailsScreen extends ConsumerWidget {
  final String orderId;
  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeOrdersAsync = ref.watch(activeRiderOrdersProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Order $orderId', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: activeOrdersAsync.when(
        data: (orders) {
          final order = orders.firstWhere((o) => o.id == orderId, 
              orElse: () => throw Exception('Order not found'));
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusTimeline(currentStatus: order.status),
                const SizedBox(height: 32),
                _InfoCard(
                  orderId: order.id,
                  title: 'Vendor Details',
                  name: order.shopName,
                  address: order.pickupAddress,
                  phone: order.vendorPhone,
                  icon: Icons.storefront_rounded,
                ),
                const SizedBox(height: 16),
                _InfoCard(
                  orderId: order.id,
                  title: 'Customer Details',
                  name: order.customerName,
                  address: order.deliveryAddress,
                  phone: order.customerPhone,
                  icon: Icons.person_rounded,
                ),
                const SizedBox(height: 32),
                const Text('Product Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: order.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${item['name']} x${item['quantity']}'),
                          Text('Rs ${item['price']}'),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
      bottomSheet: activeOrdersAsync.when(
        data: (orders) {
          final order = orders.firstWhere((o) => o.id == orderId);
          return _ActionPanel(order: order, ref: ref);
        },
        loading: () => const SizedBox.shrink(),
        error: (e, s) => const SizedBox.shrink(),
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final OrderStatus currentStatus;
  const _StatusTimeline({required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final steps = [
      {'status': OrderStatus.accepted, 'label': 'Accepted'},
      {'status': OrderStatus.reachedVendor, 'label': 'Reached Vendor'},
      {'status': OrderStatus.pickedUp, 'label': 'Picked Up'},
      {'status': OrderStatus.outForDelivery, 'label': 'On the Way'},
      {'status': OrderStatus.delivered, 'label': 'Delivered'},
    ];

    return Row(
      children: steps.map((step) {
        final index = steps.indexOf(step);
        final isActive = OrderStatus.values.indexOf(currentStatus) >= OrderStatus.values.indexOf(step['status'] as OrderStatus);
        
        return Expanded(
          child: Column(
            children: [
              Container(
                height: 4,
                color: isActive ? AppColors.rider : Colors.grey.withOpacity(0.2),
              ),
              const SizedBox(height: 8),
              Text(
                step['label'] as String,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? AppColors.rider : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String orderId;
  final String title;
  final String name;
  final String address;
  final String phone;
  final IconData icon;

  const _InfoCard({
    required this.orderId,
    required this.title,
    required this.name,
    required this.address,
    required this.phone,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.rider, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const Divider(height: 24),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(address, style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 13)),
          const SizedBox(height: 16),
          Row(
            children: [
              _ContactButton(
                icon: Icons.call_rounded,
                label: 'Call',
                onTap: () => launchUrl(Uri.parse('tel:$phone')),
              ),
              const SizedBox(width: 12),
              _ContactButton(
                icon: Icons.chat_bubble_rounded,
                label: 'Chat',
                onTap: () => GoRouter.of(context).push('/chat/$orderId/$name'),
              ),
              const Spacer(),
              _ContactButton(
                icon: Icons.directions_rounded,
                label: 'Navigate',
                onTap: () => launchUrl(Uri.parse('google.navigation:q=$address')),
                color: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ContactButton({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: (color ?? AppColors.rider).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color ?? AppColors.rider),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color ?? AppColors.rider, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  final OrderModel order;
  final WidgetRef ref;

  const _ActionPanel({required this.order, required this.ref});

  @override
  Widget build(BuildContext context) {
    String buttonText = 'Next Step';
    OrderStatus nextStatus = order.status;

    switch (order.status) {
      case OrderStatus.accepted:
        buttonText = 'I have reached Vendor';
        nextStatus = OrderStatus.reachedVendor;
        break;
      case OrderStatus.reachedVendor:
        buttonText = 'I have picked up order';
        nextStatus = OrderStatus.pickedUp;
        break;
      case OrderStatus.pickedUp:
        buttonText = 'Out for delivery';
        nextStatus = OrderStatus.outForDelivery;
        break;
      case OrderStatus.outForDelivery:
        buttonText = 'Mark as Delivered';
        nextStatus = OrderStatus.delivered;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: ElevatedButton(
        onPressed: () {
          ref.read(riderServiceProvider).updateOrderStatus(order.id, nextStatus);
          if (nextStatus == OrderStatus.delivered) {
             context.pop();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.rider,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(buttonText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
