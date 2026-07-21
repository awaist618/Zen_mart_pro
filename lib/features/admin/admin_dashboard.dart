import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../theme/app_colors.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _HeroHeader(ref: ref),
            Transform.translate(
              offset: const Offset(0, -42),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const _KpiGrid(),
                    const SizedBox(height: 16),
                    const _QuickActions(),
                    const SizedBox(height: 16),
                    const _RecentActivity(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF8B7FF0)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.08)),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Good morning',
                            style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13)),
                        const Text('Super Admin',
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  _HeroIconButton(
                    icon: Icons.logout_rounded, 
                    onTap: () => ref.read(authServiceProvider).signOut(),
                  ),
                  const SizedBox(width: 10),
                  const CircleAvatar(
                    radius: 19,
                    backgroundColor: Color(0xFFFFA53E),
                    child: Text('SA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text('Platform revenue today', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
              const Text('Rs 842,600', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Row(
                children: const [
                  Icon(Icons.arrow_outward_rounded, color: Color(0xFFC8FFEE), size: 14),
                  SizedBox(width: 2),
                  Text('12.4% vs yesterday', style: TextStyle(color: Color(0xFFC8FFEE), fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeroIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.16), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _KpiData {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _KpiData(this.icon, this.value, this.label, this.color);
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid();

  static const List<_KpiData> _items = [
    _KpiData(Icons.storefront_rounded, '128', 'Active shops', Color(0xFF00D9A5)),
    _KpiData(Icons.people_alt_rounded, '64', 'Vendors', Color(0xFFFFA53E)),
    _KpiData(Icons.receipt_long_rounded, '3,240', 'Orders today', Color(0xFF54A0FF)),
    _KpiData(Icons.two_wheeler_rounded, '42', 'Riders online', Color(0xFFFF6B6B)),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.4,
      children: _items.map((k) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: k.color,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: k.color.withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 8)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(k.icon, color: Colors.white, size: 22),
              const SizedBox(height: 8),
              Text(k.value, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700)),
              Text(k.label, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11.5)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ActionData {
  final IconData icon;
  final String label;
  final Color color;
  const _ActionData(this.icon, this.label, this.color);
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  static const List<_ActionData> _actions = [
    _ActionData(Icons.add_rounded, 'New vendor', AppColors.primary),
    _ActionData(Icons.storefront_rounded, 'New shop', Color(0xFFFFA53E)),
    _ActionData(Icons.category_rounded, 'Categories', Color(0xFF00D9A5)),
    _ActionData(Icons.report_problem_rounded, 'Complaints', Color(0xFFFF6B6B)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick actions', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 14),
          Row(
            children: _actions.map((a) {
              return Expanded(
                child: InkWell(
                  onTap: () {
                    // TODO: route to respective management screen
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: a.color.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(a.icon, color: a.color, size: 22),
                      ),
                      const SizedBox(height: 6),
                      Text(a.label, style: Theme.of(context).textTheme.labelSmall, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  const _ActivityItem(this.icon, this.color, this.title, this.subtitle);
}

class _RecentActivity extends StatelessWidget {
  const _RecentActivity();

  static const List<_ActivityItem> _items = [
    _ActivityItem(Icons.person_add_alt_rounded, Color(0xFFFFA53E), 'New vendor registration', 'Green Basket Store · 5 min ago'),
    _ActivityItem(Icons.error_outline_rounded, Color(0xFFFF6B6B), 'Complaint filed', 'Order #4821 · 18 min ago'),
    _ActivityItem(Icons.check_circle_outline_rounded, Color(0xFF00D9A5), 'Order delivered', 'Order #4819 · 40 min ago'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent activity', style: Theme.of(context).textTheme.titleMedium),
              const Text('View all', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          for (int i = 0; i < _items.length; i++) ...[
            _ActivityRow(item: _items[i]),
            if (i != _items.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final _ActivityItem item;
  const _ActivityRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: item.color.withOpacity(0.14), borderRadius: BorderRadius.circular(10)),
            child: Icon(item.icon, size: 16, color: item.color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 13.5)),
                Text(item.subtitle, style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminBottomNav extends StatelessWidget {
  const _AdminBottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavIcon(icon: Icons.home_rounded, active: true),
            _NavIcon(icon: Icons.storefront_rounded, active: false),
            _NavIcon(icon: Icons.people_alt_rounded, active: false),
            _NavIcon(icon: Icons.bar_chart_rounded, active: false),
            _NavIcon(icon: Icons.settings_rounded, active: false),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool active;
  const _NavIcon({required this.icon, required this.active});

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: active ? AppColors.primary : AppColors.textSecondary.withOpacity(0.5), size: 24);
  }
}
