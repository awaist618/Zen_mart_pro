import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../models/user_model.dart';

class VendorManagementScreen extends ConsumerStatefulWidget {
  const VendorManagementScreen({super.key});

  @override
  ConsumerState<VendorManagementScreen> createState() => _VendorManagementScreenState();
}

class _VendorManagementScreenState extends ConsumerState<VendorManagementScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final vendorsAsync = ref.watch(allVendorsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
            ),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search vendors...',
                hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.3)),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                icon: Icon(Icons.search, size: 20, color: colorScheme.primary),
              ),
            ),
          ),
        ),
      ),
      body: vendorsAsync.when(
        data: (vendors) {
          final filtered = vendors.where((v) => v.name.toLowerCase().contains(_searchQuery)).toList();
          
          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_search_rounded, size: 64, color: colorScheme.onSurface.withValues(alpha: 0.1)),
                  const SizedBox(height: 16),
                  Text('No vendors found.', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4), fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) => _VendorListTile(vendor: filtered[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_vendor_fab',
        onPressed: () => context.push('/admin/add-vendor'),
        backgroundColor: colorScheme.primary,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('CREATE VENDOR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
      ),
    );
  }
}

class _VendorListTile extends ConsumerWidget {
  final UserModel vendor;
  const _VendorListTile({required this.vendor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isSuspended = vendor.status == 'suspended';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                child: Icon(Icons.storefront_rounded, color: colorScheme.primary, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendor.name,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Shop ID: ${vendor.shopId ?? "Not Assigned"}',
                      style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      vendor.phone,
                      style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isSuspended ? const Color(0xFFF59E0B) : const Color(0xFF10B981)).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      vendor.status.toUpperCase(),
                      style: TextStyle(
                        color: isSuspended ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 16),
                      Text(' ${vendor.rating}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: colorScheme.onSurface)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 32),
          Wrap(
            spacing: 20,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _ActionButton(
                icon: Icons.edit_outlined,
                label: 'Edit',
                onTap: () {},
              ),
              _ActionButton(
                icon: Icons.assignment_outlined,
                label: 'Assign Shop',
                onTap: () {},
              ),
              _ActionButton(
                icon: Icons.inventory_2_outlined,
                label: 'Products',
                onTap: () {},
              ),
              _ActionButton(
                icon: Icons.receipt_long_outlined,
                label: 'Orders',
                onTap: () {},
              ),
              _ActionButton(
                icon: isSuspended ? Icons.check_circle_outline : Icons.block_rounded,
                label: isSuspended ? 'Activate' : 'Suspend',
                color: isSuspended ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                onTap: () {
                  ref.read(adminServiceProvider).updateUserStatus(
                    vendor.uid, 
                    isSuspended ? 'active' : 'suspended'
                  );
                },
              ),
              _ActionButton(
                icon: Icons.lock_reset_rounded,
                label: 'Reset Pwd',
                color: const Color(0xFF38BDF8),
                onTap: () {},
              ),
              _ActionButton(
                icon: Icons.delete_outline_rounded,
                label: 'Delete',
                color: const Color(0xFFEF4444),
                onTap: () => _showDeleteDialog(context, ref, vendor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, UserModel vendor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vendor?'),
        content: Text('Are you sure you want to delete "${vendor.name}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(adminServiceProvider).deleteUser(vendor.uid);
              context.pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionButton({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 20, color: color ?? colorScheme.onSurface.withValues(alpha: 0.6)),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color ?? colorScheme.onSurface.withValues(alpha: 0.6))),
        ],
      ),
    );
  }
}
