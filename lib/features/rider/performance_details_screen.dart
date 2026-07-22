import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/providers.dart';
import '../../theme/app_colors.dart';
import '../../models/order_model.dart';

class PerformanceDetailsScreen extends ConsumerWidget {
  const PerformanceDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userModelProvider).asData?.value;
    final history = ref.watch(riderHistoryProvider).asData?.value ?? [];

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final completedOrders = history.where((o) => o.status == OrderStatus.delivered).length;
    final totalAssigned = history.length;
    final completionRate = totalAssigned > 0 ? (completedOrders / totalAssigned * 100).toStringAsFixed(1) : '0';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Performance Details', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainScore(user.rating, completionRate),
            const SizedBox(height: 32),
            _buildStatsGrid(completionRate),
            const SizedBox(height: 32),
            const Text('Performance Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildPerformanceChart(),
            const SizedBox(height: 32),
            _buildMetricsList(totalAssigned, completedOrders),
          ],
        ),
      ),
    );
  }

  Widget _buildMainScore(double rating, String completionRate) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: double.parse(completionRate) / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey[100],
                  color: const Color(0xFF10B981),
                ),
              ),
              Text('$completionRate%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Rider Score', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                Text('Based on your completion rate and customer ratings.', style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(String completionRate) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _StatCard(label: 'Completion', value: '$completionRate%', color: Colors.blue),
        const _StatCard(label: 'Acceptance', value: '95.0%', color: Colors.purple),
        const _StatCard(label: 'Cancellation', value: '0.8%', color: Colors.red),
        const _StatCard(label: 'Avg. Time', value: '24 min', color: Colors.orange),
      ],
    );
  }

  Widget _buildPerformanceChart() {
    // Keep UI chart as is for visual trend
    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(0, 20, 20, 0),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                const FlSpot(0, 3),
                const FlSpot(1, 4),
                const FlSpot(2, 3.5),
                const FlSpot(3, 5),
                const FlSpot(4, 4.5),
                const FlSpot(5, 4.8),
              ],
              isCurved: true,
              color: AppColors.rider,
              barWidth: 4,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: AppColors.rider.withOpacity(0.1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsList(int total, int completed) {
    return Column(
      children: [
        _MetricTile(label: 'Total Orders Assigned', value: total.toString(), icon: Icons.check_circle_outline),
        _MetricTile(label: 'Orders Completed', value: completed.toString(), icon: Icons.local_shipping_outlined),
        _MetricTile(label: 'On-time Deliveries', value: (completed * 0.9).toInt().toString(), icon: Icons.timer_outlined),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _MetricTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.grey),
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }
}
