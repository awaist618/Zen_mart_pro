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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)],
            ),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: const InputDecoration(
                hintText: 'Search riders...',
                border: InputBorder.none,
                icon: Icon(Icons.search, size: 20),
              ),
            ),
          ),
        ),
      ),
      body: ridersAsync.when(
        data: (riders) {
          final filtered = riders.where((r) => r.name.toLowerCase().contains(_searchQuery)).toList();

          if (filtered.isEmpty) {
            return const Center(child: Text('No riders found.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) => _RiderListTile(rider: filtered[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_rider_fab',
        onPressed: () => context.push('/admin/add-rider'),
        backgroundColor: AppColors.rider,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('Add Rider', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _RiderListTile extends ConsumerWidget {
  final UserModel rider;
  const _RiderListTile({required this.rider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isSuspended = rider.status == 'suspended';

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundColor: Color(0xFFF1F5F9),
                child: Icon(Icons.directions_bike_rounded, color: AppColors.rider, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rider.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rider.phone,
                      style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Vehicle: ${rider.vehicleInfo ?? "Not Set"}',
                      style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 12),
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
                      color: isSuspended ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      rider.status.toUpperCase(),
                      style: TextStyle(
                        color: isSuspended ? Colors.orange : Colors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Earnings: Rs ${rider.totalEarnings.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green),
                  ),
                  Text(
                    '${rider.totalDeliveries} Deliveries',
                    style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 11),
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
                color: isSuspended ? Colors.green : Colors.orange,
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
                color: Colors.red,
                onTap: () => _showDeleteDialog(context, ref, rider),
              ),
            ],
          ),
        ],
      ),
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
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 20, color: color ?? Colors.black.withOpacity(0.6)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color ?? Colors.black.withOpacity(0.6))),
        ],
      ),
    );
  }
}
