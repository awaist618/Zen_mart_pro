import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../theme/app_colors.dart';

class CustomerHome extends ConsumerWidget {
  const CustomerHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _LocationBar(ref: ref),
            const SizedBox(height: 14),
            const _SearchBar(),
            const SizedBox(height: 16),
            const _PromoBanner(),
            const SizedBox(height: 20),
            Text('Categories', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            const _CategoryRow(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Popular near you', style: Theme.of(context).textTheme.titleMedium),
                const Text('See all', style: TextStyle(color: Color(0xFF0F6E56), fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 10),
            const _ShopGrid(),
          ],
        ),
      ),
      bottomNavigationBar: const _CustomerBottomNav(),
    );
  }
}

class _LocationBar extends StatelessWidget {
  final WidgetRef ref;
  const _LocationBar({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Deliver to', style: Theme.of(context).textTheme.labelSmall),
              Row(
                children: [
                  Text('Malakwal City', style: Theme.of(context).textTheme.titleMedium),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.textSecondary),
                ],
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => ref.read(authServiceProvider).signOut(),
          child: const CircleAvatar(
            radius: 19,
            backgroundColor: AppColors.accent,
            child: Text('AR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text('Search shops, products...', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
        ),
      ],
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F6E56),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF0F6E56).withOpacity(0.25), blurRadius: 14, offset: const Offset(0, 8))],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.07)),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('LIMITED OFFER', style: TextStyle(color: Color(0xFF9FE1CB), fontSize: 11, letterSpacing: 0.5, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              const Text('25% off your first order', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text('Use code WELCOME25 at checkout', style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryData {
  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;
  const _CategoryData(this.icon, this.label, this.bg, this.fg);
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow();

  static const List<_CategoryData> _categories = [
    _CategoryData(Icons.apple_rounded, 'Grocery', Color(0xFFFAEEDA), Color(0xFFBA7517)),
    _CategoryData(Icons.restaurant_rounded, 'Food', Color(0xFFFAECE7), Color(0xFFD85A30)),
    _CategoryData(Icons.checkroom_rounded, 'Fashion', Color(0xFFEEEDFE), Color(0xFF534AB7)),
    _CategoryData(Icons.phone_iphone_rounded, 'Electronics', Color(0xFFE1F5EE), Color(0xFF0F6E56)),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final c = _categories[i];
          return SizedBox(
            width: 64,
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(16)),
                  child: Icon(c.icon, color: c.fg, size: 24),
                ),
                const SizedBox(height: 6),
                Text(c.label, style: Theme.of(context).textTheme.labelSmall, textAlign: TextAlign.center),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ShopData {
  final String name;
  final String subtitle;
  final double rating;
  final IconData icon;
  final Color imageBg;
  final Color iconColor;
  const _ShopData(this.name, this.subtitle, this.rating, this.icon, this.imageBg, this.iconColor);
}

class _ShopGrid extends StatelessWidget {
  const _ShopGrid();

  static const List<_ShopData> _shops = [
    _ShopData('Green Basket Store', 'Grocery · 20–30 min', 4.8, Icons.shopping_basket_rounded, Color(0xFFFFE8CC), Color(0xFFBA7517)),
    _ShopData('Tandoori Corner', 'Fast food · 15–25 min', 4.6, Icons.local_pizza_rounded, Color(0xFFFFD9D9), Color(0xFFA32D2D)),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.82,
      children: _shops.map((s) => _ShopCard(shop: s)).toList(),
    );
  }
}

class _ShopCard extends StatelessWidget {
  final _ShopData shop;
  const _ShopCard({required this.shop});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            width: double.infinity,
            color: shop.imageBg,
            child: Stack(
              children: [
                Center(child: Icon(shop.icon, size: 28, color: shop.iconColor)),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.orange, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          shop.rating.toString(),
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(shop.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(shop.subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerBottomNav extends StatelessWidget {
  const _CustomerBottomNav();

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
            _NavIcon(icon: Icons.explore_rounded, active: false),
            _NavIcon(icon: Icons.shopping_cart_rounded, active: false),
            _NavIcon(icon: Icons.favorite_rounded, active: false),
            _NavIcon(icon: Icons.person_rounded, active: false),
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
    return Icon(icon, color: active ? AppColors.accent : AppColors.textSecondary.withOpacity(0.5), size: 24);
  }
}
