import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/providers.dart';
import '../../theme/app_colors.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _HeroHeader(ref: ref),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: const _KpiGrid(),
                ),
                const SizedBox(height: 8),
                const _QuickActions(),
                const SizedBox(height: 24),
                const _RecentActivity(),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const _AdminBottomNav(),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final WidgetRef ref;
  const _HeroHeader({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 100),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Column(
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
                      'SUPER ADMIN',
                      style: TextStyle(
                        color: AppColors.accent.withOpacity(0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Zen Mart Control',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
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
                    onTap: () => context.push('/admin/notifications'),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => context.push('/admin/profile'),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.accent, width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFF1E293B),
                        child: Text('AD', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          InkWell(
            onTap: () => context.push('/admin/analytics'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Revenue (Monthly)',
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Consumer(
                        builder: (context, ref, child) {
                          final revenueAsync = ref.watch(monthlyRevenueProvider);
                          return revenueAsync.when(
                            data: (revenue) => Text(
                              'Rs ${NumberFormat.compact().format(revenue)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            loading: () => const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            ),
                            error: (e, s) => const Text(
                              'Rs 0',
                              style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.arrow_upward_rounded, color: Colors.greenAccent, size: 14),
                          SizedBox(width: 4),
                          Text(
                            '+18%',
                            style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
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

class _KpiGrid extends ConsumerWidget {
  const _KpiGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopsCount = ref.watch(totalShopsCountProvider).asData?.value ?? 0;
    final ridersCount = ref.watch(totalRidersCountProvider).asData?.value ?? 0;
    final customersCount = ref.watch(totalCustomersCountProvider).asData?.value ?? 0;
    final pendingCount = ref.watch(pendingOrdersCountProvider).asData?.value ?? 0;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _KpiCard(
          title: 'Total Shops',
          value: shopsCount.toString(),
          icon: Icons.storefront_rounded,
          color: const Color(0xFF6366F1),
          trend: 'Active on Platform',
          onTap: () => context.push('/admin/all-shops'),
        ),
        _KpiCard(
          title: 'Active Riders',
          value: ridersCount.toString(),
          icon: Icons.two_wheeler_rounded,
          color: const Color(0xFFF59E0B),
          trend: 'Verified Fleet',
          onTap: () => context.push('/admin/riders'),
        ),
        _KpiCard(
          title: 'Pending Orders',
          value: pendingCount.toString(),
          icon: Icons.pending_actions_rounded,
          color: const Color(0xFFEF4444),
          trend: 'Needs Action',
          onTap: () => context.push('/admin/pending-orders'),
        ),
        _KpiCard(
          title: 'Total Customers',
          value: customersCount.toString(),
          icon: Icons.people_alt_rounded,
          color: const Color(0xFF10B981),
          trend: 'Growth Stats',
          onTap: () => context.push('/admin/customers'),
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
  final String trend;
  final VoidCallback? onTap;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
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
            Row(
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
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
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
                    fontWeight: FontWeight.w500,
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

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Manage Platform',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Expanded(child: _ActionItem(label: 'Vendors', icon: Icons.person_add_rounded, color: Color(0xFF6366F1), route: '/admin/users?tab=0')),
            Expanded(child: _ActionItem(label: 'Riders', icon: Icons.directions_bike_rounded, color: AppColors.rider, route: '/admin/users?tab=2')),
            Expanded(child: _ActionItem(label: 'Approvals', icon: Icons.verified_user_rounded, color: Color(0xFF10B981), route: '/admin/approvals')),
            Expanded(child: _ActionItem(label: 'Payouts', icon: Icons.payments_rounded, color: Color(0xFFF59E0B), route: '/admin/payouts')),
            Expanded(child: _ActionItem(label: 'System', icon: Icons.settings_suggest_rounded, color: Color(0xFF64748B), route: '/admin/system')),
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
  final String? route;

  const _ActionItem({required this.label, required this.icon, required this.color, this.route});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (route != null) {
          GoRouter.of(context).push(route!);
        }
      },
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
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  const _RecentActivity();

  @override
  Widget build(BuildContext context) {
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
                'Recent Events',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => context.push('/admin/activity-log'),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const _ActivityTile(
            title: 'New Vendor Registration',
            subtitle: 'Al-Madina Grocery requested approval',
            time: '2m ago',
            icon: Icons.store_mall_directory_rounded,
            color: Color(0xFF6366F1),
          ),
          const Divider(height: 24),
          const _ActivityTile(
            title: 'Withdrawal Request',
            subtitle: 'Rider #124 requested Rs 5,000',
            time: '15m ago',
            icon: Icons.account_balance_wallet_rounded,
            color: Color(0xFFF59E0B),
          ),
          const Divider(height: 24),
          const _ActivityTile(
            title: 'System Alert',
            subtitle: 'High traffic detected in Malakwal region',
            time: '1h ago',
            icon: Icons.bolt_rounded,
            color: Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;

  const _ActivityTile({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (title.contains('Vendor')) {
          context.push('/admin/approvals');
        } else if (title.contains('Withdrawal')) {
          context.push('/admin/payouts');
        } else {
          context.push('/admin/notifications');
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
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
                const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminBottomNav extends StatelessWidget {
  const _AdminBottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomNavItem(icon: Icons.dashboard_rounded, label: 'Home', isActive: true, onTap: () {}),
          _BottomNavItem(icon: Icons.storefront_rounded, label: 'Shops', isActive: false, onTap: () => context.push('/admin/shops')),
          _BottomNavItem(icon: Icons.people_rounded, label: 'Users', isActive: false, onTap: () => context.push('/admin/users')),
          _BottomNavItem(icon: Icons.bar_chart_rounded, label: 'Stats', isActive: false, onTap: () => context.push('/admin/analytics')),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.primary : const Color(0xFF94A3B8),
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.primary : const Color(0xFF94A3B8),
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
