import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/providers.dart';
import '../../models/payout_model.dart';
import '../../theme/app_colors.dart';

class PayoutManagementScreen extends ConsumerWidget {
  const PayoutManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payoutsAsync = ref.watch(payoutRequestsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Payout Management', style: TextStyle(fontWeight: FontWeight.w900)),
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: colorScheme.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: TabBar(
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.4),
            indicatorColor: colorScheme.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            tabs: const [
              Tab(text: 'REQUESTS'),
              Tab(text: 'HISTORY'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _PayoutList(statusFilter: [PayoutStatus.pending, PayoutStatus.approved]),
            _PayoutList(statusFilter: [PayoutStatus.paid, PayoutStatus.rejected]),
          ],
        ),
      ),
    );
  }
}

class _PayoutList extends ConsumerWidget {
  final List<PayoutStatus> statusFilter;
  const _PayoutList({required this.statusFilter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payoutsAsync = ref.watch(payoutRequestsProvider);

    return payoutsAsync.when(
      data: (allPayouts) {
        final payouts = allPayouts.where((p) => statusFilter.contains(p.status)).toList();
        
        if (payouts.isEmpty) {
          return const Center(child: Text('No payouts found for this category.'));
        }
        
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: payouts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) => _PayoutListTile(payout: payouts[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}

class _PayoutListTile extends ConsumerWidget {
  final PayoutModel payout;
  const _PayoutListTile({required this.payout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isPending = payout.status == PayoutStatus.pending;

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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (payout.userType == PayoutUserType.vendor ? const Color(0xFF6366F1) : const Color(0xFFD6B08A)).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  payout.userType == PayoutUserType.vendor ? Icons.storefront_rounded : Icons.directions_bike_rounded,
                  color: payout.userType == PayoutUserType.vendor ? const Color(0xFF6366F1) : const Color(0xFFD6B08A),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(payout.userName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: colorScheme.onSurface)),
                    Text(payout.userType.name.toUpperCase(), style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Text(
                'Rs ${payout.amount.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF10B981)),
              ),
            ],
          ),
          const Divider(height: 32),
          if (isPending)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => ref.read(adminServiceProvider).updatePayoutStatus(payout.id, PayoutStatus.rejected),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      minimumSize: const Size(0, 48),
                    ),
                    child: const Text('REJECT'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showMarkPaidDialog(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981), 
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 48),
                    ),
                    child: const Text('MARK PAID'),
                  ),
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (payout.status == PayoutStatus.paid ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    payout.status.name.toUpperCase(),
                    style: TextStyle(
                      color: payout.status == PayoutStatus.paid ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Text(
                  DateFormat('MMM dd, yyyy').format(payout.processedAt ?? payout.createdAt),
                  style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.3), fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _showMarkPaidDialog(BuildContext context, WidgetRef ref) {
    final methodController = TextEditingController(text: 'Bank Transfer');
    final txController = TextEditingController();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
        ),
        title: Text('Confirm Payment', style: TextStyle(fontWeight: FontWeight.w900, color: colorScheme.onSurface)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('BANK DETAILS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: colorScheme.onSurface.withValues(alpha: 0.3), letterSpacing: 1.5)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.05), 
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outline.withValues(alpha: 0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bank: ${payout.bankDetails?['bankName'] ?? 'Not set'}', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                  const SizedBox(height: 4),
                  Text('Account: ${payout.bankDetails?['accountNumber'] ?? 'Not set'}', style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withValues(alpha: 0.6))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: methodController,
              decoration: const InputDecoration(labelText: 'Payment Method', hintText: 'e.g. HBL, JazzCash'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: txController,
              decoration: const InputDecoration(labelText: 'Transaction ID / Reference'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text('CANCEL', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4), fontWeight: FontWeight.bold))
          ),
          ElevatedButton(
            onPressed: () {
              if (txController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter Transaction ID')));
                return;
              }
              ref.read(adminServiceProvider).updatePayoutStatus(
                payout.id, 
                PayoutStatus.paid, 
                txId: txController.text.trim(), 
                method: methodController.text.trim()
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981), 
              foregroundColor: Colors.white,
              minimumSize: const Size(120, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('PROCESS'),
          ),
        ],
      ),
    );
  }
}
