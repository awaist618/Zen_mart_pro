import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/providers.dart';
import '../../models/order_model.dart';
import '../../theme/app_colors.dart';

class RiderHistoryScreen extends ConsumerStatefulWidget {
  const RiderHistoryScreen({super.key});

  @override
  ConsumerState<RiderHistoryScreen> createState() => _RiderHistoryScreenState();
}

class _RiderHistoryScreenState extends ConsumerState<RiderHistoryScreen> {
  String _filter = 'Today';

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(riderHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Delivery History', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _FilterChip(label: 'Today', isSelected: _filter == 'Today', onSelected: () => setState(() => _filter = 'Today')),
                _FilterChip(label: 'Week', isSelected: _filter == 'Week', onSelected: () => setState(() => _filter = 'Week')),
                _FilterChip(label: 'Month', isSelected: _filter == 'Month', onSelected: () => setState(() => _filter = 'Month')),
                _FilterChip(label: 'All', isSelected: _filter == 'All', onSelected: () => setState(() => _filter = 'All')),
              ],
            ),
          ),
        ),
      ),
      body: historyAsync.when(
        data: (orders) {
          final filteredOrders = _applyFilter(orders);
          
          if (filteredOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_rounded, size: 64, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text('No deliveries found for $_filter', style: const TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: filteredOrders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) => _HistoryTile(order: filteredOrders[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  List<OrderModel> _applyFilter(List<OrderModel> orders) {
    final now = DateTime.now();
    switch (_filter) {
      case 'Today':
        return orders.where((o) => o.deliveredAt != null && 
          o.deliveredAt!.year == now.year && o.deliveredAt!.month == now.month && o.deliveredAt!.day == now.day).toList();
      case 'Week':
        final weekAgo = now.subtract(const Duration(days: 7));
        return orders.where((o) => o.deliveredAt != null && o.deliveredAt!.isAfter(weekAgo)).toList();
      case 'Month':
        final monthAgo = DateTime(now.year, now.month - 1, now.day);
        return orders.where((o) => o.deliveredAt != null && o.deliveredAt!.isAfter(monthAgo)).toList();
      default:
        return orders;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({required this.label, required this.isSelected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(),
        selectedColor: AppColors.rider,
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final OrderModel order;
  const _HistoryTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final bool isCancelled = order.status == OrderStatus.cancelled || order.status == OrderStatus.rejected;

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
                decoration: BoxDecoration(
                  color: (isCancelled ? Colors.red : Colors.green).withOpacity(0.1), 
                  shape: BoxShape.circle
                ),
                child: Icon(
                  isCancelled ? Icons.cancel_rounded : Icons.check_circle_rounded, 
                  color: isCancelled ? Colors.red : Colors.green, 
                  size: 20
                ),
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
                style: TextStyle(
                  fontWeight: FontWeight.w800, 
                  color: isCancelled ? Colors.grey : const Color(0xFF10B981)
                ),
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
                    order.deliveredAt != null 
                        ? DateFormat('MMM dd, h:mm a').format(order.deliveredAt!) 
                        : DateFormat('MMM dd, h:mm a').format(order.createdAt),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isCancelled ? Colors.red : Colors.green).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isCancelled ? 'CANCELLED' : 'COMPLETED',
                  style: TextStyle(
                    color: isCancelled ? Colors.red : Colors.green,
                    fontSize: 9,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
