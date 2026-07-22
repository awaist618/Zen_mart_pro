import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';

class ShopManagementScreen extends ConsumerWidget {
  const ShopManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Shop Management', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildManagementCard(
            context,
            title: 'All Shops',
            subtitle: 'View and manage all registered stores',
            icon: Icons.storefront_rounded,
            color: Colors.blue,
            onTap: () => context.push('/admin/all-shops'),
          ),
          _buildManagementCard(
            context,
            title: 'Create Shop',
            subtitle: 'Register a new store and assign vendor',
            icon: Icons.add_business_rounded,
            color: Colors.green,
            onTap: () => context.push('/admin/add-vendor'),
          ),
          _buildManagementCard(
            context,
            title: 'Assign Vendor',
            subtitle: 'Link a vendor to an existing shop',
            icon: Icons.person_add_alt_1_rounded,
            color: Colors.orange,
            onTap: () {}, // Implementation coming soon
          ),
          _buildManagementCard(
            context,
            title: 'Shop Categories',
            subtitle: 'Manage marketplace store categories',
            icon: Icons.category_rounded,
            color: Colors.purple,
            onTap: () {}, // Implementation coming soon
          ),
          _buildManagementCard(
            context,
            title: 'Shop Banners',
            subtitle: 'Upload and manage promotional banners',
            icon: Icons.photo_library_rounded,
            color: Colors.teal,
            onTap: () {}, // Implementation coming soon
          ),
          _buildManagementCard(
            context,
            title: 'Shop Status',
            subtitle: 'Bulk update shop visibility and status',
            icon: Icons.toggle_on_rounded,
            color: Colors.redAccent,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 13)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
      ),
    );
  }
}
