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

  final List<String> _tabs = ['ONGOING', 'HISTORY', 'CANCELLED'];

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Track My Orders', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Colors.white)),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textHint,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 1),
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
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            error: (e, s) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.error))),
          );
        }),
      ),
      bottomNavigationBar: const CustomerBottomNav(currentIndex: 2),
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
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
            child: const Icon(Icons.receipt_long_rounded, size: 48, color: Colors.white24),
          ),
          const SizedBox(height: 24),
          Text('No ${label.toLowerCase()} orders', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Place your first order to start tracking', style: TextStyle(color: AppColors.textHint, fontSize: 13, fontWeight: FontWeight.w500)),
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
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.shopName, 
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white)
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '#${order.id.substring(0, 8).toUpperCase()}',
                        style: const TextStyle(color: AppColors.textHint, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: order.status),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Divider(color: AppColors.border, thickness: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${order.items.length} ${order.items.length == 1 ? 'ITEM' : 'ITEMS'} • Rs ${order.totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd • h:mm a').format(order.createdAt),
                      style: const TextStyle(color: AppColors.textHint, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('TRACK', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.primary),
                    ],
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
      case OrderStatus.pending: color = AppColors.warning; break;
      case OrderStatus.confirmed:
      case OrderStatus.accepted: color = AppColors.info; break;
      case OrderStatus.preparing: color = Colors.indigoAccent; break;
      case OrderStatus.outForDelivery:
      case OrderStatus.pickedUp: 
        color = Colors.purpleAccent; 
        label = status == OrderStatus.outForDelivery ? 'ON THE WAY' : 'PICKED UP';
        break;
      case OrderStatus.delivered: color = AppColors.success; break;
      default: color = AppColors.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), 
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
    );
  }
}
