import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/providers.dart';
import '../../models/payout_model.dart';
import '../../theme/app_colors.dart';

class PayoutManagementScreen extends ConsumerWidget {
  const PayoutManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payoutsAsync = ref.watch(payoutRequestsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Payout Management', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black,
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Withdraw Requests'),
              Tab(text: 'Payment History'),
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
    final bool isPending = payout.status == PayoutStatus.pending;

    return Container(
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (payout.userType == PayoutUserType.vendor ? AppColors.vendor : AppColors.rider).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  payout.userType == PayoutUserType.vendor ? Icons.storefront_rounded : Icons.directions_bike_rounded,
                  color: payout.userType == PayoutUserType.vendor ? AppColors.vendor : AppColors.rider,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(payout.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(payout.userType.name.toUpperCase(), style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Text(
                'Rs ${payout.amount.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.green),
              ),
            ],
          ),
          const Divider(height: 24),
          if (isPending)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => ref.read(adminServiceProvider).updatePayoutStatus(payout.id, PayoutStatus.rejected),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showMarkPaidDialog(context, ref),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    child: const Text('Mark Paid'),
                  ),
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status: ${payout.status.name.toUpperCase()}',
                  style: TextStyle(
                    color: payout.status == PayoutStatus.paid ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  DateFormat('MMM dd, yyyy').format(payout.processedAt ?? payout.createdAt),
                  style: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 11),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _showMarkPaidDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            TextField(decoration: InputDecoration(hintText: 'Payment Method (e.g. JazzCash)')),
            SizedBox(height: 12),
            TextField(decoration: InputDecoration(hintText: 'Transaction ID')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(adminServiceProvider).updatePayoutStatus(payout.id, PayoutStatus.paid, txId: 'TX123', method: 'JazzCash');
              Navigator.pop(context);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
