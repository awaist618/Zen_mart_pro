import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
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
        title: const Text('Confirm Order', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF0F172A),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Delivery Location', Icons.location_on_rounded),
            const SizedBox(height: 16),
            _buildAddressCard(context, address),
            const SizedBox(height: 32),
            _buildSectionHeader('Payment Method', Icons.payments_rounded),
            const SizedBox(height: 16),
            _buildPaymentOptions(),
            const SizedBox(height: 32),
            _buildSectionHeader('Order Items', Icons.shopping_basket_rounded),
            const SizedBox(height: 16),
            _buildOrderSummary(cart),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomAction(context, cart, address, user),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.accent),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
      ],
    );
  }

  Widget _buildAddressCard(BuildContext context, dynamic address) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 8)),
        ],
        border: Border.all(color: AppColors.accent.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.accent.withOpacity(0.15), AppColors.accent.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.location_on_rounded, color: AppColors.accent, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address?.label ?? 'Delivery Address', 
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))
                ),
                const SizedBox(height: 4),
                Text(
                  address?.fullAddress ?? 'Please add a delivery address to continue', 
                  style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 13, fontWeight: FontWeight.w600, height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push('/customer/addresses'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.chevron_right_rounded, color: Color(0xFF0F172A), size: 20),
              ),
            ),
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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _PaymentTile(
            title: 'Cash on Delivery',
            subtitle: 'Pay when you receive items',
            icon: Icons.money_rounded,
            isSelected: _paymentMethod == 'Cash on Delivery',
            onTap: () => setState(() => _paymentMethod = 'Cash on Delivery'),
          ),
          const Divider(height: 1, indent: 60),
          _PaymentTile(
            title: 'Online Transfer',
            subtitle: 'Scan QR to pay instantly',
            icon: Icons.qr_code_scanner_rounded,
            isSelected: _paymentMethod == 'Online Transfer',
            onTap: () => setState(() => _paymentMethod = 'Online Transfer'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(dynamic cart) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          ...cart.items.values.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                        child: Text('${item.quantity}x', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppColors.accent)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(item.product.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155)))),
                    ],
                  ),
                ),
                Text('Rs ${item.totalPrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              ],
            ),
          )),
          const Divider(height: 32),
          _SummaryRow(label: 'Order Subtotal', value: 'Rs ${cart.totalAmount.toStringAsFixed(0)}'),
          const SizedBox(height: 12),
          _SummaryRow(label: 'Delivery Charge', value: 'Rs 100'),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total to Pay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
              Text('Rs ${(cart.totalAmount + 100).toStringAsFixed(0)}', 
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.accent)),
            ],
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: ElevatedButton(
        onPressed: (_isPlacingOrder || address == null) ? null : () {
          if (_paymentMethod == 'Online Transfer') {
            _showQRScannerDialog(context, cart, address, user);
          } else {
            _placeOrder(context, cart, address, user);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 64),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
          shadowColor: AppColors.accent.withOpacity(0.4),
        ),
        child: _isPlacingOrder 
          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _paymentMethod == 'Online Transfer' ? 'Pay & Confirm Order' : 'Confirm Order', 
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)
                ),
                const SizedBox(width: 12),
                const Icon(Icons.check_circle_rounded, size: 20),
              ],
            ),
      ),
    );
  }

  void _showQRScannerDialog(BuildContext context, dynamic cart, dynamic address, dynamic user) {
    final total = cart.totalAmount + 100;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            const Text('Secure Checkout', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
            const SizedBox(height: 8),
            Text('Scan QR code to pay Rs ${total.toStringAsFixed(0)}', style: TextStyle(color: Colors.black.withOpacity(0.4), fontWeight: FontWeight.w600)),
            const SizedBox(height: 32),
            
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppColors.accent.withOpacity(0.1)),
                boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.05), blurRadius: 40, offset: const Offset(0, 10))],
              ),
              child: Column(
                children: [
                  QrImageView(
                    data: 'PAYMENT_ID_${DateTime.now().millisecondsSinceEpoch}_AMT_$total',
                    version: QrVersions.auto,
                    size: 200.0,
                    foregroundColor: const Color(0xFF0F172A),
                  ),
                  const SizedBox(height: 20),
                  const Text('ZEN MART SECURE PAY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2, color: Colors.grey)),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                'Open your JazzCash, EasyPaisa or Banking App to scan and pay. We will verify your transaction automatically.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.6, fontWeight: FontWeight.w500),
              ),
            ),
            
            const Spacer(),
            
            _VerificationStatus(onComplete: () {
              Navigator.pop(context);
              _placeOrder(context, cart, address, user, isPrepaid: true);
            }),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _placeOrder(BuildContext context, dynamic cart, dynamic address, dynamic user, {bool isPrepaid = false}) async {
    setState(() => _isPlacingOrder = true);
    
    try {
      final firstItem = cart.items.values.first;
      final deliveryOtp = (Random().nextInt(9000) + 1000).toString();

      final orderData = {
        'customerId': user.uid,
        'customerName': user.name,
        'customerPhone': user.phone,
        'vendorId': firstItem.product.vendorId,
        'shopId': firstItem.product.shopId,
        'shopName': firstItem.product.shopName,
        'vendorPhone': '03001234567',
        'status': 'pending',
        'totalAmount': cart.totalAmount + 100,
        'deliveryFee': 100.0,
        'pickupAddress': 'Shop Address, Main Market',
        'deliveryAddress': address.fullAddress,
        'items': cart.items.values.map((item) => {
          'productId': item.product.id,
          'name': item.product.name,
          'price': item.product.price,
          'quantity': item.quantity,
        }).toList(),
        'paymentMethod': _paymentMethod,
        'paymentStatus': isPrepaid ? 'paid' : 'pending',
        'deliveryOtp': deliveryOtp,
        'createdAt': DateTime.now(),
      };

      final orderId = await ref.read(customerServiceProvider).placeOrder(orderData);
      
      ref.read(cartProvider.notifier).clearCart();
      
      if (context.mounted) {
        context.go('/customer/order-success/$orderId');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order placement failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }
}

class _VerificationStatus extends StatefulWidget {
  final VoidCallback onComplete;
  const _VerificationStatus({required this.onComplete});
  @override
  State<_VerificationStatus> createState() => _VerificationStatusState();
}

class _VerificationStatusState extends State<_VerificationStatus> {
  String _status = 'Awaiting payment...';
  double _progress = 0;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _simulateScanning();
  }

  void _simulateScanning() async {
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    setState(() { _status = 'Payment detected. Verifying...'; _progress = 0.4; });
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    setState(() { _status = 'Confirming with gateway...'; _progress = 0.8; });
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() { _isSuccess = true; _status = 'Success! Order placing...'; _progress = 1.0; });
    await Future.delayed(const Duration(seconds: 2));
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isSuccess) const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.accent)),
              if (_isSuccess) const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
              const SizedBox(width: 12),
              Text(_status, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: _isSuccess ? Colors.green : const Color(0xFF1E293B))),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: const Color(0xFFF1F5F9),
              color: _isSuccess ? Colors.green : AppColors.accent,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  const _PaymentTile({required this.title, required this.subtitle, required this.icon, required this.isSelected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accent.withOpacity(0.04) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: isSelected ? Border.all(color: AppColors.accent.withOpacity(0.2)) : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent.withOpacity(0.1) : const Color(0xFFF8FAFC), 
                  borderRadius: BorderRadius.circular(14)
                ),
                child: Icon(icon, color: isSelected ? AppColors.accent : Colors.grey[400], size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title, 
                      style: TextStyle(
                        fontWeight: FontWeight.w900, 
                        fontSize: 15, 
                        color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF334155),
                        letterSpacing: -0.2,
                      )
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle, 
                      style: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 12, fontWeight: FontWeight.w600)
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle, 
                  border: Border.all(color: isSelected ? AppColors.accent : Colors.grey.withOpacity(0.2), width: 2)
                ),
                child: isSelected 
                  ? Container(width: 12, height: 12, decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)) 
                  : const SizedBox(width: 12, height: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 14, fontWeight: FontWeight.w600)), Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1E293B)))]);
  }
}
