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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 100),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
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
                        color: colorScheme.primary.withValues(alpha: 0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Zen Mart Control',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
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
                        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3), width: 2),
                      ),
                      child: Consumer(
                        builder: (context, ref, child) {
                          final user = ref.watch(userModelProvider).asData?.value;
                          return CircleAvatar(
                            radius: 18,
                            backgroundColor: colorScheme.surface,
                            backgroundImage: (user?.profilePicture != null && user!.profilePicture!.isNotEmpty)
                                ? NetworkImage(user.profilePicture!)
                                : null,
                            child: (user?.profilePicture == null || user!.profilePicture!.isEmpty)
                                ? Text(
                                    user?.name.substring(0, 1).toUpperCase() ?? 'A',
                                    style: TextStyle(color: colorScheme.onSurface, fontSize: 12, fontWeight: FontWeight.bold),
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
          const SizedBox(height: 36),
          InkWell(
            onTap: () => context.push('/admin/analytics'),
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Revenue (Monthly)',
                  style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 14, fontWeight: FontWeight.w600),
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
                              'Rs ${NumberFormat('#,###').format(revenue)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                              ),
                            ),
                            loading: () => const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            ),
                            error: (e, s) => Text(
                              'Rs 0',
                              style: TextStyle(color: colorScheme.onSurface, fontSize: 38, fontWeight: FontWeight.w900),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.trending_up_rounded, color: Color(0xFF10B981), size: 14),
                          SizedBox(width: 6),
                          Text(
                            '+18%',
                            style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w800),
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
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, color: colorScheme.onSurface, size: 22),
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
    final payoutCount = ref.watch(pendingPayoutsCountProvider).asData?.value ?? 0;
    final pendingCount = ref.watch(pendingOrdersCountProvider).asData?.value ?? 0;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _KpiCard(
          title: 'Payout Requests',
          value: payoutCount.toString().padLeft(2, '0'),
          icon: Icons.payments_rounded,
          color: const Color(0xFFF59E0B),
          onTap: () => context.push('/admin/payouts'),
        ),
        _KpiCard(
          title: 'Active Riders',
          value: ridersCount.toString(),
          icon: Icons.two_wheeler_rounded,
          color: const Color(0xFF38BDF8),
          onTap: () => context.push('/admin/riders'),
        ),
        _KpiCard(
          title: 'Pending Orders',
          value: pendingCount.toString(),
          icon: Icons.pending_actions_rounded,
          color: const Color(0xFFEF4444),
          onTap: () => context.push('/admin/pending-orders'),
        ),
        _KpiCard(
          title: 'Total Shops',
          value: shopsCount.toString(),
          icon: Icons.storefront_rounded,
          color: const Color(0xFF8B5CF6),
          onTap: () => context.push('/admin/all-shops'),
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
  final VoidCallback? onTap;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                Icon(Icons.chevron_right_rounded, color: colorScheme.onSurface.withValues(alpha: 0.2), size: 14),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
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
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manage Platform',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: const [
              _ActionItem(label: 'Orders', icon: Icons.receipt_long_rounded, color: Colors.deepPurple, route: '/admin/orders'),
              SizedBox(width: 12),
              _ActionItem(label: 'Vendors', icon: Icons.person_add_rounded, color: Color(0xFF6366F1), route: '/admin/users?tab=0'),
              SizedBox(width: 12),
              _ActionItem(label: 'Riders', icon: Icons.directions_bike_rounded, color: const Color(0xFFD6B08A), route: '/admin/users?tab=2'),
              SizedBox(width: 12),
              _ActionItem(label: 'Support', icon: Icons.support_agent_rounded, color: Colors.blue, route: '/admin/support'),
              SizedBox(width: 12),
              _ActionItem(label: 'Payouts', icon: Icons.payments_rounded, color: Color(0xFFF59E0B), route: '/admin/payouts'),
              SizedBox(width: 12),
              _ActionItem(label: 'System', icon: Icons.settings_suggest_rounded, color: Color(0xFF64748B), route: '/admin/system'),
            ],
          ),
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
    final theme = Theme.of(context);
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
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }
}

class _RecentActivity extends ConsumerWidget {
  const _RecentActivity();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activityAsync = ref.watch(activityLogsProvider(null));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Events',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
              ),
              TextButton(
                onPressed: () => context.push('/admin/activity-log'),
                child: Text('View All', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          activityAsync.when(
            data: (logs) {
              if (logs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('No recent activity', style: TextStyle(color: Colors.grey))),
                );
              }
              return Column(
                children: logs.take(5).map((log) => Column(
                  children: [
                    _ActivityTile(
                      title: log.title,
                      subtitle: log.subtitle,
                      time: _formatTime(log.timestamp),
                      icon: log.icon,
                      color: log.color,
                    ),
                    if (logs.indexOf(log) != logs.take(5).length - 1)
                      const Divider(height: 24),
                  ],
                )).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
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
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        if (title.contains('Vendor')) {
          context.push('/admin/approvals');
        } else if (title.contains('Withdrawal')) {
          context.push('/admin/payouts');
        } else if (title.contains('Support')) {
          context.push('/admin/support');
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
                color: color.withValues(alpha: 0.1),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.3), fontSize: 11),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 10, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1))),
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
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.3),
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.3),
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
