import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';

class SystemSettingsScreen extends ConsumerWidget {
  const SystemSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('System Settings', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildSectionHeader(context, 'MARKETPLACE CONFIG'),
          _buildSettingTile(context, icon: Icons.category_rounded, title: 'Categories', onTap: () => context.push('/admin/categories')),
          _buildSettingTile(context, icon: Icons.photo_library_rounded, title: 'Shop Banners', onTap: () {}),
          _buildSettingTile(context, icon: Icons.confirmation_number_rounded, title: 'Coupons', onTap: () {}),
          
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'FINANCIAL SETTINGS'),
          _buildSettingTile(context, icon: Icons.delivery_dining_rounded, title: 'Delivery Charges', onTap: () {}),
          _buildSettingTile(context, icon: Icons.receipt_rounded, title: 'Taxes', onTap: () {}),
          _buildSettingTile(context, icon: Icons.percent_rounded, title: 'Commission Percentage', onTap: () {}),

          const SizedBox(height: 24),
          _buildSectionHeader(context, 'APP CONFIGURATION'),
          _buildSettingTile(context, icon: Icons.notifications_active_rounded, title: 'Notification Settings', onTap: () {}),
          _buildSettingTile(context, icon: Icons.terminal_rounded, title: 'Firebase Config', onTap: () {}),
          _buildSettingTile(context, icon: Icons.info_outline_rounded, title: 'App Version', subtitle: 'v1.0.0+1', onTap: () {}),

          const SizedBox(height: 24),
          _buildSectionHeader(context, 'DATA MANAGEMENT'),
          _buildSettingTile(context, icon: Icons.backup_rounded, title: 'Backup Database', onTap: () {}),
          _buildSettingTile(context, icon: Icons.restore_rounded, title: 'Restore Database', color: const Color(0xFFF59E0B), onTap: () {}),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.3),
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = color ?? colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: accent, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colorScheme.onSurface),
        ),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 12)) : null,
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 12, color: colorScheme.onSurface.withValues(alpha: 0.2)),
      ),
    );
  }
}
