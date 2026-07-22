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
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          product.category.toUpperCase(),
                          style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.orange, size: 20),
                          const SizedBox(width: 4),
                          const Text('4.8', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                          Text(' (1.2k+)', style: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'by ${product.brand}',
                    style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.4), fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rs ${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.accent),
                      ),
                      if (product.discount > 0) ...[
                        const SizedBox(width: 12),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            'Rs ${product.price + product.discount}',
                            style: TextStyle(fontSize: 18, color: Colors.grey[400], decoration: TextDecoration.lineThrough, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                  const SizedBox(height: 12),
                  Text(
                    product.description,
                    style: TextStyle(color: Colors.black.withOpacity(0.6), height: 1.7, fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 32),
                  _buildStockInfo(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(context, ref),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
          color: Colors.white,
          shape: const CircleBorder(),
          elevation: 4,
          shadowColor: Colors.black26,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF0F172A)),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/customer');
              }
            },
          ),
        ),
      ),
      actions: [
        _AppBarAction(icon: Icons.favorite_border_rounded, color: Colors.redAccent, onTap: () {}),
        _AppBarAction(icon: Icons.share_outlined, onTap: () {}),
        const SizedBox(width: 12),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'product_${product.id}',
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              image: product.imageUrl.isNotEmpty 
                ? DecorationImage(image: NetworkImage(product.imageUrl), fit: BoxFit.contain)
                : null,
            ),
            child: product.imageUrl.isEmpty 
              ? const Center(child: Icon(Icons.image, size: 80, color: Colors.grey))
              : null,
          ),
        ),
      ),
    );
  }

  Widget _buildStockInfo() {
    bool isLowStock = product.stock < 10;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isLowStock ? Colors.orange.withOpacity(0.05) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isLowStock ? Colors.orange.withOpacity(0.1) : Colors.transparent),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: isLowStock ? Colors.orange : Colors.blue, shape: BoxShape.circle),
            child: Icon(isLowStock ? Icons.priority_high_rounded : Icons.inventory_2_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLowStock ? 'Low Stock' : 'In Stock',
                  style: TextStyle(color: isLowStock ? Colors.orange[900] : Colors.blue[900], fontWeight: FontWeight.w900, fontSize: 13),
                ),
                Text(
                  isLowStock ? 'Only ${product.stock} items left!' : '${product.stock} units available for delivery',
                  style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: OutlinedButton(
              onPressed: () {
                ref.read(cartProvider.notifier).addItem(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} added to cart'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 64),
                side: BorderSide(color: Colors.grey.withOpacity(0.3), width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Icon(Icons.add_shopping_cart_rounded, color: Color(0xFF1E293B)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 5,
            child: ElevatedButton(
              onPressed: () {
                ref.read(cartProvider.notifier).addItem(product);
                context.push('/customer/cart');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 64),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 8,
                shadowColor: AppColors.accent.withOpacity(0.4),
              ),
              child: const Text('Buy Now', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppBarAction extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;
  const _AppBarAction({required this.icon, this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: CircleAvatar(
        backgroundColor: Colors.white,
        child: IconButton(icon: Icon(icon, size: 20, color: color ?? Colors.black), onPressed: onTap),
      ),
    );
  }
}
