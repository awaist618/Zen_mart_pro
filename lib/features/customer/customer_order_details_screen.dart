import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../models/order_model.dart';
import '../../theme/app_colors.dart';

class CustomerOrderDetailsScreen extends ConsumerWidget {
  final String orderId;
  const CustomerOrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Order Tracking', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<OrderModel?>(
        future: ref.read(vendorServiceProvider).getOrder(orderId), // Reusing vendor service for detail fetch
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final order = snapshot.data;
          if (order == null) return const Center(child: Text('Order not found'));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusTracker(order.status),
                const SizedBox(height: 32),
                _SectionTitle(title: 'Delivery Address'),
                const SizedBox(height: 12),
                _InfoCard(
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_rounded, color: AppColors.accent),
                      const SizedBox(width: 16),
                      Expanded(child: Text(order.deliveryAddress, style: const TextStyle(fontWeight: FontWeight.w500))),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                if (order.riderId != null) ...[
                  _SectionTitle(title: 'Rider Information'),
                  const SizedBox(height: 12),
                  _buildRiderCard(context, order),
                  const SizedBox(height: 32),
                ],
                _SectionTitle(title: 'Order Summary'),
                const SizedBox(height: 12),
                _buildOrderSummary(order),
                const SizedBox(height: 40),
                _buildActionButtons(context, order),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusTracker(OrderStatus status) {
    // Simplified stepper for tracking
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Order Status', style: TextStyle(color: Colors.black.withOpacity(0.4), fontWeight: FontWeight.bold)),
              Text(status.name.toUpperCase(), style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 24),
          // Placeholder for visual tracking line
          const LinearProgressIndicator(value: 0.5, backgroundColor: Color(0xFFF1F5F9), color: AppColors.accent),
        ],
      ),
    );
  }

  Widget _buildRiderCard(BuildContext context, OrderModel order) {
    return _InfoCard(
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: Color(0xFFF1F5F9), child: Icon(Icons.person_rounded, color: Colors.grey)),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('John Doe', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Assigned Rider', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call_rounded, color: Colors.green),
            style: IconButton.styleFrom(backgroundColor: Colors.green.withOpacity(0.1)),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(OrderModel order) {
    return _InfoCard(
      child: Column(
        children: [
          ...order.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${item['name']} x${item['quantity']}', style: const TextStyle(fontSize: 14)),
                Text('Rs ${item['price'] * item['quantity']}'),
              ],
            ),
          )),
          const Divider(height: 24),
          const _Row(label: 'Delivery Fee', value: 'Rs 100'),
          const _Row(label: 'Taxes', value: 'Rs 20'),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('Rs ${order.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.accent)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, OrderModel order) {
    return Column(
      children: [
        if (order.status == OrderStatus.delivered)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Reorder Items', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        const SizedBox(height: 12),
        if (order.status == OrderStatus.delivered)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Rate & Review', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        if (order.status == OrderStatus.pending)
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {},
              child: const Text('Cancel Order', style: TextStyle(color: Colors.red)),
            ),
          ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) => Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
}

class _InfoCard extends StatelessWidget {
  final Widget child;
  const _InfoCard({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10)]),
    child: child,
  );
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)), Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))]),
  );
}
