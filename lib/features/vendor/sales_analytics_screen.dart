import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/providers.dart';
import '../../theme/app_colors.dart';

class VendorSalesAnalyticsScreen extends ConsumerWidget {
  const VendorSalesAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Sales Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black,
          bottom: const TabBar(
            labelColor: Color(0xFF8B5CF6),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF8B5CF6),
            tabs: [
              Tab(text: 'Daily'),
              Tab(text: 'Weekly'),
              Tab(text: 'Monthly'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _SalesTabContent(period: 'Daily'),
            _SalesTabContent(period: 'Weekly'),
            _SalesTabContent(period: 'Monthly'),
          ],
        ),
      ),
    );
  }
}

class _SalesTabContent extends StatelessWidget {
  final String period;
  const _SalesTabContent({required this.period});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Performance Summary
          const Text('Performance Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.4,
            children: const [
              _AnalyticsStatCard(title: 'Revenue', value: 'Rs 18,420', icon: Icons.payments_outlined, color: Colors.green),
              _AnalyticsStatCard(title: 'Orders', value: '24', icon: Icons.shopping_bag_outlined, color: Colors.blue),
              _AnalyticsStatCard(title: 'Products Sold', value: '156', icon: Icons.inventory_2_outlined, color: Colors.orange),
              _AnalyticsStatCard(title: 'Avg Order', value: 'Rs 768', icon: Icons.analytics_outlined, color: Colors.purple),
            ],
          ),
          
          const SizedBox(height: 32),
          const Text('Revenue Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          // Chart
          Container(
            height: 240,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 2),
                      const FlSpot(2, 4.5),
                      const FlSpot(4, 3),
                      const FlSpot(6, 5),
                      const FlSpot(8, 4),
                      const FlSpot(10, 6.5),
                    ],
                    isCurved: true,
                    color: const Color(0xFF8B5CF6),
                    barWidth: 4,
                    belowBarData: BarAreaData(show: true, color: const Color(0xFF8B5CF6).withOpacity(0.1)),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
          const Text('Best Selling Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _TopProductTile(name: 'Fresh Milk 1L', sales: '45 sales', revenue: 'Rs 9,000'),
          _TopProductTile(name: 'Bread Wheat Large', sales: '32 sales', revenue: 'Rs 4,800'),
          _TopProductTile(name: 'Eggs (Dozen)', sales: '28 sales', revenue: 'Rs 8,400'),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _AnalyticsStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _AnalyticsStatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _TopProductTile extends StatelessWidget {
  final String name;
  final String sales;
  final String revenue;

  const _TopProductTile({required this.name, required this.sales, required this.revenue});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF8B5CF6)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(sales, style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 12)),
              ],
            ),
          ),
          Text(revenue, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        ],
      ),
    );
  }
}
