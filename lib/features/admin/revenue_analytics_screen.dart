import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/providers.dart';
import '../../theme/app_colors.dart';

class RevenueAnalyticsScreen extends ConsumerWidget {
  const RevenueAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyAsync = ref.watch(dailyRevenueProvider);
    final weeklyAsync = ref.watch(weeklyRevenueProvider);
    final monthlyAsync = ref.watch(monthlyRevenueProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Revenue Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Revenue Grid
            Row(
              children: [
                Expanded(
                  child: _RevenueStatCard(
                    title: 'Today',
                    amount: dailyAsync.asData?.value ?? 0.0,
                    color: AppColors.accent,
                    isLoading: dailyAsync.isLoading,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _RevenueStatCard(
                    title: 'This Week',
                    amount: weeklyAsync.asData?.value ?? 0.0,
                    color: Colors.indigo,
                    isLoading: weeklyAsync.isLoading,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _RevenueStatCard(
              title: 'This Month',
              amount: monthlyAsync.asData?.value ?? 0.0,
              color: AppColors.primary,
              isLarge: true,
              isLoading: monthlyAsync.isLoading,
            ),
            
            const SizedBox(height: 32),
            const Text('Revenue Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // Chart Container
            Container(
              height: 300,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15)],
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 3),
                        const FlSpot(2.6, 2),
                        const FlSpot(4.9, 5),
                        const FlSpot(6.8, 3.1),
                        const FlSpot(8, 4),
                        const FlSpot(9.5, 3),
                        const FlSpot(11, 4),
                      ],
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            const Text('Detailed Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            _BreakdownTile(title: 'Shop Revenue', icon: Icons.storefront_rounded, color: Colors.blue),
            _BreakdownTile(title: 'Vendor Payouts', icon: Icons.person_pin_rounded, color: Colors.purple),
            _BreakdownTile(title: 'Order Fees', icon: Icons.receipt_long_rounded, color: Colors.green),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _RevenueStatCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final bool isLarge;
  final bool isLoading;

  const _RevenueStatCard({
    required this.title,
    required this.amount,
    required this.color,
    this.isLarge = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isLarge ? 24 : 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
          const SizedBox(height: 4),
          isLoading 
            ? const SizedBox(height: 28, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(
                'Rs ${NumberFormat.compact().format(amount)}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isLarge ? 28 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
        ],
      ),
    );
  }
}

class _BreakdownTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _BreakdownTile({required this.title, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
        ],
      ),
    );
  }
}
