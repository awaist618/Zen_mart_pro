import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/providers.dart';
import '../../models/order_model.dart';
import '../../theme/app_colors.dart';
import './widgets/customer_bottom_nav.dart';

class CustomerOrdersScreen extends ConsumerStatefulWidget {
  const CustomerOrdersScreen({super.key});

  @override
  ConsumerState<CustomerOrdersScreen> createState() => _CustomerOrdersScreenState();
}

class _CustomerOrdersScreenState extends ConsumerState<CustomerOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = ['Active', 'Preparing', 'Out for Delivery', 'Delivered', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<OrderStatus> _getStatusListForTab(int index) {
    switch (index) {
      case 0: return [OrderStatus.pending, OrderStatus.confirmed, OrderStatus.accepted];
      case 1: return [OrderStatus.preparing];
      case 2: return [OrderStatus.reachedVendor, OrderStatus.pickedUp, OrderStatus.outForDelivery];
      case 3: return [OrderStatus.delivered];
      case 4: return [OrderStatus.cancelled, OrderStatus.rejected];
      default: return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(customerOrdersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('My Orders', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.accent,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.accent,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(_tabs.length, (index) {
          return ordersAsync.when(
            data: (orders) {
              final statusList = _getStatusListForTab(index);
              final filtered = orders.where((o) => statusList.contains(orderStatusFromModel(o.status))).toList();

              if (filtered.isEmpty) {
                return _EmptyState(label: _tabs[index]);
              }

              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) => _OrderCard(order: filtered[index]),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
          );
        }),
      ),
      bottomNavigationBar: const CustomerBottomNav(currentIndex: 3),
    );
  }

  // Helper because OrderModel uses the enum but Firestore returns string
  OrderStatus orderStatusFromModel(OrderStatus status) => status;
}

class _EmptyState extends StatelessWidget {
  final String label;
  const _EmptyState({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_rounded, size: 64, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('No $label orders', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/customer/order-details/${order.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
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
                  decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.shopping_bag_outlined, color: AppColors.accent, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.shopName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        '${order.items.length} items • Rs ${order.totalAmount.toStringAsFixed(0)}',
                        style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: order.status),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM dd, h:mm a').format(order.createdAt),
                  style: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 11),
                ),
                const Text('View Details', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case OrderStatus.pending: color = Colors.orange; break;
      case OrderStatus.preparing: color = Colors.blue; break;
      case OrderStatus.outForDelivery: color = Colors.purple; break;
      case OrderStatus.delivered: color = Colors.green; break;
      case OrderStatus.cancelled:
      case OrderStatus.rejected: color = Colors.red; break;
      default: color = AppColors.accent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }
}
