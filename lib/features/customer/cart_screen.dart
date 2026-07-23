import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../core/localization.dart';
import '../../theme/app_colors.dart';
import './widgets/customer_bottom_nav.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.8),
                elevation: 0,
                scrolledUnderElevation: 0,
                title: Text('my_cart'.tr(ref), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: colorScheme.onBackground)),
                flexibleSpace: FlexibleSpaceBar(
                  background: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(color: Colors.transparent),
                  ),
                ),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: colorScheme.onBackground),
                  onPressed: () => context.go('/customer'),
                ),
                actions: [
                  if (cart.itemCount > 0)
                    TextButton(
                      onPressed: () => _showClearCartDialog(context, ref),
                      child: Text('clear'.tr(ref).toUpperCase(), style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5)),
                    ),
                  const SizedBox(width: 10),
                ],
              ),
              if (cart.itemCount == 0)
                SliverFillRemaining(child: _buildEmptyCart(context, ref))
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 150),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = cart.items.values.toList()[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _CartItemTile(item: item),
                        );
                      },
                      childCount: cart.items.length,
                    ),
                  ),
                ),
            ],
          ),
          
          if (cart.itemCount > 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildFloatingBillSummary(context, ref, cart),
            ),

          if (cart.itemCount == 0)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomerBottomNav(currentIndex: 2),
            ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, WidgetRef ref) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isLight ? Colors.white : AppColors.dialog,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text('clear'.tr(ref) + '?', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w800)),
        content: Text('This will remove all premium items from your bag.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('cancel'.tr(ref).toUpperCase(), style: const TextStyle(color: AppColors.textHint))),
          TextButton(
            onPressed: () { ref.read(cartProvider.notifier).clearCart(); Navigator.pop(context); },
            child: Text('clear'.tr(ref).toUpperCase(), style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: colorScheme.surface, 
              shape: BoxShape.circle,
              boxShadow: isLight ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 40)] : null,
            ),
            child: Icon(Icons.shopping_bag_outlined, size: 70, color: colorScheme.primary.withOpacity(0.3)),
          ),
          const SizedBox(height: 32),
          Text('empty_cart'.tr(ref), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: colorScheme.onBackground)),
          const SizedBox(height: 12),
          Text('Discover premium products and add them here.', textAlign: TextAlign.center, style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 14)),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => context.go('/customer'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(180, 56)),
            child: Text('start_shopping'.tr(ref).toUpperCase()),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingBillSummary(BuildContext context, WidgetRef ref, dynamic cart) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final colorScheme = theme.colorScheme;
    double total = cart.totalAmount + 100.0; // Simplification

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
          decoration: BoxDecoration(
            color: isLight ? Colors.white.withOpacity(0.9) : AppColors.bottomNav.withOpacity(0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
            boxShadow: [
              BoxShadow(
                color: isLight ? Colors.black.withOpacity(0.08) : Colors.black.withOpacity(0.4), 
                blurRadius: 40
              )
            ],
            border: Border.all(color: isLight ? colorScheme.outline.withOpacity(0.1) : Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('grand_total'.tr(ref).toUpperCase(), style: TextStyle(color: colorScheme.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    const SizedBox(height: 4),
                    Text('Rs ${total.toStringAsFixed(0)}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: colorScheme.onSurface)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => context.push('/customer/checkout'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(160, 60)),
                child: Row(
                  children: [
                    Text('checkout'.tr(ref).toUpperCase()),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  final dynamic item;
  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: isLight ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20)] : [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
        border: isLight ? Border.all(color: colorScheme.outline.withOpacity(0.05)) : null,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(item.product.imageUrl, width: 85, height: 85, fit: BoxFit.cover),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: colorScheme.onSurface), maxLines: 1),
                const SizedBox(height: 4),
                Text('Rs ${item.product.price.round()}', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 12),
                _QuantitySelector(
                  quantity: item.quantity,
                  onAdd: () => ref.read(cartProvider.notifier).addItem(item.product),
                  onRemove: () => ref.read(cartProvider.notifier).removeItem(item.product.id),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => ref.read(cartProvider.notifier).removeItem(item.product.id),
            icon: Icon(Icons.close_rounded, color: colorScheme.onSurface.withOpacity(0.3), size: 20),
          ),
        ],
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  const _QuantitySelector({required this.quantity, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightSecondaryBackground : AppColors.background, 
        borderRadius: BorderRadius.circular(12)
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CircleAction(icon: Icons.remove_rounded, onTap: onRemove),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text('$quantity', style: TextStyle(fontWeight: FontWeight.w800, color: colorScheme.onSurface, fontSize: 13)),
          ),
          _CircleAction(icon: Icons.add_rounded, onTap: onAdd),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, color: colorScheme.primary, size: 18),
      ),
    );
  }
}
