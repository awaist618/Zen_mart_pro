import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../models/offer_model.dart';
import '../../theme/app_colors.dart';

class OfferDetailsScreen extends ConsumerWidget {
  final OfferModel offer;
  const OfferDetailsScreen({super.key, required this.offer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopsAsync = ref.watch(offerShopsProvider(offer.applicableShopIds));
    final productsAsync = ref.watch(offerProductsProvider(offer.applicableProductIds));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                offer.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  color: const Color(0xFF0F172A),
                  child: const Icon(Icons.local_offer_rounded, size: 80, color: Colors.white24),
                ),
              ),
            ),
            leading: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black),
              ),
              onPressed: () => context.pop(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      if (offer.couponCode != null)
                        GestureDetector(
                          onTap: () {
                            // Copy to clipboard or set in state
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Coupon ${offer.couponCode} applied!')),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.accent, width: 1.5, style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.content_copy_rounded, size: 14, color: AppColors.accent),
                                const SizedBox(width: 8),
                                Text(
                                  offer.couponCode!,
                                  style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(offer.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    offer.description,
                    style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 15, height: 1.5),
                  ),
                  const Divider(height: 48),
                ],
              ),
            ),
          ),

          if (offer.applicableShopIds.isNotEmpty) ...[
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverToBoxAdapter(
                child: Text('Participating Shops', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: shopsAsync.when(
                data: (shops) => SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _SmallShopTile(shop: shops[index]),
                    childCount: shops.length,
                  ),
                ),
                loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
                error: (e, s) => SliverToBoxAdapter(child: Text('Error: $e')),
              ),
            ),
          ],

          if (offer.applicableProductIds.isNotEmpty) ...[
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverToBoxAdapter(
                child: Text('Eligible Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: productsAsync.when(
                data: (products) => SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _ProductOfferCard(product: products[index]),
                    childCount: products.length,
                  ),
                ),
                loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
                error: (e, s) => SliverToBoxAdapter(child: Text('Error: $e')),
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _SmallShopTile extends StatelessWidget {
  final dynamic shop; // ShopModel
  const _SmallShopTile({required this.shop});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => context.push('/customer/shop/${shop.id}'),
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundImage: NetworkImage(shop.imageUrl),
        radius: 24,
      ),
      title: Text(shop.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(shop.category),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
    );
  }
}

class _ProductOfferCard extends StatelessWidget {
  final dynamic product; // ProductModel
  const _ProductOfferCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(product.imageUrl, fit: BoxFit.cover, width: double.infinity),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1),
                Text('Rs ${product.price}', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
