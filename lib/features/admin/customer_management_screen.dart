import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../models/user_model.dart';
import '../../theme/app_colors.dart';

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
                hintText: 'Search customers...',
                border: InputBorder.none,
                icon: Icon(Icons.search, size: 20),
              ),
            ),
          ),
        ),
      ),
      body: customersAsync.when(
        data: (customers) {
          final filtered = customers.where((c) => c.name.toLowerCase().contains(_searchQuery)).toList();

          if (filtered.isEmpty) {
            return const Center(child: Text('No customers found.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
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
    final bool isDisabled = customer.status == 'disabled';

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
                child: Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer.email,
                      style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      customer.phone,
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
                      color: isDisabled ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      customer.status.toUpperCase(),
                      style: TextStyle(
                        color: isDisabled ? Colors.red : Colors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${customer.totalDeliveries} Orders', // Reusing field for customer
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
                color: isDisabled ? Colors.green : Colors.orange,
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
                color: Colors.red,
                onTap: () => _showDeleteDialog(context, ref, customer),
              ),
            ],
          ),
        ],
      ),
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
