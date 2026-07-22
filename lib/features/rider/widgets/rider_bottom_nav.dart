import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';

class RiderBottomNav extends StatelessWidget {
  final int currentIndex;
  const RiderBottomNav({super.key, required this.currentIndex});

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
            onTap: () => context.go('/rider'),
          ),
          _BottomNavItem(
            icon: Icons.task_rounded, 
            label: 'Tasks', 
            isActive: currentIndex == 1,
            onTap: () => context.go('/rider/active-tasks'),
          ),
          _BottomNavItem(
            icon: Icons.history_rounded, 
            label: 'History', 
            isActive: currentIndex == 2,
            onTap: () => context.go('/rider/history'),
          ),
          _BottomNavItem(
            icon: Icons.person_rounded, 
            label: 'Profile', 
            isActive: currentIndex == 3,
            onTap: () => context.go('/rider/profile'),
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
            color: isActive ? AppColors.rider : const Color(0xFF94A3B8),
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.rider : const Color(0xFF94A3B8),
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
