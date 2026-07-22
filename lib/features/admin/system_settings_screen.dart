import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';

class SystemSettingsScreen extends ConsumerWidget {
  const SystemSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('System Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader('MARKETPLACE CONFIG'),
          _buildSettingTile(icon: Icons.category_rounded, title: 'Categories', onTap: () {}),
          _buildSettingTile(icon: Icons.photo_library_rounded, title: 'Shop Banners', onTap: () {}),
          _buildSettingTile(icon: Icons.confirmation_number_rounded, title: 'Coupons', onTap: () {}),
          
          const SizedBox(height: 24),
          _buildSectionHeader('FINANCIAL SETTINGS'),
          _buildSettingTile(icon: Icons.delivery_dining_rounded, title: 'Delivery Charges', onTap: () {}),
          _buildSettingTile(icon: Icons.receipt_rounded, title: 'Taxes', onTap: () {}),
          _buildSettingTile(icon: Icons.percent_rounded, title: 'Commission Percentage', onTap: () {}),

          const SizedBox(height: 24),
          _buildSectionHeader('APP CONFIGURATION'),
          _buildSettingTile(icon: Icons.notifications_active_rounded, title: 'Notification Settings', onTap: () {}),
          _buildSettingTile(icon: Icons.terminal_rounded, title: 'Firebase Config', onTap: () {}),
          _buildSettingTile(icon: Icons.info_outline_rounded, title: 'App Version', subtitle: 'v1.0.0+1', onTap: () {}),

          const SizedBox(height: 24),
          _buildSectionHeader('DATA MANAGEMENT'),
          _buildSettingTile(icon: Icons.backup_rounded, title: 'Backup Database', onTap: () {}),
          _buildSettingTile(icon: Icons.restore_rounded, title: 'Restore Database', color: Colors.orange, onTap: () {}),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.black.withOpacity(0.4),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (color ?? AppColors.primary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color ?? AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
      ),
    );
  }
}
