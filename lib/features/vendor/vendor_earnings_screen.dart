import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/providers.dart';
import '../../theme/app_colors.dart';

class VendorEarningsScreen extends ConsumerStatefulWidget {
  const VendorEarningsScreen({super.key});

  @override
  ConsumerState<VendorEarningsScreen> createState() => _VendorEarningsScreenState();
}

class _VendorEarningsScreenState extends ConsumerState<VendorEarningsScreen> {
  bool _isRequesting = false;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userModelProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Earnings & Payouts', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: colorScheme.onSurface),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/vendor');
            }
          },
        ),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('User not found'));

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEarningsHero(user, colorScheme, isLight),
                const SizedBox(height: 40),
                _SectionTitle(title: 'WITHDRAWAL REQUEST', color: colorScheme.primary),
                const SizedBox(height: 16),
                _buildWithdrawalCard(user, colorScheme, isLight),
                const SizedBox(height: 40),
                _SectionTitle(title: 'PAYOUT HISTORY', color: colorScheme.primary),
                const SizedBox(height: 16),
                _buildPayoutHistory(user.uid, colorScheme, isLight),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildEarningsHero(dynamic user, ColorScheme colorScheme, bool isLight) {
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
        boxShadow: [BoxShadow(color: colorScheme.primary.withValues(alpha: 0.1), blurRadius: 40)],
      ),
      child: Column(
        children: [
          Text(
            'AVAILABLE BALANCE',
            style: TextStyle(color: colorScheme.primary.withValues(alpha: 0.6), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2),
          ),
          const SizedBox(height: 12),
          Text(
            'Rs ${NumberFormat('#,###').format(user.totalEarnings)}',
            style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: -1),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _HeroStat(label: 'Total Sales', value: '142', color: Colors.white), // Simplified
              Container(width: 1, height: 30, color: Colors.white10, margin: const EdgeInsets.symmetric(horizontal: 24)),
              _HeroStat(label: 'Withdrawals', value: 'Rs 12k', color: Colors.white), // Simplified
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalCard(dynamic user, ColorScheme colorScheme, bool isLight) {
    final hasBankDetails = user.bankDetails != null && user.bankDetails!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: colorScheme.outline.withValues(alpha: isLight ? 0.5 : 0.05)),
      ),
      child: Column(
        children: [
          if (!hasBankDetails)
            _WarningMessage(
              message: 'Add your bank details in profile to request payouts.',
              onTap: () => context.push('/vendor/profile'),
            )
          else ...[
            Row(
              children: [
                Icon(Icons.account_balance_rounded, color: colorScheme.primary, size: 20),
                const SizedBox(width: 12),
                Text(
                  user.bankDetails!['bankName'] ?? 'Digital Account',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: (_isRequesting || user.totalEarnings < 500) ? null : () => _handleWithdrawal(user.uid, user.totalEarnings),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isRequesting 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('WITHDRAW ALL (RS ${user.totalEarnings.toInt()})', style: const TextStyle(fontWeight: FontWeight.w900)),
            ),
            const SizedBox(height: 12),
            Text(
              'Minimum withdrawal: Rs 500',
              style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.3), fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPayoutHistory(String vendorId, ColorScheme colorScheme, bool isLight) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('payouts')
          .where('userId', isEqualTo: vendorId)
          .orderBy('requestedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final payouts = snapshot.data!.docs;

        if (payouts.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Text('No history found', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.3))),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: payouts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final data = payouts[index].data() as Map<String, dynamic>;
            final status = data['status'] ?? 'pending';
            final amount = data['amount'] ?? 0.0;
            final date = (data['requestedAt'] as Timestamp?)?.toDate() ?? DateTime.now();

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.outline.withValues(alpha: 0.05)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (status == 'completed' ? AppColors.success : AppColors.warning).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      status == 'completed' ? Icons.check_circle_rounded : Icons.pending_rounded,
                      color: status == 'completed' ? AppColors.success : AppColors.warning,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rs ${amount.toInt()}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                        Text(DateFormat('MMM dd • hh:mm a').format(date), style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.3), fontSize: 11)),
                      ],
                    ),
                  ),
                  _StatusTag(status: status),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleWithdrawal(String uid, double amount) async {
    setState(() => _isRequesting = true);
    try {
      await ref.read(vendorServiceProvider).requestWithdrawal(uid, amount, 'vendor');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Withdrawal request sent!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isRequesting = false);
    }
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _HeroStat({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Column(children: [Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 2), Text(label, style: TextStyle(color: color.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.w600))]);
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionTitle({required this.title, required this.color});
  @override
  Widget build(BuildContext context) => Row(children: [const SizedBox(width: 4), Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color.withValues(alpha: 0.6), letterSpacing: 2))]);
}

class _WarningMessage extends StatelessWidget {
  final String message;
  final VoidCallback onTap;
  const _WarningMessage({required this.message, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, child: Row(children: [const Icon(Icons.error_outline_rounded, color: AppColors.warning, size: 20), const SizedBox(width: 12), Expanded(child: Text(message, style: const TextStyle(color: AppColors.warning, fontSize: 13, fontWeight: FontWeight.w600)))]));
}

class _StatusTag extends StatelessWidget {
  final String status;
  const _StatusTag({required this.status});
  @override
  Widget build(BuildContext context) {
    final color = status == 'completed' ? AppColors.success : AppColors.warning;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)));
  }
}
