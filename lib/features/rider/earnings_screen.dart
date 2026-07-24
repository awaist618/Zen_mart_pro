import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../models/order_model.dart';
import '../../services/pdf_service.dart';

class RiderEarningsScreen extends ConsumerWidget {
  const RiderEarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = ref.watch(userModelProvider).asData?.value;
    final todayHistoryAsync = ref.watch(todayRiderHistoryProvider);

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Earnings & Payouts", style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: colorScheme.onSurface),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/rider');
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf_rounded, color: colorScheme.primary),
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
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _EarningHero(user: user),
            const SizedBox(height: 40),
            
            _SectionTitle(title: 'STATISTICS', color: colorScheme.primary),
            const SizedBox(height: 16),
            _EarningsGrid(user: user, colorScheme: colorScheme),
            
            const SizedBox(height: 40),
            _SectionTitle(title: 'WITHDRAWAL STATUS', color: colorScheme.primary),
            const SizedBox(height: 16),
            _WithdrawalStatusCard(colorScheme: colorScheme),
            
            const SizedBox(height: 40),
            _SectionTitle(title: "TODAY'S ACTIVITY", color: AppColors.success),
            const SizedBox(height: 16),
            todayHistoryAsync.when(
              data: (orders) => orders.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Text('No activity today.', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.3))),
                      ),
                    )
                  : Column(children: orders.map((o) => _OrderEarningTile(order: o, colorScheme: colorScheme)).toList()),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Error: $e'),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomSheet: _WithdrawalAction(balance: user.totalEarnings, user: user, theme: theme),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionTitle({required this.title, required this.color});
  @override
  Widget build(BuildContext context) => Row(children: [const SizedBox(width: 4), Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color.withValues(alpha: 0.6), letterSpacing: 2))]);
}

class _EarningHero extends StatelessWidget {
  final UserModel user;
  const _EarningHero({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(36),
        boxShadow: [BoxShadow(color: AppColors.rider.withValues(alpha: 0.1), blurRadius: 40)],
      ),
      child: Column(
        children: [
          Text("AVAILABLE BALANCE", style: TextStyle(color: AppColors.rider.withValues(alpha: 0.6), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 12),
          Text('Rs ${user.totalEarnings.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -1)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _HeroStat(label: 'Total Tasks', value: user.totalDeliveries.toString()),
              Container(width: 1, height: 24, color: Colors.white10, margin: const EdgeInsets.symmetric(horizontal: 32)),
              _HeroStat(label: 'Avg. Rating', value: user.rating.toStringAsFixed(1)),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  const _HeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _EarningsGrid extends StatelessWidget {
  final UserModel user;
  final ColorScheme colorScheme;
  const _EarningsGrid({required this.user, required this.colorScheme});

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
        _StatCard(label: 'TODAY', value: 'Rs 1,200', color: Colors.blue),
        _StatCard(label: 'WEEKLY', value: 'Rs 8,450', color: Colors.purple),
        _StatCard(label: 'MONTHLY', value: 'Rs 28,000', color: Colors.orange),
        _StatCard(label: 'LIFETIME', value: 'Rs ${user.totalEarnings.toInt()}', color: AppColors.success),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.3), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 4),
          FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900))),
        ],
      ),
    );
  }
}

class _WithdrawalStatusCard extends StatelessWidget {
  final ColorScheme colorScheme;
  const _WithdrawalStatusCard({required this.colorScheme});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.timer_rounded, color: Colors.orange, size: 22),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Processing...', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                const SizedBox(height: 2),
                Text('Payout ID: #X2481A', style: TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const Text('Rs 5,000', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.orange, fontSize: 16)),
        ],
      ),
    );
  }
}

class _WithdrawalAction extends StatelessWidget {
  final double balance;
  final UserModel user;
  final ThemeData theme;
  const _WithdrawalAction({required this.balance, required this.user, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1))),
      ),
      child: ElevatedButton(
        onPressed: balance < 500 ? null : () => _showWithdrawalSheet(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.rider,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 64),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: Text('REQUEST PAYOUT', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1)),
      ),
    );
  }

  void _showWithdrawalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(36))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 28, right: 28, top: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Payout Request', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
            const SizedBox(height: 8),
            Text('Balance: Rs ${balance.toStringAsFixed(0)}', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontWeight: FontWeight.w600)),
            const SizedBox(height: 32),
            _buildField(label: 'Amount', hint: '0.00', icon: Icons.payments_rounded, prefix: 'Rs '),
            const SizedBox(height: 20),
            _buildField(label: 'Method', hint: 'Select Method', icon: Icons.account_balance_wallet_rounded),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rider,
                minimumSize: const Size(double.infinity, 64),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('SUBMIT REQUEST', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildField({required String label, required String hint, required IconData icon, String? prefix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        TextField(
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.1)),
            prefixIcon: Icon(icon, color: AppColors.rider, size: 20),
            prefixText: prefix,
            prefixStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
            filled: true,
            fillColor: Colors.black26,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}

class _OrderEarningTile extends StatelessWidget {
  final dynamic order;
  final ColorScheme colorScheme;
  const _OrderEarningTile({required this.order, required this.colorScheme});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface, 
        borderRadius: BorderRadius.circular(24), 
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.05))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order #${order.id.substring(0, 5).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
              const SizedBox(height: 2),
              Text('${DateFormat('h:mm a').format(order.deliveredAt ?? DateTime.now())} • ${order.shopName}', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.3), fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
          Text('+Rs ${order.deliveryFee.toInt()}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.success, fontSize: 16)),
        ],
      ),
    );
  }
}
