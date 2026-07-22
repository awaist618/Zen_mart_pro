import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../models/shop_model.dart';
import '../../theme/app_colors.dart';

class FeaturedShopsScreen extends ConsumerStatefulWidget {
  const FeaturedShopsScreen({super.key});

  @override
  ConsumerState<FeaturedShopsScreen> createState() => _FeaturedShopsScreenState();
}

class _FeaturedShopsScreenState extends ConsumerState<FeaturedShopsScreen> {
  String _sortBy = 'Rating';

  @override
  Widget build(BuildContext context) {
    final featuredAsync = ref.watch(featuredShopsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Featured Shops', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort_rounded),
            onSelected: (val) => setState(() => _sortBy = val),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Rating', child: Text('Sort by Rating')),
              const PopupMenuItem(value: 'Delivery Time', child: Text('Sort by Delivery Time')),
              const PopupMenuItem(value: 'Popularity', child: Text('Sort by Popularity')),
            ],
          ),
        ],
      ),
      body: featuredAsync.when(
        data: (shops) {
          var sortedShops = List<ShopModel>.from(shops);
          if (_sortBy == 'Rating') {
            sortedShops.sort((a, b) => b.rating.compareTo(a.rating));
          } else if (_sortBy == 'Delivery Time') {
            // Simplified parsing of delivery time string
            sortedShops.sort((a, b) => a.deliveryTime.compareTo(b.deliveryTime));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: sortedShops.length,
            separatorBuilder: (_, __) => const SizedBox(height: 20),
            itemBuilder: (context, index) => _FeaturedShopBigCard(shop: sortedShops[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _FeaturedShopBigCard extends StatelessWidget {
  final ShopModel shop;
  const _FeaturedShopBigCard({required this.shop});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/customer/shop/${shop.id}'),
      borderRadius: BorderRadius.circular(32),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 25, offset: const Offset(0, 12)),
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'shop_banner_${shop.id}',
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                      image: shop.imageUrl.isNotEmpty 
                          ? DecorationImage(image: NetworkImage(shop.imageUrl), fit: BoxFit.cover)
                          : null,
                      color: const Color(0xFFF1F5F9),
                    ),
                    child: shop.imageUrl.isEmpty 
                        ? const Center(child: Icon(Icons.storefront, size: 64, color: Colors.grey))
                        : null,
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.orange, size: 18),
                            const SizedBox(width: 4),
                            Text(shop.rating.toString(), style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (shop.hasFreeDelivery)
                  Positioned(
                    bottom: 12,
                    left: 16,
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
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          shop.name, 
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5)
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          shop.deliveryTime, 
                          style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1E293B), fontSize: 12)
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${shop.category} • ${shop.address}', 
                    style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 14, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const _Tag(label: 'Featured Store', color: Colors.blue),
                      const SizedBox(width: 8),
                      if (shop.isOpen) 
                        const _Tag(label: 'Open Now', color: Color(0xFF10B981))
                      else
                        const _Tag(label: 'Closed', color: Colors.redAccent),
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

class _Tag extends StatelessWidget {
  final String label;
  final bool isVisible;
  final Color? color;
  const _Tag({required this.label, this.isVisible = true, this.color});

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? AppColors.accent).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color ?? AppColors.accent, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
