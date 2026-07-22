import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VendorBottomNav extends StatelessWidget {
  final int currentIndex;
  const VendorBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomNavItem(
            icon: Icons.dashboard_rounded, 
            label: 'Home', 
            isActive: currentIndex == 0,
            onTap: () => context.go('/vendor'),
          ),
          _BottomNavItem(
            icon: Icons.receipt_long_rounded, 
            label: 'Orders', 
            isActive: currentIndex == 1,
            onTap: () => context.go('/vendor/orders'),
          ),
          _BottomNavItem(
            icon: Icons.inventory_2_rounded, 
            label: 'Items', 
            isActive: currentIndex == 2,
            onTap: () => context.go('/vendor/products'),
          ),
          _BottomNavItem(
            icon: Icons.person_rounded, 
            label: 'Profile', 
            isActive: currentIndex == 3,
            onTap: () => context.go('/vendor/profile'),
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF8B5CF6) : const Color(0xFF94A3B8),
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFF8B5CF6) : const Color(0xFF94A3B8),
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
