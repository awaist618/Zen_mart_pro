import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderId;
  const OrderSuccessScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.03),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated-like check icon
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.05), shape: BoxShape.circle),
                      ),
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), shape: BoxShape.circle),
                      ),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                        child: const Icon(Icons.check_rounded, size: 60, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  const Text(
                    'Order Confirmed!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your payment was successful and your order is now being prepared by the store.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w600, height: 1.5),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC), 
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        Text('REFERENCE ID', style: TextStyle(color: Colors.black.withOpacity(0.3), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2)),
                        const SizedBox(height: 4),
                        Text('#${orderId.substring(0, 12).toUpperCase()}', style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800, fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go('/customer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 22),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 0,
                      ),
                      child: const Text('Back to Home', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => context.push('/customer/order-details/$orderId'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map_rounded, size: 18, color: AppColors.accent),
                          SizedBox(width: 10),
                          Text('Track Delivery Status', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900, fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
