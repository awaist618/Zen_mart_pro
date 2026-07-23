import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../models/product_model.dart';
import '../../theme/app_colors.dart';

class ProductDetailsScreen extends ConsumerWidget {
  final ProductModel product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildModernAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 150),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _Badge(label: product.category, color: colorScheme.primary),
                          _RatingBadge(rating: '4.8', count: '1.2k'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        product.name,
                        style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: colorScheme.onBackground, letterSpacing: -1),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'by ${product.brand}',
                        style: TextStyle(fontSize: 16, color: colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 32),
                      _PriceSection(price: product.price, discount: product.discount),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Divider(color: colorScheme.outline.withOpacity(0.1)),
                      ),
                      Text('The Detail', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: colorScheme.onBackground)),
                      const SizedBox(height: 12),
                      Text(
                        product.description,
                        style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7), height: 1.7, fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 40),
                      _StockCard(stock: product.stock),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildFloatingAction(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildModernAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return SliverAppBar(
      expandedHeight: 420,
      pinned: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: isLight ? Colors.white.withOpacity(0.8) : AppColors.surface.withOpacity(0.8),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: colorScheme.onSurface),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      actions: [
        _CircleActionBtn(icon: Icons.favorite_border_rounded, onTap: () {}),
        const SizedBox(width: 12),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'product_${product.id}',
          child: Container(
            color: isLight ? AppColors.lightSecondaryBackground : AppColors.secondaryBackground,
            child: product.imageUrl.isNotEmpty 
                ? Image.network(product.imageUrl, fit: BoxFit.contain)
                : Center(child: Icon(Icons.image, size: 80, color: colorScheme.onSurface.withOpacity(0.05))),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingAction(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final colorScheme = theme.colorScheme;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          decoration: BoxDecoration(
            color: isLight ? Colors.white.withOpacity(0.9) : AppColors.bottomNav.withOpacity(0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
            boxShadow: [
              BoxShadow(
                color: isLight ? Colors.black.withOpacity(0.08) : Colors.black.withOpacity(0.3), 
                blurRadius: 40
              )
            ],
            border: Border.all(color: isLight ? colorScheme.outline.withOpacity(0.1) : Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              _ActionSquareBtn(
                icon: Icons.share_rounded, 
                onTap: () {},
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(cartProvider.notifier).addItem(product);
                    context.push('/customer/cart');
                  },
                  child: const Text('ADD TO BAG'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Text(label.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5)));
}

class _RatingBadge extends StatelessWidget {
  final String rating;
  final String count;
  const _RatingBadge({required this.rating, required this.count});
  @override
  Widget build(BuildContext context) => Row(children: [const Icon(Icons.star_rounded, color: AppColors.warning, size: 20), const SizedBox(width: 6), Text(rating, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)), const SizedBox(width: 4), Text('($count)', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3), fontSize: 13, fontWeight: FontWeight.w600))]);
}

class _PriceSection extends StatelessWidget {
  final double price;
  final double discount;
  const _PriceSection({required this.price, required this.discount});
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end, 
      children: [
        Text('Rs ${price.toStringAsFixed(0)}', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: colorScheme.primary, letterSpacing: -1)), 
        if (discount > 0) ...[
          const SizedBox(width: 14), 
          Padding(
            padding: const EdgeInsets.only(bottom: 6), 
            child: Text('Rs ${(price + discount).round()}', style: TextStyle(fontSize: 18, color: colorScheme.onSurface.withOpacity(0.3), decoration: TextDecoration.lineThrough, fontWeight: FontWeight.w600))
          )
        ]
      ]
    );
  }
}

class _StockCard extends StatelessWidget {
  final int stock;
  const _StockCard({required this.stock});
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    bool isLow = stock < 10;
    return Container(
      padding: const EdgeInsets.all(24), 
      decoration: BoxDecoration(
        color: colorScheme.surface, 
        borderRadius: BorderRadius.circular(28),
        boxShadow: isLight ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20)] : null,
        border: isLight ? Border.all(color: colorScheme.outline.withOpacity(0.05)) : null,
      ), 
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12), 
            decoration: BoxDecoration(color: (isLow ? AppColors.warning : AppColors.info).withOpacity(0.1), shape: BoxShape.circle), 
            child: Icon(isLow ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded, color: isLow ? AppColors.warning : AppColors.info, size: 24)
          ), 
          const SizedBox(width: 16), 
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Text(isLow ? 'LIMITED AVAILABILITY' : 'FULLY STOCKED', style: TextStyle(color: isLow ? AppColors.warning : AppColors.info, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5)), 
                const SizedBox(height: 4), 
                Text(isLow ? 'Only $stock items left in stock.' : 'Ready for immediate premium delivery.', style: TextStyle(color: colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.w600))
              ]
            )
          )
        ]
      )
    );
  }
}

class _CircleActionBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleActionBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 10), 
      child: CircleAvatar(
        backgroundColor: isLight ? Colors.white.withOpacity(0.8) : AppColors.surface.withOpacity(0.8), 
        child: IconButton(icon: Icon(icon, size: 20, color: colorScheme.onSurface), onPressed: onTap)
      )
    );
  }
}

class _ActionSquareBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ActionSquareBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return InkWell(
      onTap: onTap, 
      borderRadius: BorderRadius.circular(18), 
      child: Container(
        height: 60, 
        width: 60, 
        decoration: BoxDecoration(
          color: colorScheme.surface, 
          borderRadius: BorderRadius.circular(18), 
          border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
          boxShadow: isLight ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)] : null,
        ), 
        child: Icon(icon, color: colorScheme.onSurface, size: 24)
      )
    );
  }
}
