import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/providers.dart';
import '../../models/order_model.dart';
import '../../theme/app_colors.dart';

class RiderHistoryScreen extends ConsumerWidget {
  const RiderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(riderHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Delivery History', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: historyAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text('No completed deliveries yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) => _HistoryTile(order: orders[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final OrderModel order;
  const _HistoryTile({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order #${order.id.substring(0, 8).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '${order.shopName} → ${order.customerName}',
                      style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                'Rs ${order.deliveryFee.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF10B981)),
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    order.deliveredAt != null ? DateFormat('MMM dd, h:mm a').format(order.deliveredAt!) : 'N/A',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.route_outlined, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  const Text('2.4 km', style: TextStyle(fontSize: 11, color: Colors.grey)), // Placeholder for distance
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
