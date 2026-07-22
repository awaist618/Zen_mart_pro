import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../theme/app_colors.dart';
import './widgets/customer_bottom_nav.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('My Cart', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          if (cart.itemCount > 0)
            TextButton(
              onPressed: () => ref.read(cartProvider.notifier).clearCart(),
              child: const Text('Clear All', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
      body: cart.itemCount == 0 
          ? _buildEmptyCart(context)
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = cart.items.values.toList()[index];
                      return _CartItemTile(item: item);
                    },
                  ),
                ),
                _buildBillSummary(context, cart),
              ],
            ),
      bottomNavigationBar: cart.itemCount > 0 ? null : const CustomerBottomNav(currentIndex: 2),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('Your cart is empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/customer'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.white),
            child: const Text('Start Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildBillSummary(BuildContext context, dynamic cart) {
    double taxes = cart.totalAmount * 0.05; // 5% tax example
    double deliveryFee = 100.0;
    double total = cart.totalAmount + deliveryFee + taxes;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Column(
        children: [
          _CouponSection(),
          const SizedBox(height: 24),
          _SummaryRow(label: 'Subtotal', value: 'Rs ${cart.totalAmount.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Delivery Fee', value: 'Rs ${deliveryFee.toStringAsFixed(0)}', color: Colors.green),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Taxes (GST 5%)', value: 'Rs ${taxes.toStringAsFixed(0)}'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Rs ${total.toStringAsFixed(0)}', 
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.accent)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/customer/checkout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Proceed to Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CouponSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.confirmation_number_outlined, color: AppColors.accent, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Apply Coupon Code',
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 14),
              ),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent)),
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
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color ?? Colors.black)),
      ],
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  final dynamic item; // CartItem
  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(item.product.imageUrl, width: 70, height: 70, fit: BoxFit.cover),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Rs ${item.product.price}', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Row(
            children: [
              _QtyBtn(icon: Icons.remove, onTap: () => ref.read(cartProvider.notifier).removeItem(item.product.id)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              _QtyBtn(icon: Icons.add, onTap: () => ref.read(cartProvider.notifier).addItem(item.product)),
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
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: AppColors.accent),
      ),
    );
  }
}
