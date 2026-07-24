import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';

class ShopManagementScreen extends ConsumerWidget {
  const ShopManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Shop Management', style: TextStyle(fontWeight: FontWeight.w900)),
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
          _buildManagementCard(
            context,
            title: 'All Shops',
            subtitle: 'View and manage all registered stores',
            icon: Icons.storefront_rounded,
            color: const Color(0xFF6366F1),
            onTap: () => context.push('/admin/all-shops'),
          ),
          _buildManagementCard(
            context,
            title: 'Create Shop',
            subtitle: 'Register a new store and assign vendor',
            icon: Icons.add_business_rounded,
            color: const Color(0xFF10B981),
            onTap: () => context.push('/admin/add-vendor'),
          ),
          _buildManagementCard(
            context,
            title: 'Assign Vendor',
            subtitle: 'Link a vendor to an existing shop',
            icon: Icons.person_add_alt_1_rounded,
            color: const Color(0xFFF59E0B),
            onTap: () {}, // Implementation coming soon
          ),
          _buildManagementCard(
            context,
            title: 'Shop Categories',
            subtitle: 'Manage marketplace store categories',
            icon: Icons.category_rounded,
            color: const Color(0xFF8B5CF6),
            onTap: () => context.push('/admin/categories'),
          ),
          _buildManagementCard(
            context,
            title: 'Shop Banners',
            subtitle: 'Upload and manage promotional banners',
            icon: Icons.photo_library_rounded,
            color: const Color(0xFF06B6D4),
            onTap: () {}, // Implementation coming soon
          ),
          _buildManagementCard(
            context,
            title: 'Shop Status',
            subtitle: 'Bulk update shop visibility and status',
            icon: Icons.toggle_on_rounded,
            color: const Color(0xFFEF4444),
            onTap: () => context.push('/admin/all-shops'), // Can filter by status here later
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildManagementCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onSurface)),
        subtitle: Text(subtitle, style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 13)),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: colorScheme.onSurface.withValues(alpha: 0.3)),
      ),
    );
  }
}
