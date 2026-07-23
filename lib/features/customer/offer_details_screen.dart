import 'dart:ui';
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
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: AppColors.surface.withOpacity(0.8),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
                  onPressed: () => context.canPop() ? context.pop() : context.go('/customer'),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                offer.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  color: AppColors.surface,
                  child: const Icon(Icons.local_offer_rounded, size: 80, color: Colors.white10),
                ),
              ),
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
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          offer.offerType == 'percentage' 
                              ? '${offer.value.round()}% OFF' 
                              : offer.offerType == 'free_delivery' 
                                  ? 'FREE DELIVERY' 
                                  : 'Rs ${offer.value.round()} OFF',
                          style: const TextStyle(color: AppColors.background, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                        ),
                      ),
                      if (offer.couponCode != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.qr_code_rounded, size: 16, color: AppColors.primary),
                              const SizedBox(width: 10),
                              Text(
                                offer.couponCode!,
                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(offer.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1)),
                  const SizedBox(height: 12),
                  Text(
                    offer.description,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.6, fontWeight: FontWeight.w500),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Divider(color: AppColors.border),
                  ),
                ],
              ),
            ),
          ),

          if (offer.applicableShopIds.isNotEmpty) ...[
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverToBoxAdapter(
                child: Text('PARTICIPATING STORES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 1.5)),
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
                loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(color: AppColors.primary))),
                error: (e, s) => const SliverToBoxAdapter(child: Center(child: Text('Error loading shops'))),
              ),
            ),
          ],

          if (offer.applicableProductIds.isNotEmpty) ...[
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
              sliver: SliverToBoxAdapter(
                child: Text('ELIGIBLE PRODUCTS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 1.5)),
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
                    childAspectRatio: 0.82,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _ProductOfferCard(product: products[index]),
                    childCount: products.length,
                  ),
                ),
                loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(color: AppColors.primary))),
                error: (e, s) => const SliverToBoxAdapter(child: Center(child: Text('Error loading products'))),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListTile(
        onTap: () => context.push('/customer/shop/${shop.id}'),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(shop.imageUrl, width: 48, height: 48, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(width: 48, height: 48, color: AppColors.elevatedSurface, child: const Icon(Icons.storefront, color: AppColors.textHint, size: 20))),
        ),
        title: Text(shop.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white)),
        subtitle: Text(shop.category, style: const TextStyle(color: AppColors.textHint, fontSize: 12, fontWeight: FontWeight.w600)),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primary),
        ),
      ),
    );
  }
}

class _ProductOfferCard extends StatelessWidget {
  final dynamic product; // ProductModel
  const _ProductOfferCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/customer/product', extra: product),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: product.imageUrl.isNotEmpty 
                  ? Image.network(product.imageUrl, fit: BoxFit.cover, width: double.infinity)
                  : Container(color: AppColors.secondaryBackground, child: const Icon(Icons.image, color: Colors.white10)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name, 
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white), 
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Rs ${product.price.toStringAsFixed(0)}', 
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 15)
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
