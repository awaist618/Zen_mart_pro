import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../models/user_model.dart';

class CustomerManagementScreen extends ConsumerStatefulWidget {
  const CustomerManagementScreen({super.key});

  @override
  ConsumerState<CustomerManagementScreen> createState() => _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends ConsumerState<CustomerManagementScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(allCustomersProvider);
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
                hintText: 'Search customers...',
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
      body: customersAsync.when(
        data: (customers) {
          final filtered = customers.where((c) => c.name.toLowerCase().contains(_searchQuery)).toList();

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_search_rounded, size: 64, color: colorScheme.onSurface.withValues(alpha: 0.1)),
                  const SizedBox(height: 16),
                  Text('No customers found.', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4), fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) => _CustomerListTile(customer: filtered[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _CustomerListTile extends ConsumerWidget {
  final UserModel customer;
  const _CustomerListTile({required this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDisabled = customer.status == 'disabled';

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
                child: Icon(Icons.person_outline_rounded, color: colorScheme.primary, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer.email,
                      style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      customer.phone,
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
                      color: (isDisabled ? const Color(0xFFEF4444) : const Color(0xFF10B981)).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      customer.status.toUpperCase(),
                      style: TextStyle(
                        color: isDisabled ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${customer.totalDeliveries} Orders',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: colorScheme.onSurface),
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
                icon: Icons.history_rounded,
                label: 'History',
                onTap: () {},
              ),
              _ActionButton(
                icon: isDisabled ? Icons.check_circle_outline : Icons.block_rounded,
                label: isDisabled ? 'Enable' : 'Disable',
                color: isDisabled ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                onTap: () {
                  ref.read(adminServiceProvider).updateUserStatus(
                    customer.uid, 
                    isDisabled ? 'active' : 'disabled'
                  );
                },
              ),
              _ActionButton(
                icon: Icons.delete_outline_rounded,
                label: 'Delete',
                color: const Color(0xFFEF4444),
                onTap: () => _showDeleteDialog(context, ref, customer),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, UserModel customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer?'),
        content: Text('Are you sure you want to delete "${customer.name}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(adminServiceProvider).deleteUser(customer.uid);
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
