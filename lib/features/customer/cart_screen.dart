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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('my_cart'.tr(ref), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        actions: [
          if (cart.itemCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: () => _showClearCartDialog(context, ref),
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                label: Text('clear'.tr(ref), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w800, fontSize: 13)),
              ),
            ),
        ],
      ),
      body: cart.itemCount == 0 
          ? _buildEmptyCart(context, ref)
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = cart.items.values.toList()[index];
                      return _CartItemTile(item: item);
                    },
                  ),
                ),
                _buildBillSummary(context, ref, cart),
              ],
            ),
      bottomNavigationBar: cart.itemCount > 0 ? null : const CustomerBottomNav(currentIndex: 2),
    );
  }

  void _showClearCartDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart?'),
        content: const Text('This will remove all items from your cart.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('cancel'.tr(ref))),
          TextButton(
            onPressed: () {
              ref.read(cartProvider.notifier).clearCart();
              Navigator.pop(context);
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.shopping_basket_outlined, size: 80, color: AppColors.accent.withOpacity(0.5)),
            ),
            const SizedBox(height: 24),
            Text('empty_cart'.tr(ref), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(
              'Looks like you haven\'t added anything to your cart yet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.4), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/customer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text('start_shopping'.tr(ref), style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillSummary(BuildContext context, WidgetRef ref, dynamic cart) {
    double taxes = cart.totalAmount * 0.05; 
    double deliveryFee = 100.0;
    double total = cart.totalAmount + deliveryFee + taxes;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 25, offset: const Offset(0, -10))],
      ),
      child: Column(
        children: [
          const _CouponSection(),
          const SizedBox(height: 28),
          _SummaryRow(label: 'item_total'.tr(ref), value: 'Rs ${cart.totalAmount.toStringAsFixed(0)}'),
          const SizedBox(height: 12),
          _SummaryRow(label: 'delivery_fee'.tr(ref), value: 'Rs ${deliveryFee.toStringAsFixed(0)}', color: Colors.green),
          const SizedBox(height: 12),
          _SummaryRow(label: 'taxes'.tr(ref), value: 'Rs ${taxes.toStringAsFixed(0)}'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('grand_total'.tr(ref), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Theme.of(context).textTheme.displayLarge?.color)),
              Text('Rs ${total.toStringAsFixed(0)}', 
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.accent)),
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/customer/checkout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 8,
                shadowColor: AppColors.accent.withOpacity(0.4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('checkout'.tr(ref), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CouponSection extends StatelessWidget {
  const _CouponSection();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.confirmation_number_rounded, color: AppColors.accent.withOpacity(0.7), size: 22),
          const SizedBox(width: 14),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Have a promo code?',
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                fillColor: Colors.transparent,
              ),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.accent, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _SummaryRow({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5), fontSize: 14, fontWeight: FontWeight.w600)),
        Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: color ?? Theme.of(context).textTheme.bodyLarge?.color)),
      ],
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  final dynamic item; 
  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 8)),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Hero(
            tag: 'product_${item.product.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                item.product.imageUrl, 
                width: 90, 
                height: 90, 
                fit: BoxFit.cover, 
                errorBuilder: (c,e,s) => Container(width: 90, height: 90, color: Theme.of(context).scaffoldBackgroundColor, child: const Icon(Icons.image, color: Colors.grey))
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name, 
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.2),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Rs ${item.product.price.toStringAsFixed(0)}', 
                  style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900, fontSize: 17)
                ),
                const SizedBox(height: 12),
                Container(
                  width: 110,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _QtyBtn(icon: Icons.remove_rounded, onTap: () => ref.read(cartProvider.notifier).removeItem(item.product.id)),
                      Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                      _QtyBtn(icon: Icons.add_rounded, onTap: () => ref.read(cartProvider.notifier).addItem(item.product)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => ref.read(cartProvider.notifier).removeItem(item.product.id),
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
              ),
              const SizedBox(height: 12),
              Text(
                'Rs ${(item.product.price * item.quantity).toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 18, color: AppColors.accent),
      ),
    );
  }
}
