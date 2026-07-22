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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    image: shop.imageUrl.isNotEmpty 
                        ? DecorationImage(image: NetworkImage(shop.imageUrl), fit: BoxFit.cover)
                        : null,
                    color: Colors.grey[200],
                  ),
                  child: shop.imageUrl.isEmpty 
                      ? const Center(child: Icon(Icons.storefront, size: 64, color: Colors.grey))
                      : null,
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.orange, size: 18),
                        const SizedBox(width: 4),
                        Text(shop.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(shop.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(shop.deliveryTime, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${shop.category} • ${shop.address}', style: TextStyle(color: Colors.black.withOpacity(0.5))),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _Tag(label: 'Free Delivery', isVisible: shop.hasFreeDelivery),
                      if (shop.hasFreeDelivery) const SizedBox(width: 8),
                      _Tag(label: 'Featured', color: Colors.blue),
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
