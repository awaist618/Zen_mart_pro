import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../models/user_model.dart';
import '../../theme/app_colors.dart';

class RiderManagementScreen extends ConsumerStatefulWidget {
  const RiderManagementScreen({super.key});

  @override
  ConsumerState<RiderManagementScreen> createState() => _RiderManagementScreenState();
}

class _RiderManagementScreenState extends ConsumerState<RiderManagementScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final ridersAsync = ref.watch(allRidersProvider);
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
                hintText: 'Search riders...',
                hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.3)),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                icon: Icon(Icons.search, size: 20, color: const Color(0xFFD6B08A)),
              ),
            ),
          ),
        ),
      ),
      body: ridersAsync.when(
        data: (riders) {
          final filtered = riders.where((r) => r.name.toLowerCase().contains(_searchQuery)).toList();

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_search_rounded, size: 64, color: colorScheme.onSurface.withValues(alpha: 0.1)),
                  const SizedBox(height: 16),
                  Text('No riders found.', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4), fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) => _RiderListTile(rider: filtered[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_rider_fab',
        onPressed: () => context.push('/admin/add-rider'),
        backgroundColor: const Color(0xFFD6B08A),
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('ADD RIDER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
      ),
    );
  }
}

class _RiderListTile extends ConsumerWidget {
  final UserModel rider;
  const _RiderListTile({required this.rider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isSuspended = rider.status == 'suspended';

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
                backgroundColor: const Color(0xFFD6B08A).withValues(alpha: 0.1),
                child: const Icon(Icons.directions_bike_rounded, color: Color(0xFFD6B08A), size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rider.name,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rider.phone,
                      style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Vehicle: ${rider.vehicleInfo ?? "Not Set"}',
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
                      rider.status.toUpperCase(),
                      style: TextStyle(
                        color: isSuspended ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Rs ${rider.totalEarnings.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF10B981)),
                  ),
                  Text(
                    '${rider.totalDeliveries} Deliveries',
                    style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.3), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ActionButton(
                icon: Icons.visibility_outlined,
                label: 'View',
                onTap: () {},
              ),
              _ActionButton(
                icon: Icons.edit_outlined,
                label: 'Edit',
                onTap: () {},
              ),
              _ActionButton(
                icon: isSuspended ? Icons.check_circle_outline : Icons.block_rounded,
                label: isSuspended ? 'Activate' : 'Suspend',
                color: isSuspended ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                onTap: () {
                  ref.read(adminServiceProvider).updateRiderStatus(
                    rider.uid, 
                    isSuspended ? 'active' : 'suspended'
                  );
                },
              ),
              _ActionButton(
                icon: Icons.delete_outline_rounded,
                label: 'Delete',
                color: const Color(0xFFEF4444),
                onTap: () => _showDeleteDialog(context, ref, rider),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, UserModel rider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Rider?'),
        content: Text('Are you sure you want to delete "${rider.name}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(adminServiceProvider).deleteRider(rider.uid);
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
