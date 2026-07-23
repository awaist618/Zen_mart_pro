import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/providers.dart';
import '../../models/user_model.dart';
import '../../models/order_model.dart';
import '../../theme/app_colors.dart';

class RiderDashboard extends ConsumerWidget {
  const RiderDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userModelProvider);
    final todayHistoryAsync = ref.watch(todayRiderHistoryProvider);
    final activeOrdersAsync = ref.watch(activeRiderOrdersProvider);
    final availableOrdersAsync = ref.watch(availableOrdersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('User not found'));
          
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _RiderHero(user: user, ref: ref),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Transform.translate(
                      offset: const Offset(0, -40),
                      child: _RiderKpiGrid(
                        user: user, 
                        activeOrdersCount: activeOrdersAsync.asData?.value.length ?? 0,
                        todayOrdersCount: todayHistoryAsync.asData?.value.length ?? 0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Active Delivery Section
                    activeOrdersAsync.when(
                      data: (orders) => orders.isNotEmpty 
                          ? _ActiveDeliverySummary(order: orders.first)
                          : const SizedBox.shrink(),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, s) => const SizedBox.shrink(),
                    ),
                    
                    const SizedBox(height: 24),
                    const _QuickActions(),
                    const SizedBox(height: 32),
                    
                    // Available Orders Section
                    const _AvailableOrdersHeader(),
                    const SizedBox(height: 16),
                    if (!user.isOnline)
                      _OfflineOverlay()
                    else
                      availableOrdersAsync.when(
                        data: (orders) {
                          if (orders.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Text('No available requests nearby', style: TextStyle(color: Colors.black.withOpacity(0.3))),
                              ),
                            );
                          }
                          return Column(
                            children: orders.map((o) => _OrderRequestTile(order: o, riderId: user.uid)).toList(),
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, s) => Text('Error: $e'),
                      ),
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
      bottomNavigationBar: const _RiderBottomNav(),
    );
  }
}

class _RiderHero extends StatelessWidget {
  final UserModel user;
  final WidgetRef ref;

  const _RiderHero({required this.user, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 100),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(36), bottomRight: Radius.circular(36)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30, right: -30,
            child: Container(
              width: 160, height: 160,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.rider.withOpacity(0.15)),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50), child: Container(color: Colors.transparent)),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.isOnline ? 'YOU ARE ONLINE' : 'YOU ARE OFFLINE',
                        style: TextStyle(color: user.isOnline ? AppColors.success : AppColors.rider.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2)),
                      const SizedBox(height: 4),
                      Text('Hello, ${user.name}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: [
                      Switch.adaptive(
                        value: user.isOnline,
                        onChanged: (v) => ref.read(riderServiceProvider).toggleOnlineStatus(user.uid, v),
                        activeColor: AppColors.success,
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => context.push('/rider/profile'),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.rider, width: 2)),
                          child: CircleAvatar(
                            radius: 18, 
                            backgroundColor: const Color(0xFF1E293B), 
                            backgroundImage: (user.profilePicture != null && user.profilePicture!.isNotEmpty) 
                                ? NetworkImage(user.profilePicture!) 
                                : null,
                            child: (user.profilePicture == null || user.profilePicture!.isEmpty)
                                ? Text(user.name.substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              InkWell(
                onTap: () => context.push('/rider/earnings'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Today's Earnings", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ref.watch(todayRiderHistoryProvider).when(
                          data: (orders) {
                            final todayEarnings = orders.fold(0.0, (sum, order) => sum + order.deliveryFee);
                            return Text('Rs ${todayEarnings.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800));
                          },
                          loading: () => const Text('...', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800)),
                          error: (e, s) => const Text('Rs 0', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800)),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.1))),
                          child: const Text('Bonus Ready', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
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

class _RiderKpiGrid extends StatelessWidget {
  final UserModel user;
  final int activeOrdersCount;
  final int todayOrdersCount;

  const _RiderKpiGrid({required this.user, required this.activeOrdersCount, required this.todayOrdersCount});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _KpiCard(
          title: 'Active Tasks',
          value: activeOrdersCount.toString().padLeft(2, '0'),
          icon: Icons.directions_bike_rounded,
          color: const Color(0xFF6366F1),
          onTap: () => context.push('/rider/active-tasks'),
        ),
        _KpiCard(
          title: 'Deliveries',
          value: todayOrdersCount.toString().padLeft(2, '0'),
          icon: Icons.local_shipping_rounded,
          color: const Color(0xFF10B981),
          onTap: () => context.push('/rider/history'),
        ),
        _KpiCard(
          title: 'Total Balance',
          value: 'Rs ${user.totalEarnings.toStringAsFixed(0)}',
          icon: Icons.account_balance_wallet_rounded,
          color: AppColors.rider,
          onTap: () => context.push('/rider/earnings'),
        ),
        _KpiCard(
          title: 'Performance',
          value: '98%',
          icon: Icons.auto_graph_rounded,
          color: const Color(0xFF10B981),
          onTap: () => context.push('/rider/performance'),
        ),
        _KpiCard(
          title: 'Rider Rating',
          value: user.rating.toStringAsFixed(1),
          icon: Icons.star_rounded,
          color: const Color(0xFFF59E0B),
          onTap: () => context.push('/rider/reviews'),
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
  final VoidCallback onTap;

  const _KpiCard({required this.title, required this.value, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(24), 
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 10))]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(6), 
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), 
              child: Icon(icon, color: color, size: 16)
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value, 
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis, 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title, 
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 9, color: Colors.black.withValues(alpha: 0.5), fontWeight: FontWeight.w700)
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveDeliverySummary extends StatelessWidget {
  final OrderModel order;
  const _ActiveDeliverySummary({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.rider, Color(0xFFE11D48)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.rider.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Active Delivery', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: Text(order.status.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 16),
          Text(order.shopName, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          Text(order.pickupAddress, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.push('/rider/order-details/${order.id}'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.rider, minimumSize: const Size(double.infinity, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('View Active Tasks', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _OfflineOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Color(0xFFE2E8F0))),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text('You are currently offline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          const Text('Go online to receive new delivery requests nearby.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ActionItem(label: 'History', icon: Icons.history_rounded, color: const Color(0xFF6366F1), onTap: () => context.push('/rider/history')),
            _ActionItem(label: 'Earnings', icon: Icons.account_balance_wallet_rounded, color: const Color(0xFF10B981), onTap: () => context.push('/rider/earnings')),
            _ActionItem(label: 'Tasks', icon: Icons.assignment_rounded, color: const Color(0xFFF59E0B), onTap: () => context.push('/rider/active-tasks')),
            _ActionItem(label: 'Support', icon: Icons.support_agent_rounded, color: AppColors.rider, onTap: () => context.push('/rider/support')),
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
    return Expanded(child: InkWell(onTap: onTap, child: Column(children: [Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))]), child: Icon(icon, color: color, size: 26)), const SizedBox(height: 8), Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)), textAlign: TextAlign.center)])));
  }
}

class _AvailableOrdersHeader extends StatelessWidget {
  const _AvailableOrdersHeader();
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Available Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.rider.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: const Text('Live', style: TextStyle(color: AppColors.rider, fontSize: 11, fontWeight: FontWeight.bold)))]);
  }
}

class _OrderRequestTile extends ConsumerWidget {
  final OrderModel order;
  final String riderId;
  const _OrderRequestTile({required this.order, required this.riderId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))]),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.rider.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.shopping_bag_outlined, color: AppColors.rider, size: 24)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    Text('Order #${order.id.substring(0, 8).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), 
                    const SizedBox(height: 4), 
                    Text(order.shopName, style: TextStyle(color: AppColors.rider, fontWeight: FontWeight.bold, fontSize: 13)),
                  ]
                )
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('Rs ${order.deliveryFee.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF10B981))), const Text('Est. Earnings', style: TextStyle(color: Colors.grey, fontSize: 10))]),
            ],
          ),
          const SizedBox(height: 16),
          _LocationInfo(icon: Icons.storefront_rounded, address: order.pickupAddress, label: 'PICKUP'),
          const SizedBox(height: 8),
          _LocationInfo(icon: Icons.location_on_rounded, address: order.deliveryAddress, label: 'DELIVERY'),
          const SizedBox(height: 20),
          Row(
            children: [
              Text('Payment: ', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text(order.paymentMethod, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const Spacer(),
              const Icon(Icons.near_me_rounded, size: 14, color: Colors.blue),
              const SizedBox(width: 4),
              const Text('2.4 km', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => ref.read(riderServiceProvider).rejectOrder(order.id, riderId), 
                style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF64748B), side: const BorderSide(color: Color(0xFFE2E8F0)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), minimumSize: const Size(0, 48)), 
                child: const Text('Decline')
              )
            ), 
            const SizedBox(width: 12), 
            Expanded(
              flex: 2, 
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await ref.read(orderServiceProvider).updateStatus(order.id, OrderStatus.accepted, riderId: riderId);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Order accepted successfully!'), backgroundColor: Colors.green),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to accept order: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
                }, 
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.rider, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), minimumSize: const Size(0, 48), elevation: 0), 
                child: const Text('Accept Delivery', style: TextStyle(fontWeight: FontWeight.bold))
              )
            )
          ]),
        ],
      ),
    );
  }
}

class _LocationInfo extends StatelessWidget {
  final IconData icon;
  final String address;
  final String label;
  const _LocationInfo({required this.icon, required this.address, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1)),
              Text(address, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}

class _RiderBottomNav extends StatelessWidget {
  const _RiderBottomNav();
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32), 
      decoration: BoxDecoration(
        color: Colors.white, 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))]
      ), 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround, 
        children: [
          _BottomNavItem(
            icon: Icons.home_rounded, 
            label: 'Home', 
            isActive: location == '/rider', 
            onTap: () => context.go('/rider')
          ), 
          _BottomNavItem(
            icon: Icons.list_alt_rounded, 
            label: 'History', 
            isActive: location == '/rider/history', 
            onTap: () => context.push('/rider/history')
          ), 
          _BottomNavItem(
            icon: Icons.notifications_none_rounded, 
            label: 'Alerts', 
            isActive: location == '/rider/alerts', 
            onTap: () => context.push('/rider/alerts')
          ), 
          _BottomNavItem(
            icon: Icons.person_outline_rounded, 
            label: 'Profile', 
            isActive: location == '/rider/profile' || location == '/rider/vehicle' || location == '/rider/documents',
            onTap: () => context.push('/rider/profile')
          )
        ]
      )
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _BottomNavItem({required this.icon, required this.label, required this.isActive, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: onTap, child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: isActive ? AppColors.rider : const Color(0xFF94A3B8), size: 26), const SizedBox(height: 4), Text(label, style: TextStyle(color: isActive ? AppColors.rider : const Color(0xFF94A3B8), fontSize: 11, fontWeight: isActive ? FontWeight.bold : FontWeight.w500))]));
  }
}
