import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../models/order_model.dart';
import '../../theme/app_colors.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _paymentMethod = 'Cash on Delivery';
  bool _isPlacingOrder = false;

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final address = ref.watch(defaultAddressProvider);
    final user = ref.watch(userModelProvider).asData?.value;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Delivery Address'),
            const SizedBox(height: 12),
            _buildAddressCard(context, address),
            const SizedBox(height: 32),
            _buildSectionHeader('Payment Method'),
            const SizedBox(height: 12),
            _buildPaymentOptions(),
            const SizedBox(height: 32),
            _buildSectionHeader('Order Summary'),
            const SizedBox(height: 12),
            _buildOrderSummary(cart),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomAction(context, cart, address, user),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildAddressCard(BuildContext context, dynamic address) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_rounded, color: AppColors.accent),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(address?.label ?? 'No address selected', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(address?.fullAddress ?? 'Please add a delivery address', 
                    style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 13)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push('/customer/addresses'),
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptions() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        children: [
          _PaymentTile(
            title: 'Cash on Delivery',
            icon: Icons.money_rounded,
            isSelected: _paymentMethod == 'Cash on Delivery',
            onTap: () => setState(() => _paymentMethod = 'Cash on Delivery'),
          ),
          _PaymentTile(
            title: 'Credit / Debit Card',
            icon: Icons.credit_card_rounded,
            isSelected: _paymentMethod == 'Card',
            onTap: () => setState(() => _paymentMethod = 'Card'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(dynamic cart) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        children: [
          ...cart.items.values.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${item.product.name} x${item.quantity}', style: const TextStyle(fontSize: 13)),
                Text('Rs ${item.totalPrice.toStringAsFixed(0)}'),
              ],
            ),
          )),
          const Divider(height: 24),
          _SummaryRow(label: 'Subtotal', value: 'Rs ${cart.totalAmount.toStringAsFixed(0)}'),
          const _SummaryRow(label: 'Delivery Fee', value: 'Rs 100'),
          const Divider(height: 24),
          _SummaryRow(
            label: 'Total', 
            value: 'Rs ${(cart.totalAmount + 100).toStringAsFixed(0)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context, dynamic cart, dynamic address, dynamic user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: ElevatedButton(
        onPressed: (_isPlacingOrder || address == null) ? null : () => _placeOrder(context, cart, address, user),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: _isPlacingOrder 
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text('Place Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Future<void> _placeOrder(BuildContext context, dynamic cart, dynamic address, dynamic user) async {
    setState(() => _isPlacingOrder = true);
    
    try {
      // Assuming all items from same shop for MVP, or handle multi-shop later
      final firstItem = cart.items.values.first;
      
      final orderData = {
        'customerId': user.uid,
        'customerName': user.name,
        'customerPhone': user.phone,
        'vendorId': firstItem.product.vendorId,
        'shopId': firstItem.product.shopId,
        'shopName': 'Shop Name', // Should ideally fetch from shop model
        'vendorPhone': 'Vendor Phone',
        'status': 'pending',
        'totalAmount': cart.totalAmount + 100,
        'deliveryFee': 100.0,
        'pickupAddress': 'Shop Address',
        'deliveryAddress': address.fullAddress,
        'items': cart.items.values.map((item) => {
          'productId': item.product.id,
          'name': item.product.name,
          'price': item.product.price,
          'quantity': item.quantity,
        }).toList(),
        'paymentMethod': _paymentMethod,
        'createdAt': DateTime.now(),
      };

      final orderId = await ref.read(customerServiceProvider).placeOrder(orderData);
      
      ref.read(cartProvider.notifier).clearCart();
      
      if (context.mounted) {
        context.go('/customer/order-success/$orderId');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }
}

class _PaymentTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentTile({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isSelected ? AppColors.accent : Colors.grey),
      title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: Radio<bool>(
        value: true,
        groupValue: isSelected,
        activeColor: AppColors.accent,
        onChanged: (_) => onTap(),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({required this.label, required this.value, this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isTotal ? Colors.black : Colors.grey, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 16 : 13)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isTotal ? 18 : 13, color: isTotal ? AppColors.accent : Colors.black)),
      ],
    );
  }
}
