import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/providers.dart';
import '../../theme/app_colors.dart';

class RiderEarningsScreen extends ConsumerWidget {
  const RiderEarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayHistoryAsync = ref.watch(todayRiderHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Today's Earnings", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: todayHistoryAsync.when(
        data: (orders) {
          final double subtotal = orders.fold(0, (sum, item) => sum + item.deliveryFee);
          final double bonus = orders.length >= 10 ? 500 : 0; // Example bonus logic
          final double total = subtotal + bonus;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _EarningSummaryCard(
                  total: total,
                  deliveries: orders.length,
                  bonus: bonus,
                ),
                const SizedBox(height: 32),
                const Text('Delivery Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (orders.isEmpty)
                  const Center(child: Text('No deliveries completed today yet.'))
                else
                  ...orders.map((order) => _OrderEarningTile(order: order)),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _EarningSummaryCard extends StatelessWidget {
  final double total;
  final int deliveries;
  final double bonus;

  const _EarningSummaryCard({required this.total, required this.deliveries, required this.bonus});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.rider, Color(0xFFE11D48)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: AppColors.rider.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Text("TODAY'S TOTAL", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text('Rs ${total.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(label: 'Deliveries', value: deliveries.toString()),
              Container(width: 1, height: 30, color: Colors.white24),
              _StatItem(label: 'Bonus', value: 'Rs ${bonus.toStringAsFixed(0)}'),
              Container(width: 1, height: 30, color: Colors.white24),
              _StatItem(label: 'Tips', value: 'Rs 0'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
      ],
    );
  }
}

class _OrderEarningTile extends StatelessWidget {
  final dynamic order;
  const _OrderEarningTile({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order #${order.id.substring(0, 8).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                '${DateFormat('h:mm a').format(order.deliveredAt!)} • ${order.shopName}',
                style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 12),
              ),
            ],
          ),
          Text(
            '+ Rs ${order.deliveryFee.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
