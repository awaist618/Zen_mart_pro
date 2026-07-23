import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Confirm Order', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: colorScheme.onBackground)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: colorScheme.onBackground),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Delivery Location', Icons.location_on_rounded, colorScheme),
            const SizedBox(height: 16),
            _buildAddressCard(context, address, colorScheme, isLight),
            const SizedBox(height: 32),
            _buildSectionHeader('Payment Method', Icons.payments_rounded, colorScheme),
            const SizedBox(height: 16),
            _buildPaymentOptions(colorScheme, isLight),
            const SizedBox(height: 32),
            _buildSectionHeader('Order Summary', Icons.shopping_bag_rounded, colorScheme),
            const SizedBox(height: 16),
            _buildOrderSummary(cart, colorScheme, isLight),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomAction(context, cart, address, user, colorScheme, isLight),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(title.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: colorScheme.primary, letterSpacing: 1.5)),
      ],
    );
  }

  Widget _buildAddressCard(BuildContext context, dynamic address, ColorScheme colorScheme, bool isLight) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: isLight ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)] : null,
        border: isLight ? Border.all(color: colorScheme.outline.withOpacity(0.1)) : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.location_on_rounded, color: colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address?.label ?? 'Delivery Address', 
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: colorScheme.onSurface)
                ),
                const SizedBox(height: 4),
                Text(
                  address?.fullAddress ?? 'Please add a delivery address to continue', 
                  style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 13, fontWeight: FontWeight.w500, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => context.push('/customer/addresses'),
            icon: Icon(Icons.edit_location_alt_rounded, color: colorScheme.primary, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: isLight ? AppColors.lightSecondaryBackground : AppColors.background, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptions(ColorScheme colorScheme, bool isLight) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: isLight ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)] : null,
        border: isLight ? Border.all(color: colorScheme.outline.withOpacity(0.1)) : null,
      ),
      child: Column(
        children: [
          _PaymentTile(
            title: 'Cash on Delivery',
            subtitle: 'Pay at your doorstep',
            icon: Icons.payments_rounded,
            isSelected: _paymentMethod == 'Cash on Delivery',
            onTap: () => setState(() => _paymentMethod = 'Cash on Delivery'),
            colorScheme: colorScheme,
            isLight: isLight,
          ),
          Divider(color: isLight ? colorScheme.outline.withOpacity(0.1) : AppColors.border, indent: 64, endIndent: 16),
          _PaymentTile(
            title: 'Online Transfer',
            subtitle: 'Instant secure payment',
            icon: Icons.qr_code_scanner_rounded,
            isSelected: _paymentMethod == 'Online Transfer',
            onTap: () => setState(() => _paymentMethod = 'Online Transfer'),
            colorScheme: colorScheme,
            isLight: isLight,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(dynamic cart, ColorScheme colorScheme, bool isLight) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: isLight ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)] : null,
        border: isLight ? Border.all(color: colorScheme.outline.withOpacity(0.1)) : null,
      ),
      child: Column(
        children: [
          ...cart.items.values.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isLight ? AppColors.lightSecondaryBackground : AppColors.background, 
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: Text('${item.quantity}x', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: colorScheme.primary)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(item.product.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.onSurface))),
                    ],
                  ),
                ),
                Text('Rs ${item.totalPrice.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: colorScheme.onSurface)),
              ],
            ),
          )),
          Divider(color: isLight ? colorScheme.outline.withOpacity(0.1) : AppColors.border, height: 32),
          _SummaryLine(label: 'Subtotal', value: 'Rs ${cart.totalAmount.toStringAsFixed(0)}', colorScheme: colorScheme),
          const SizedBox(height: 12),
          _SummaryLine(label: 'Delivery Charge', value: 'Rs 100', color: AppColors.success, colorScheme: colorScheme),
          Divider(color: isLight ? colorScheme.outline.withOpacity(0.1) : AppColors.border, height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total to Pay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: colorScheme.onSurface)),
              Text('Rs ${(cart.totalAmount + 100).toStringAsFixed(0)}', 
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: colorScheme.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context, dynamic cart, dynamic address, dynamic user, ColorScheme colorScheme, bool isLight) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : AppColors.premiumDarkSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: isLight ? Colors.black.withOpacity(0.08) : Colors.black.withOpacity(0.3), 
            blurRadius: 30
          )
        ],
        border: Border.all(color: isLight ? colorScheme.outline.withOpacity(0.1) : colorScheme.outline.withOpacity(0.1)),
      ),
      child: ElevatedButton(
        onPressed: (_isPlacingOrder || address == null) ? null : () {
          if (_paymentMethod == 'Online Transfer') {
            _showQRScannerDialog(context, cart, address, user, colorScheme, isLight);
          } else {
            _placeOrder(context, cart, address, user);
          }
        },
        child: _isPlacingOrder 
          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_paymentMethod == 'Online Transfer' ? 'PAY & CONFIRM' : 'PLACE ORDER'),
                const SizedBox(width: 12),
                const Icon(Icons.verified_rounded, size: 20),
              ],
            ),
      ),
    );
  }

  void _showQRScannerDialog(BuildContext context, dynamic cart, dynamic address, dynamic user, ColorScheme colorScheme, bool isLight) {
    final total = cart.totalAmount + 100;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: isLight ? Colors.white : AppColors.dialog,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: colorScheme.onSurface.withOpacity(0.1), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text('Secure Checkout', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text('Scan QR code to pay Rs ${total.toStringAsFixed(0)}', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.w500)),
            const SizedBox(height: 32),
            
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: isLight ? AppColors.lightSecondaryBackground : Colors.white,
                borderRadius: BorderRadius.circular(32),
              ),
              child: QrImageView(
                data: 'PAYMENT_ID_${DateTime.now().millisecondsSinceEpoch}_AMT_$total',
                version: QrVersions.auto,
                size: 200.0,
                foregroundColor: isLight ? colorScheme.onBackground : AppColors.background,
              ),
            ),
            
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                'Open your digital wallet to scan and pay. We will verify your transaction automatically.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withOpacity(0.6), height: 1.6, fontWeight: FontWeight.w500),
              ),
            ),
            
            const Spacer(),
            
            _VerificationStatus(
              colorScheme: colorScheme,
              onComplete: () {
                Navigator.pop(context);
                _placeOrder(context, cart, address, user, isPrepaid: true);
              }
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _placeOrder(BuildContext context, dynamic cart, dynamic address, dynamic user, {bool isPrepaid = false}) async {
    if (cart.items.isEmpty) return;

    setState(() => _isPlacingOrder = true);
    
    try {
      final firstItem = cart.items.values.first;
      final deliveryOtp = (Random().nextInt(9000) + 1000).toString();

      // Fix shopName missing error by fetching shop data
      final shopDoc = await FirebaseFirestore.instance.collection('shops').doc(firstItem.product.shopId).get();
      final shopName = shopDoc.exists ? (shopDoc.data()?['name'] ?? 'Premium Shop') : 'Premium Shop';
      final shopImageUrl = shopDoc.exists ? (shopDoc.data()?['imageUrl'] ?? '') : '';

      final orderData = {
        'customerId': user.uid,
        'customerName': user.name,
        'customerPhone': user.phone,
        'vendorId': firstItem.product.vendorId,
        'shopId': firstItem.product.shopId,
        'shopName': cart.shopName ?? shopName,
        'shopImageUrl': cart.shopImageUrl ?? shopImageUrl,
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order placement failed: $e'), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }
}

class _VerificationStatus extends StatefulWidget {
  final ColorScheme colorScheme;
  final VoidCallback onComplete;
  const _VerificationStatus({required this.onComplete, required this.colorScheme});
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
    setState(() { _isSuccess = true; _status = 'Success! Finalizing...'; _progress = 1.0; });
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
              if (!_isSuccess) SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: widget.colorScheme.primary)),
              if (_isSuccess) const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
              const SizedBox(width: 12),
              Text(_status, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: _isSuccess ? AppColors.success : widget.colorScheme.onSurface)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: widget.colorScheme.onSurface.withOpacity(0.05),
              color: _isSuccess ? AppColors.success : widget.colorScheme.primary,
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
  final ColorScheme colorScheme;
  final bool isLight;

  const _PaymentTile({required this.title, required this.subtitle, required this.icon, required this.isSelected, required this.onTap, required this.colorScheme, required this.isLight});
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
            color: isSelected ? colorScheme.primary.withOpacity(0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary.withOpacity(0.1) : (isLight ? AppColors.lightSecondaryBackground : AppColors.background), 
                  borderRadius: BorderRadius.circular(14)
                ),
                child: Icon(icon, color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.3), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title, 
                      style: TextStyle(
                        fontWeight: FontWeight.w700, 
                        fontSize: 15, 
                        color: colorScheme.onSurface,
                      )
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle, 
                      style: TextStyle(color: colorScheme.onSurface.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.w500)
                    ),
                  ],
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, 
                  border: Border.all(color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.1), width: 2)
                ),
                child: isSelected 
                  ? Center(child: Container(width: 10, height: 10, decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle))) 
                  : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final ColorScheme colorScheme;
  const _SummaryLine({required this.label, required this.value, this.color, required this.colorScheme});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, 
      children: [
        Text(label, style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 14, fontWeight: FontWeight.w500)), 
        Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: color ?? colorScheme.onSurface))
      ]
    );
  }
}
