import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/providers.dart';
import '../../core/localization.dart';
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

  final List<String> _tabs = ['Ongoing', 'History', 'Cancelled'];

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
      case 0: return [
        OrderStatus.pending, 
        OrderStatus.confirmed, 
        OrderStatus.accepted, 
        OrderStatus.preparing, 
        OrderStatus.reachedVendor, 
        OrderStatus.pickedUp, 
        OrderStatus.outForDelivery
      ];
      case 1: return [OrderStatus.delivered];
      case 2: return [OrderStatus.cancelled, OrderStatus.rejected];
      default: return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(customerOrdersProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('order_history'.tr(ref), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Theme.of(context).textTheme.displayLarge?.color,
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.accent,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.accent,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              tabs: _tabs.map((t) => Tab(text: t)).toList(),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(),
        children: List.generate(_tabs.length, (index) {
          return ordersAsync.when(
            data: (orders) {
              final statusList = _getStatusListForTab(index);
              final filtered = orders.where((o) => statusList.contains(o.status)).toList();

              if (filtered.isEmpty) {
                return _EmptyOrdersState(label: _tabs[index]);
              }

              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: filtered.length,
                physics: const BouncingScrollPhysics(),
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) => _OrderCard(order: filtered[index]),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
          );
        }),
      ),
      bottomNavigationBar: const CustomerBottomNav(currentIndex: 2), // Index 2 for Orders
    );
  }
}

class _EmptyOrdersState extends StatelessWidget {
  final String label;
  const _EmptyOrdersState({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
            child: Icon(Icons.receipt_long_rounded, size: 48, color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          Text('No $label orders found', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          Text('Orders you place will appear here', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
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
      borderRadius: BorderRadius.circular(32),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10)),
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.accent.withOpacity(0.15), AppColors.accent.withOpacity(0.05)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.storefront_rounded, color: AppColors.accent, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.shopName, 
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, letterSpacing: -0.2)
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Order #${order.id.substring(0, 8).toUpperCase()}',
                        style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.3), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: order.status),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Divider(height: 1, thickness: 1.2),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${order.items.length} ${order.items.length == 1 ? 'ITEM' : 'ITEMS'} • Rs ${order.totalAmount.toStringAsFixed(0)}',
                      style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy • h:mm a').format(order.createdAt),
                      style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.2), fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Track', style: TextStyle(color: Theme.of(context).textTheme.displayLarge?.color, fontWeight: FontWeight.w900, fontSize: 13)),
                        const SizedBox(width: 6),
                        Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Theme.of(context).textTheme.displayLarge?.color),
                      ],
                    ),
                  ),
                ),
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
    String label = status.name.toUpperCase();
    
    switch (status) {
      case OrderStatus.pending: 
        color = Colors.orange; 
        break;
      case OrderStatus.confirmed:
      case OrderStatus.accepted: 
        color = Colors.blue; 
        break;
      case OrderStatus.preparing: 
        color = Colors.indigo; 
        break;
      case OrderStatus.outForDelivery:
      case OrderStatus.pickedUp: 
        color = Colors.purple; 
        label = status == OrderStatus.outForDelivery ? 'ON THE WAY' : 'PICKED UP';
        break;
      case OrderStatus.delivered: 
        color = const Color(0xFF10B981); 
        break;
      case OrderStatus.cancelled:
      case OrderStatus.rejected: 
        color = Colors.redAccent; 
        break;
      default: 
        color = AppColors.accent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12), 
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.8),
      ),
    );
  }
}
