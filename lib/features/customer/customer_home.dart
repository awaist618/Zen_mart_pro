import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../theme/app_colors.dart';
import '../../models/shop_model.dart';
import './widgets/customer_bottom_nav.dart';
import '../../core/localization.dart';

class CustomerHome extends ConsumerWidget {
  const CustomerHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.accent.withOpacity(0.05), Theme.of(context).scaffoldBackgroundColor],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            title: _LocationHeader(ref: ref),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: const _SearchBar(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _PromoBanner(),
                  const SizedBox(height: 32),
                  _SectionHeader(title: 'what_buy'.tr(ref), showSeeAll: false),
                  const SizedBox(height: 20),
                  const _CategoryGrid(),
                  const SizedBox(height: 40),
                  _SectionHeader(
                    title: 'featured_stores'.tr(ref), 
                    showSeeAll: true,
                    onSeeAll: '/customer/featured-shops',
                  ),
                  const SizedBox(height: 20),
                  const _FeaturedShops(),
                  const SizedBox(height: 40),
                  _SectionHeader(title: 'popular_near'.tr(ref), showSeeAll: true),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          const _NearbyShopsGrid(),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
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
    final user = ref.watch(userModelProvider).asData?.value;

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => context.push('/customer/addresses'),
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.location_on_rounded, color: AppColors.accent, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            'deliver_to'.tr(ref),
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.4),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Colors.grey),
                        ],
                      ),
                      Text(
                        defaultAddress?.fullAddress ?? 'Select location...',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => context.push('/customer/profile'),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accent.withOpacity(0.2), width: 1.5),
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFF1F5F9),
              backgroundImage: user?.profilePicture != null ? NetworkImage(user!.profilePicture!) : null,
              child: user?.profilePicture == null
                  ? Text(
                      user?.name.substring(0, 1).toUpperCase() ?? '?',
                      style: const TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends ConsumerWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.push('/customer/search'),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: AppColors.accent, size: 24),
            const SizedBox(width: 14),
            Text(
              'search_hint'.tr(ref),
              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.3), fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Container(
              height: 24,
              width: 1.5,
              color: Colors.grey.withOpacity(0.1),
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
            const Icon(Icons.tune_rounded, color: AppColors.accent, size: 22),
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

        return Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(0.2),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
                // Background Image with Gradient Overlay
                Positioned.fill(
                  child: Image.network(
                    offer.imageUrl.isNotEmpty ? offer.imageUrl : 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?q=80&w=600',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.black.withOpacity(0.2),
                          Colors.transparent,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          offer.offerType == 'percentage' 
                              ? '${offer.value.round()}% OFF' 
                              : 'SPECIAL OFFER',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        offer.title,
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 200,
                        child: Text(
                          offer.description,
                          maxLines: 2,
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, height: 1.3),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.push('/customer/offer', extra: offer),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Shop Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
        height: 180,
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(32)),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
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
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5),
          ),
        ),
        if (showSeeAll)
          Consumer(
            builder: (context, ref, child) => GestureDetector(
              onTap: onSeeAll != null ? () => context.push(onSeeAll!) : null,
              child: Row(
                children: [
                  Text(
                    'view_all'.tr(ref),
                    style: const TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.accent),
                ],
              ),
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
    return Consumer(
      builder: (context, ref, child) {
        final categories = [
          {'name': 'grocery'.tr(ref), 'key': 'Grocery', 'icon': Icons.local_grocery_store_rounded, 'color': const Color(0xFF6366F1)},
          {'name': 'food'.tr(ref), 'key': 'Food', 'icon': Icons.restaurant_rounded, 'color': const Color(0xFFF59E0B)},
          {'name': 'pharmacy'.tr(ref), 'key': 'Pharmacy', 'icon': Icons.medical_services_rounded, 'color': const Color(0xFF10B981)},
          {'name': 'fashion'.tr(ref), 'key': 'Fashion', 'icon': Icons.checkroom_rounded, 'color': const Color(0xFFEC4899)},
        ];

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: categories.map((cat) {
            final name = cat['name'] as String;
            final key = cat['key'] as String;
            final color = cat['color'] as Color;
            return Column(
              children: [
                InkWell(
                  onTap: () => context.push('/customer/category/$key'),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withOpacity(0.12), color.withOpacity(0.04)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: color.withOpacity(0.15), width: 1.5),
                    ),
                    child: Center(
                      child: Icon(cat['icon'] as IconData, color: color, size: 30),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  name,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: -0.2),
                ),
              ],
            );
          }).toList(),
        );
      },
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
          height: 240,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: shops.length,
            padding: const EdgeInsets.only(right: 20),
            separatorBuilder: (_, __) => const SizedBox(width: 20),
            itemBuilder: (context, index) {
              final shop = shops[index];
              return InkWell(
                onTap: () => context.push('/customer/shop/${shop.id}'),
                borderRadius: BorderRadius.circular(32),
                child: Container(
                  width: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 25,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Hero(
                            tag: 'shop_banner_${shop.id}',
                            child: Container(
                              height: 145,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                                image: shop.imageUrl.isNotEmpty 
                                    ? DecorationImage(image: NetworkImage(shop.imageUrl), fit: BoxFit.cover)
                                    : null,
                              ),
                              child: shop.imageUrl.isEmpty 
                                  ? const Center(child: Icon(Icons.storefront, size: 40, color: Colors.grey))
                                  : null,
                            ),
                          ),
                          Positioned(
                            top: 16,
                            left: 16,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star_rounded, color: Colors.orange, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${shop.rating}', 
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A))
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (shop.hasFreeDelivery)
                            Positioned(
                              bottom: 12,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'FREE DELIVERY', 
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)
                                ),
                              ),
                            ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    shop.name, 
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A), letterSpacing: -0.5), 
                                    maxLines: 1, 
                                    overflow: TextOverflow.ellipsis
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${shop.category} • ${shop.deliveryTime}', 
                                    style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 13, fontWeight: FontWeight.w600)
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.accent),
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
      loading: () => Container(
        height: 220,
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(28)),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (e, s) => const SizedBox.shrink(),
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 18,
              crossAxisSpacing: 18,
              childAspectRatio: 0.82,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _ShopCard(shop: shops[index]),
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
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8)),
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      image: shop.imageUrl.isNotEmpty 
                          ? DecorationImage(image: NetworkImage(shop.imageUrl), fit: BoxFit.cover)
                          : null,
                    ),
                    child: shop.imageUrl.isEmpty 
                        ? const Center(child: Icon(Icons.storefront, size: 30, color: Colors.grey))
                        : null,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.orange, size: 12),
                          const SizedBox(width: 2),
                          Text('${shop.rating}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(shop.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF1E293B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.delivery_dining_rounded, size: 14, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(shop.hasFreeDelivery ? 'Free' : 'Rs ${shop.deliveryFee.round()}', style: TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 13, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(shop.deliveryTime, style: TextStyle(fontSize: 10, color: Colors.black.withOpacity(0.4), fontWeight: FontWeight.w600)),
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
