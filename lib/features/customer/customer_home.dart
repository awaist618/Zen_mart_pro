import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../theme/app_colors.dart';
import '../../models/shop_model.dart';
import './widgets/customer_bottom_nav.dart';

class CustomerHome extends ConsumerWidget {
  const CustomerHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFFF8FAFC),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(color: const Color(0xFFF8FAFC)),
            ),
            title: _LocationHeader(ref: ref),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: const _SearchBar(),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),
                const _PromoBanner(),
                const SizedBox(height: 28),
                const _SectionHeader(title: 'Top Categories', showSeeAll: false),
                const SizedBox(height: 16),
                const _CategoryGrid(),
                const SizedBox(height: 32),
                const _SectionHeader(
                  title: 'Featured Shops', 
                  showSeeAll: true,
                  onSeeAll: '/customer/featured-shops',
                ),
                const SizedBox(height: 16),
                const _FeaturedShops(),
                const SizedBox(height: 24),
                const _SectionHeader(title: 'Popular Near You', showSeeAll: true),
                const SizedBox(height: 16),
              ]),
            ),
          ),
          const _NearbyShopsGrid(),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
      bottomNavigationBar: const CustomerBottomNav(currentIndex: 0),
    );
  }
}

class _LocationHeader extends StatelessWidget {
  final WidgetRef ref;
  const _LocationHeader({required this.ref});

  @override
  Widget build(BuildContext context) {
    final defaultAddress = ref.watch(defaultAddressProvider);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.location_on_rounded, color: AppColors.accent, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: () => context.push('/customer/addresses'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'DELIVER TO',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.4),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        defaultAddress?.fullAddress ?? 'Select Address',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF64748B)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => context.push('/customer/profile'),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accent.withOpacity(0.3), width: 2),
            ),
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFF1F5F9),
              child: Text('AW', style: TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
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
    return GestureDetector(
      onTap: () => context.push('/customer/search'),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: AppColors.accent),
            const SizedBox(width: 12),
            Text(
              'Search for food, grocery...',
              style: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 14),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.tune_rounded, color: AppColors.accent, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoBanner extends ConsumerWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(activeOffersProvider);

    return offersAsync.when(
      data: (offers) {
        if (offers.isEmpty) return const SizedBox.shrink();
        final offer = offers.first;

        return InkWell(
          onTap: () => context.push('/customer/offer', extra: offer),
          child: Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF334155)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              image: offer.imageUrl.isNotEmpty 
                  ? DecorationImage(image: NetworkImage(offer.imageUrl), fit: BoxFit.cover, opacity: 0.4)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  bottom: -20,
                  child: Icon(Icons.shopping_bag_rounded, size: 150, color: Colors.white.withOpacity(0.05)),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          offer.offerType == 'percentage' 
                              ? '${offer.value.round()}% OFF' 
                              : offer.offerType == 'free_delivery' 
                                  ? 'FREE DELIVERY' 
                                  : 'Rs ${offer.value.round()} OFF',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        offer.title,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        offer.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Container(
        height: 160,
        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(28)),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => const SizedBox.shrink(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool showSeeAll;
  final String? onSeeAll;
  const _SectionHeader({required this.title, required this.showSeeAll, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        if (showSeeAll)
          TextButton(
            onPressed: onSeeAll != null ? () => context.push(onSeeAll!) : null,
            child: Text(
              'See All',
              style: TextStyle(color: AppColors.accent, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid();

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'Grocery', 'icon': Icons.local_grocery_store_rounded, 'color': const Color(0xFF6366F1)},
      {'name': 'Food', 'icon': Icons.restaurant_rounded, 'color': const Color(0xFFF59E0B)},
      {'name': 'Pharmacy', 'icon': Icons.medical_services_rounded, 'color': const Color(0xFF10B981)},
      {'name': 'Fashion', 'icon': Icons.checkroom_rounded, 'color': const Color(0xFFEC4899)},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: categories.map((cat) {
        final name = cat['name'] as String;
        return Expanded(
          child: InkWell(
            onTap: () => context.push('/customer/category/$name'),
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
                  child: Icon(cat['icon'] as IconData, color: cat['color'] as Color, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _FeaturedShops extends ConsumerWidget {
  const _FeaturedShops();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredAsync = ref.watch(featuredShopsProvider);

    return featuredAsync.when(
      data: (shops) {
        if (shops.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: shops.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final shop = shops[index];
              return InkWell(
                onTap: () => context.push('/customer/shop/${shop.id}'),
                child: Container(
                  width: 280,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 110,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                          image: shop.imageUrl.isNotEmpty 
                              ? DecorationImage(image: NetworkImage(shop.imageUrl), fit: BoxFit.cover)
                              : null,
                        ),
                        child: shop.imageUrl.isEmpty 
                            ? const Center(child: Icon(Icons.storefront, size: 40, color: Colors.grey))
                            : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(shop.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Text('${shop.category} • ${shop.deliveryTime}', style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 12)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.greenAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('${shop.rating} ★', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text('Error: $e'),
    );
  }
}

class _NearbyShopsGrid extends ConsumerWidget {
  const _NearbyShopsGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearbyAsync = ref.watch(nearbyShopsProvider);

    return nearbyAsync.when(
      data: (shops) {
        if (shops.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => Material(
                color: Colors.transparent,
                child: _ShopCard(shop: shops[index]),
              ),
              childCount: shops.length,
            ),
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
      error: (e, s) => SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
    );
  }
}

class _ShopCard extends StatelessWidget {
  final ShopModel shop;
  const _ShopCard({required this.shop});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/customer/shop/${shop.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  image: shop.imageUrl.isNotEmpty 
                      ? DecorationImage(image: NetworkImage(shop.imageUrl), fit: BoxFit.cover)
                      : null,
                ),
                child: shop.imageUrl.isEmpty 
                    ? const Center(child: Icon(Icons.storefront, size: 40, color: Colors.grey))
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(shop.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('${shop.category} • Rs ${shop.deliveryFee.round()} del', style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 11)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(shop.deliveryTime, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
