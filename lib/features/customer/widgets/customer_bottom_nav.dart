import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';

class CustomerBottomNav extends StatelessWidget {
  final int currentIndex;
  const CustomerBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 30),
      height: 76,
      decoration: BoxDecoration(
        color: isLight ? Colors.white.withOpacity(0.9) : AppColors.bottomNav.withOpacity(0.85),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: isLight ? Colors.black.withOpacity(0.08) : Colors.black.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: isLight ? colorScheme.outline.withOpacity(0.1) : Colors.white.withOpacity(0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _CustomerNavItem(
                icon: Icons.grid_view_rounded, 
                label: 'Home', 
                isActive: currentIndex == 0,
                onTap: () => context.go('/customer'),
              ),
              _CustomerNavItem(
                icon: Icons.search_rounded, 
                label: 'Search', 
                isActive: currentIndex == 1,
                onTap: () => context.go('/customer/search'),
              ),
              _CustomerNavItem(
                icon: Icons.shopping_bag_rounded, 
                label: 'Cart', 
                isActive: currentIndex == 2,
                onTap: () => context.go('/customer/cart'),
              ),
              _CustomerNavItem(
                icon: Icons.person_rounded, 
                label: 'Account', 
                isActive: currentIndex == 3,
                onTap: () => context.go('/customer/profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _CustomerNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(horizontal: isActive ? 20 : 10, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? colorScheme.primary.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: isActive ? colorScheme.primary : (isLight ? AppColors.lightTextHint : const Color(0xFF7C8596)),
              size: 26,
            ),
          ),
          if (!isActive) ...[
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isLight ? AppColors.lightTextHint : const Color(0xFF7C8596),
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
