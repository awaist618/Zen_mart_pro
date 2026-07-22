import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/providers.dart';
import '../../theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../models/order_model.dart';
import '../../services/pdf_service.dart';

class RiderEarningsScreen extends ConsumerWidget {
  const RiderEarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userModelProvider).asData?.value;
    final todayHistoryAsync = ref.watch(todayRiderHistoryProvider);

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Earnings Summary", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () {
              final history = ref.read(riderHistoryProvider).asData?.value ?? [];
              PdfService.generateRiderEarningsReport(user, history);
            },
            tooltip: 'Export Statement',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _EarningSummaryCard(user: user),
            const SizedBox(height: 32),
            
            _SectionHeader(title: 'Earnings Breakdown'),
            const SizedBox(height: 12),
            _EarningsGrid(user: user),
            
            const SizedBox(height: 32),
            _SectionHeader(title: 'Withdrawals'),
            const SizedBox(height: 12),
            _WithdrawalStatusCard(),
            
            const SizedBox(height: 32),
            const Text("Today's Deliveries", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            todayHistoryAsync.when(
              data: (orders) => orders.isEmpty
                  ? const Center(child: Text('No deliveries yet today.'))
                  : Column(children: orders.map((o) => _OrderEarningTile(order: o)).toList()),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Error: $e'),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: _WithdrawalAction(balance: user.totalEarnings, user: user),
    );
  }
}

class _EarningSummaryCard extends StatelessWidget {
  final UserModel user;
  const _EarningSummaryCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.rider, Color(0xFFE11D48)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: AppColors.rider.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Text("AVAILABLE BALANCE", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text('Rs ${user.totalEarnings.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MiniStat(label: 'Deliveries', value: user.totalDeliveries.toString()),
              Container(width: 1, height: 20, color: Colors.white24),
              _MiniStat(label: 'Rating', value: user.rating.toStringAsFixed(1)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
      ],
    );
  }
}

class _EarningsGrid extends StatelessWidget {
  final UserModel user;
  const _EarningsGrid({required this.user});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.6,
      children: [
        _StatBox(label: 'Today', value: 'Rs 1,200', color: Colors.blue),
        _StatBox(label: 'This Week', value: 'Rs 8,450', color: Colors.purple),
        _StatBox(label: 'This Month', value: 'Rs 28,000', color: Colors.orange),
        _StatBox(label: 'Lifetime', value: 'Rs ${user.totalEarnings.toStringAsFixed(0)}', color: Colors.green),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatBox({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _WithdrawalStatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.pending_actions_rounded, color: Colors.orange, size: 20),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pending Withdrawal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Requested on Oct 24', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const Text('Rs 5,000', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
        ],
      ),
    );
  }
}

class _WithdrawalAction extends StatelessWidget {
  final double balance;
  final UserModel user;
  const _WithdrawalAction({required this.balance, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: ElevatedButton(
        onPressed: balance < 500 ? null : () => _showWithdrawalDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.rider,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text('Withdraw Earnings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showWithdrawalDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Withdraw Funds', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Available Balance: Rs ${balance.toStringAsFixed(0)}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: 'Rs ',
                hintText: 'Enter amount to withdraw',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Method', border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
              items: const [
                DropdownMenuItem(value: 'bank', child: Text('Bank Account')),
                DropdownMenuItem(value: 'easypaisa', child: Text('Easypaisa')),
                DropdownMenuItem(value: 'jazzcash', child: Text('JazzCash')),
              ],
              onChanged: (v) {},
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rider,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Submit Request', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) => Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
}

class _OrderEarningTile extends StatelessWidget {
  final dynamic order;
  const _OrderEarningTile({required this.order});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10)]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order #${order.id.substring(0, 8).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('${DateFormat('h:mm a').format(order.deliveredAt ?? DateTime.now())} • ${order.shopName}', style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 12)),
            ],
          ),
          Text('+ Rs ${order.deliveryFee.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
        ],
      ),
    );
  }
}
