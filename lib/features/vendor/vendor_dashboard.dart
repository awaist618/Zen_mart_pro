import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../models/order_model.dart';
import '../../theme/app_colors.dart';
import './widgets/vendor_bottom_nav.dart';

class VendorDashboard extends ConsumerWidget {
  const VendorDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _VendorHero(ref: ref),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: const _VendorKpiGrid(),
                ),
                const SizedBox(height: 8),
                const _ShopStatusCard(),
                const SizedBox(height: 24),
                const _ManageShop(),
                const SizedBox(height: 32),
                const _IncomingOrders(),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const VendorBottomNav(currentIndex: 0),
    );
  }
}

class _VendorHero extends ConsumerWidget {
  final WidgetRef ref;
  const _VendorHero({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopAsync = ref.watch(currentShopProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 100),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A), // Match App Theme Dark
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Stack(
        children: [
          // Background Blobs (Premium Theme style)
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8B5CF6).withOpacity(0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VENDOR PORTAL',
                          style: TextStyle(
                            color: const Color(0xFF8B5CF6).withOpacity(0.8),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          shopAsync.value?.name ?? 'Loading Shop...',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      _HeaderActionIcon(
                        icon: Icons.notifications_none_rounded,
                        onTap: () => context.push('/vendor/notifications'),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => context.push('/vendor/profile'),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF8B5CF6), width: 2),
                          ),
                          child: Consumer(
                            builder: (context, ref, child) {
                              final user = ref.watch(userModelProvider).asData?.value;
                              return CircleAvatar(
                                radius: 18,
                                backgroundColor: const Color(0xFF1E293B),
                                backgroundImage: (user?.profilePicture != null && user!.profilePicture!.isNotEmpty)
                                    ? NetworkImage(user.profilePicture!)
                                    : null,
                                child: (user?.profilePicture == null || user!.profilePicture!.isEmpty)
                                    ? Text(
                                        user?.name.substring(0, 1).toUpperCase() ?? 'GB',
                                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                      )
                                    : null,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              InkWell(
                onTap: () => context.push('/vendor/analytics'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Sales",
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Flexible(
                          child: Text(
                            'Rs 18,420',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: const Text(
                            '24 Orders',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderActionIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _VendorKpiGrid extends ConsumerWidget {
  const _VendorKpiGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomingOrders = ref.watch(incomingOrdersProvider).asData?.value ?? [];
    final totalItems = ref.watch(shopProductsProvider).asData?.value ?? [];
    final lowStockItems = totalItems.where((p) => p.stock < 5).length;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _KpiCard(
          title: 'New Orders',
          value: incomingOrders.length.toString().padLeft(2, '0'),
          icon: Icons.shopping_bag_rounded,
          color: const Color(0xFF8B5CF6),
          subtitle: 'Awaiting Action',
          onTap: () => context.push('/vendor/orders'),
        ),
        _KpiCard(
          title: 'Total Items',
          value: totalItems.length.toString(),
          icon: Icons.inventory_2_rounded,
          color: const Color(0xFF6366F1),
          subtitle: 'Active Products',
          onTap: () => context.push('/vendor/products'),
        ),
        _KpiCard(
          title: 'Low Stock',
          value: lowStockItems.toString().padLeft(2, '0'),
          icon: Icons.warning_amber_rounded,
          color: const Color(0xFFEF4444),
          subtitle: 'Needs Attention',
          onTap: () => context.push('/vendor/low-stock'),
        ),
        _KpiCard(
          title: 'Store Rating',
          value: '4.8',
          icon: Icons.star_rounded,
          color: const Color(0xFFF59E0B),
          subtitle: '124 Reviews',
          onTap: () => context.push('/vendor/reviews'),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;
  final VoidCallback? onTap;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withOpacity(0.5),
                    fontWeight: FontWeight.w600,
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

class _ShopStatusCard extends ConsumerWidget {
  const _ShopStatusCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopAsync = ref.watch(currentShopProvider);

    return shopAsync.when(
      data: (shop) {
        if (shop == null) return const SizedBox.shrink();
        final bool isOnline = shop.status == 'active';

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isOnline 
                  ? [const Color(0xFF8B5CF6), const Color(0xFF6366F1)]
                  : [const Color(0xFF64748B), const Color(0xFF475569)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: (isOnline ? const Color(0xFF8B5CF6) : Colors.grey).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Store Status: ${isOnline ? "Online" : "Closed"}',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isOnline 
                          ? 'Your shop is visible to customers' 
                          : 'Your shop is hidden from customers',
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: isOnline,
                onChanged: (v) {
                  ref.read(vendorServiceProvider).updateShopStatus(
                    shop.id, 
                    v ? 'active' : 'disabled'
                  );
                },
                activeColor: Colors.white,
                activeTrackColor: Colors.white.withOpacity(0.3),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => const SizedBox.shrink(),
    );
  }
}

class _ManageShop extends StatelessWidget {
  const _ManageShop();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shop Management',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ActionItem(
              label: 'Add Product', 
              icon: Icons.add_box_rounded, 
              color: const Color(0xFF10B981),
              onTap: () => context.push('/vendor/add-product'),
            ),
            _ActionItem(
              label: 'Inventory', 
              icon: Icons.list_alt_rounded, 
              color: const Color(0xFF6366F1), 
              onTap: () => context.push('/vendor/products'),
            ),
            _ActionItem(
              label: 'Coupons', 
              icon: Icons.confirmation_number_rounded, 
              color: const Color(0xFFF59E0B), 
              onTap: () => context.push('/vendor/coupons'),
            ),
            _ActionItem(
              label: 'Reviews', 
              icon: Icons.rate_review_rounded, 
              color: const Color(0xFF8B5CF6), 
              onTap: () => context.push('/vendor/reviews'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionItem({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _IncomingOrders extends ConsumerWidget {
  const _IncomingOrders();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomingOrdersAsync = ref.watch(incomingOrdersProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Orders',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => context.push('/vendor/orders'),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          incomingOrdersAsync.when(
            data: (orders) {
              if (orders.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('No pending orders', style: TextStyle(color: Colors.grey))),
                );
              }
              final recentOrders = orders.take(3).toList();
              return Column(
                children: recentOrders.map((order) {
                  return Column(
                    children: [
                      _OrderTile(
                        orderId: '#${order.id.substring(0, 4).toUpperCase()}',
                        amount: 'Rs ${order.totalAmount}',
                        customer: order.customerName,
                        time: '${DateTime.now().difference(order.createdAt).inMinutes}m ago',
                        status: 'Pending',
                        color: const Color(0xFFF59E0B),
                        onTap: () => _showOrderDetails(context, order),
                      ),
                      if (order != recentOrders.last) const Divider(height: 24),
                    ],
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(BuildContext context, OrderModel order) {
    // Navigate to order details or show a quick bottom sheet
    context.push('/vendor/order-details/${order.id}');
  }
}

class _OrderTile extends StatelessWidget {
  final String orderId;
  final String amount;
  final String customer;
  final String time;
  final String status;
  final Color color;
  final VoidCallback onTap;

  const _OrderTile({
    required this.orderId,
    required this.amount,
    required this.customer,
    required this.time,
    required this.status,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.receipt_long_rounded, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order $orderId',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  '$customer • $amount',
                  style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 11),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
