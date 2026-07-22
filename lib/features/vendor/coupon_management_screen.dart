import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/providers.dart';
import '../../models/coupon_model.dart';
import '../../theme/app_colors.dart';

class CouponManagementScreen extends ConsumerWidget {
  const CouponManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couponsAsync = ref.watch(shopCouponsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Coupons', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: couponsAsync.when(
        data: (coupons) {
          if (coupons.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.confirmation_number_outlined, size: 64, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text('No coupons created yet', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: coupons.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _CouponTile(coupon: coupons[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCouponDialog(context, ref),
        backgroundColor: const Color(0xFFF59E0B),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Coupon', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showCouponDialog(BuildContext context, WidgetRef ref, {CouponModel? coupon}) {
    final codeController = TextEditingController(text: coupon?.code);
    final percentageController = TextEditingController(text: coupon?.discountPercentage.toString());
    final fixedController = TextEditingController(text: coupon?.fixedDiscount.toString());
    final minOrderController = TextEditingController(text: coupon?.minOrderAmount.toString());
    DateTime expiryDate = coupon?.expiryDate ?? DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(coupon == null ? 'Create Coupon' : 'Edit Coupon'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(labelText: 'Coupon Code (e.g. SAVE20)'),
                  textCapitalization: TextCapitalization.characters,
                ),
                TextField(
                  controller: percentageController,
                  decoration: const InputDecoration(labelText: 'Discount Percentage (%)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: fixedController,
                  decoration: const InputDecoration(labelText: 'Fixed Discount (Rs)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: minOrderController,
                  decoration: const InputDecoration(labelText: 'Minimum Order Amount'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Expiry Date'),
                  subtitle: Text(DateFormat('MMM dd, yyyy').format(expiryDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: expiryDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => expiryDate = picked);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final user = ref.read(userModelProvider).asData?.value;
                if (user?.shopId == null) return;

                final newCoupon = CouponModel(
                  id: coupon?.id ?? '',
                  shopId: user!.shopId!,
                  code: codeController.text.trim().toUpperCase(),
                  discountPercentage: double.tryParse(percentageController.text) ?? 0,
                  fixedDiscount: double.tryParse(fixedController.text) ?? 0,
                  expiryDate: expiryDate,
                  minOrderAmount: double.tryParse(minOrderController.text) ?? 0,
                  isActive: coupon?.isActive ?? true,
                );

                if (coupon == null) {
                  ref.read(vendorServiceProvider).addCoupon(newCoupon);
                } else {
                  ref.read(vendorServiceProvider).updateCoupon(coupon.id, newCoupon.toMap());
                }
                Navigator.pop(context);
              },
              child: Text(coupon == null ? 'Create' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CouponTile extends ConsumerWidget {
  final CouponModel coupon;
  const _CouponTile({required this.coupon});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isExpired = coupon.expiryDate.isBefore(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.confirmation_number_rounded, color: Color(0xFFF59E0B)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coupon.code,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.2),
                    ),
                    Text(
                      coupon.discountPercentage > 0 
                          ? '${coupon.discountPercentage}% OFF' 
                          : 'Rs ${coupon.fixedDiscount} OFF',
                      style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: coupon.isActive && !isExpired,
                onChanged: isExpired ? null : (v) {
                  ref.read(vendorServiceProvider).updateCoupon(coupon.id, {'isActive': v});
                },
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Min Order: Rs ${coupon.minOrderAmount}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  Text(
                    'Expires: ${DateFormat('MMM dd, yyyy').format(coupon.expiryDate)}',
                    style: TextStyle(
                      color: isExpired ? Colors.red : Colors.grey[600],
                      fontSize: 12,
                      fontWeight: isExpired ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => const CouponManagementScreen()._showCouponDialog(context, ref, coupon: coupon),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red),
                    onPressed: () => _showDeleteDialog(context, ref),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Coupon?'),
        content: Text('Are you sure you want to delete "${coupon.code}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(vendorServiceProvider).deleteCoupon(coupon.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
