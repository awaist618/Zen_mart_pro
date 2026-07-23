import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../theme/app_colors.dart';
import '../../models/shop_model.dart';
import '../../models/product_model.dart';
import './widgets/customer_bottom_nav.dart';
import '../../core/localization.dart';

class CustomerHome extends ConsumerWidget {
  const CustomerHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Gradient Glow
          Positioned(
            top: -200,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [colorScheme.primary.withOpacity(isLight ? 0.12 : 0.08), Colors.transparent],
                ),
              ),
            ),
          ),
          
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 160,
                floating: true,
                pinned: true,
                elevation: 0,
                backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.8),
                flexibleSpace: FlexibleSpaceBar(
                  background: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(color: Colors.transparent),
                  ),
                ),
                title: _LocationHeader(ref: ref),
                bottom: const PreferredSize(
                  preferredSize: Size.fromHeight(80),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: _SearchBar(),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      const _PromoBanner(),
                      const SizedBox(height: 40),
                      _SectionHeader(title: 'Quick Categories', showSeeAll: false),
                      const SizedBox(height: 20),
                      const _CategoryGrid(),
                      const SizedBox(height: 40),
                      _SectionHeader(
                        title: 'Premium Stores', 
                        showSeeAll: true,
                        onSeeAll: '/customer/featured-shops',
                      ),
                      const SizedBox(height: 20),
                      const _FeaturedShops(),
                      const SizedBox(height: 40),
                      _SectionHeader(title: 'Trending Now', showSeeAll: true),
                      const SizedBox(height: 20),
                      const _TrendingProducts(),
                      const SizedBox(height: 40),
                      _SectionHeader(title: 'Stores Near You', showSeeAll: true),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              const _NearbyShopsGrid(),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
          
          // Floating Bottom Nav
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: const CustomerBottomNav(currentIndex: 0),
          ),
        ],
      ),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => context.push('/customer/addresses'),
            borderRadius: BorderRadius.circular(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.location_on_rounded, color: colorScheme.primary, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'DELIVERING TO',
                        style: TextStyle(
                          color: colorScheme.primary.withOpacity(0.8),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              defaultAddress?.fullAddress ?? 'Select Location',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colorScheme.onBackground),
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: colorScheme.onSurface.withOpacity(0.4)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _HeaderActionBtn(
          icon: Icons.notifications_none_rounded, 
          onTap: () => context.push('/customer/notifications')
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => context.push('/customer/profile'),
          child: Hero(
            tag: 'profile_avatar',
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.primary.withOpacity(0.3), width: 1.5),
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: colorScheme.surface,
                backgroundImage: (user?.profilePicture != null && user!.profilePicture!.isNotEmpty)
                    ? NetworkImage(user.profilePicture!)
                    : null,
                child: (user?.profilePicture == null || user!.profilePicture!.isEmpty)
                    ? Text(
                        user?.name.substring(0, 1).toUpperCase() ?? '?',
                        style: TextStyle(color: colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderActionBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderActionBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isLight ? colorScheme.outline.withOpacity(0.1) : Colors.white.withOpacity(0.05)),
          boxShadow: isLight ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)] : null,
        ),
        child: Icon(icon, color: colorScheme.onSurface, size: 20),
      ),
    );
  }
}

class _SearchBar extends ConsumerWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return GestureDetector(
      onTap: () => context.push('/customer/search'),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isLight ? Colors.black.withOpacity(0.05) : Colors.black.withOpacity(0.15), 
              blurRadius: 30, 
              offset: const Offset(0, 10)
            ),
          ],
          border: Border.all(color: isLight ? colorScheme.outline.withOpacity(0.1) : Colors.white.withOpacity(0.03)),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: colorScheme.primary, size: 24),
            const SizedBox(width: 14),
            Text(
              'search_hint'.tr(ref),
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.4), fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.tune_rounded, color: colorScheme.primary, size: 18),
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

        return Container(
          width: double.infinity,
          height: 190,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 40, offset: const Offset(0, 20)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(36),
            child: Stack(
              children: [
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
                        colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          offer.offerType == 'percentage' ? '${offer.value.round()}% OFF' : 'VIP DEAL',
                          style: const TextStyle(color: AppColors.background, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        offer.title,
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => context.push('/customer/offer', extra: offer),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(110, 44),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('SHOP NOW'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => _Skeleton(height: 190, radius: 36),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22, 
            fontWeight: FontWeight.w800, 
            color: colorScheme.onBackground, 
            letterSpacing: -0.5
          ),
        ),
        if (showSeeAll)
          TextButton(
            onPressed: onSeeAll != null ? () => context.push(onSeeAll!) : null,
            child: Row(
              children: [
                Text('View All', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w800, fontSize: 13)),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios_rounded, size: 10, color: colorScheme.primary),
              ],
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
          {'name': 'Grocery', 'key': 'Grocery', 'icon': Icons.local_grocery_store_rounded, 'color': const Color(0xFF6366F1)},
          {'name': 'Food', 'key': 'Food', 'icon': Icons.restaurant_rounded, 'color': const Color(0xFFF59E0B)},
          {'name': 'Pharmacy', 'key': 'Pharmacy', 'icon': Icons.medical_services_rounded, 'color': const Color(0xFF10B981)},
          {'name': 'Fashion', 'key': 'Fashion', 'icon': Icons.checkroom_rounded, 'color': const Color(0xFFEC4899)},
        ];

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: categories.map((cat) {
            final color = cat['color'] as Color;
            return InkWell(
              onTap: () => context.push('/customer/category/${cat['key']}'),
              borderRadius: BorderRadius.circular(24),
              child: Column(
                children: [
                  Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: color.withOpacity(0.15), width: 1),
                    ),
                    child: Center(child: Icon(cat['icon'] as IconData, color: color, size: 30)),
                  ),
                  const SizedBox(height: 12),
                  Text(cat['name'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                ],
              ),
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
          height: 260,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: shops.length,
            padding: const EdgeInsets.only(right: 20),
            separatorBuilder: (_, __) => const SizedBox(width: 20),
            itemBuilder: (context, index) => _FeaturedShopCard(shop: shops[index]),
          ),
        );
      },
      loading: () => SizedBox(height: 260, child: ListView(scrollDirection: Axis.horizontal, children: List.generate(2, (_) => Padding(padding: const EdgeInsets.only(right: 20), child: _Skeleton(width: 280, height: 260, radius: 32))))),
      error: (e, s) => const SizedBox.shrink(),
    );
  }
}

class _FeaturedShopCard extends StatelessWidget {
  final ShopModel shop;
  const _FeaturedShopCard({required this.shop});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return InkWell(
      onTap: () => context.push('/customer/shop/${shop.id}'),
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: 290,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: isLight ? Colors.black.withOpacity(0.05) : Colors.black.withOpacity(0.15), 
              blurRadius: 30, 
              offset: const Offset(0, 10)
            )
          ],
          border: isLight ? Border.all(color: colorScheme.outline.withOpacity(0.05)) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  child: shop.imageUrl.isNotEmpty 
                      ? Image.network(shop.imageUrl, height: 155, width: double.infinity, fit: BoxFit.cover)
                      : Container(height: 155, color: colorScheme.secondaryContainer, child: Icon(Icons.storefront, color: colorScheme.onSurface.withOpacity(0.1), size: 50)),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: _GlassBadge(label: '${shop.rating}', icon: Icons.star_rounded, color: AppColors.warning),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shop.name, 
                    style: TextStyle(
                      fontWeight: FontWeight.w800, 
                      fontSize: 17, 
                      color: colorScheme.onSurface, 
                      letterSpacing: -0.2
                    ), 
                    maxLines: 1
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${shop.category} • ${shop.deliveryTime}', 
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.5), 
                      fontSize: 12, 
                      fontWeight: FontWeight.w600
                    )
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

class _TrendingProducts extends ConsumerWidget {
  const _TrendingProducts();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Re-using nearby shop's first store's products as "Trending" for UI purposes
    final shopsAsync = ref.watch(nearbyShopsProvider);

    return shopsAsync.when(
      data: (shops) {
        if (shops.isEmpty) return const SizedBox.shrink();
        final productsAsync = ref.watch(shopProductsByIdProvider(shops.first.id));
        
        return productsAsync.when(
          data: (products) => SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) => _SmallProductCard(product: products[index]),
            ),
          ),
          loading: () => const SizedBox.shrink(),
          error: (e, s) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(),
    );
  }
}

class _SmallProductCard extends StatelessWidget {
  final ProductModel product;
  const _SmallProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return InkWell(
      onTap: () => context.push('/customer/product', extra: product),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface, 
          borderRadius: BorderRadius.circular(20),
          boxShadow: isLight ? [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)] : null,
          border: isLight ? Border.all(color: colorScheme.outline.withOpacity(0.05)) : null,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(product.imageUrl, width: 64, height: 64, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name, 
                    style: TextStyle(
                      fontWeight: FontWeight.w700, 
                      fontSize: 14, 
                      color: colorScheme.onSurface
                    ), 
                    maxLines: 1
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rs ${product.price.round()}', 
                    style: TextStyle(
                      color: colorScheme.primary, 
                      fontWeight: FontWeight.w900, 
                      fontSize: 15
                    )
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

class _NearbyShopsGrid extends ConsumerWidget {
  const _NearbyShopsGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearbyAsync = ref.watch(nearbyShopsProvider);

    return nearbyAsync.when(
      data: (shops) => SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => _ShopCard(shop: shops[index]),
            childCount: shops.length,
          ),
        ),
      ),
      loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(color: AppColors.primary))),
      error: (e, s) => const SliverToBoxAdapter(child: SizedBox.shrink()),
    );
  }
}

class _ShopCard extends StatelessWidget {
  final ShopModel shop;
  const _ShopCard({required this.shop});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return InkWell(
      onTap: () => context.push('/customer/shop/${shop.id}'),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface, 
          borderRadius: BorderRadius.circular(22),
          boxShadow: isLight ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15)] : null,
          border: isLight ? Border.all(color: colorScheme.outline.withOpacity(0.05)) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                child: shop.imageUrl.isNotEmpty 
                    ? Image.network(shop.imageUrl, fit: BoxFit.cover, width: double.infinity)
                    : Container(color: colorScheme.secondaryContainer, child: Icon(Icons.storefront, color: colorScheme.onSurface.withOpacity(0.1))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shop.name, 
                    style: TextStyle(
                      fontWeight: FontWeight.w700, 
                      fontSize: 13, 
                      color: colorScheme.onSurface
                    ), 
                    maxLines: 1
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        shop.hasFreeDelivery ? 'FREE' : 'Rs ${shop.deliveryFee.round()}', 
                        style: TextStyle(
                          color: colorScheme.primary, 
                          fontSize: 10, 
                          fontWeight: FontWeight.w800
                        )
                      ),
                      Icon(Icons.arrow_forward_rounded, size: 12, color: colorScheme.onSurface.withOpacity(0.3)),
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

class _GlassBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _GlassBadge({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  const _Skeleton({this.width, required this.height, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
