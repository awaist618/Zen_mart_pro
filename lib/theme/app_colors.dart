import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF4F46E5);
  static const Color accent = Color(0xFF06B6D4);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color divider = Color(0xFFE2E8F0);
  
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // Role colors (matching the requested accent/primary for context)
  static const Color admin = primary;
  static const Color vendor = Color(0xFF8B5CF6);
  static const Color customer = accent;
  static const Color rider = Color(0xFFF43F5E);

  static const Color vendorAccent = vendor;
  static const Color customerAccent = customer;
  static const Color riderAccent = rider;

  /// Returns the accent color tied to a given role string
  static Color forRole(String role) {
    switch (role.toLowerCase()) {
      case 'super_admin':
      case 'admin':
        return admin;
      case 'vendor':
        return vendor;
      case 'customer':
        return customer;
      case 'rider':
        return rider;
      default:
        return primary;
    }
  }

  /// Soft gradient per role — used on dashboard headers & role cards.
  static LinearGradient gradientForRole(String role) {
    final Color c = forRole(role);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [c, Color.lerp(c, Colors.white, 0.25)!],
    );
  }
}
