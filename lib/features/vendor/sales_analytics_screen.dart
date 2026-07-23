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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Sales Analytics', style: TextStyle(fontWeight: FontWeight.w900)),
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: colorScheme.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: TabBar(
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurface.withOpacity(0.4),
            indicatorColor: colorScheme.primary,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: Colors.transparent,
            labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            tabs: const [
              Tab(text: 'DAILY'),
              Tab(text: 'WEEKLY'),
              Tab(text: 'MONTHLY'),
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

class _SalesTabContent extends ConsumerWidget {
  final String period;
  const _SalesTabContent({required this.period});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'PERFORMANCE SUMMARY', color: colorScheme.primary),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.4,
            children: [
              _AnalyticsStatCard(title: 'Revenue', value: 'Rs 18.4k', icon: Icons.payments_rounded, color: AppColors.success, colorScheme: colorScheme, isLight: isLight),
              _AnalyticsStatCard(title: 'Orders', value: '24', icon: Icons.shopping_bag_rounded, color: AppColors.info, colorScheme: colorScheme, isLight: isLight),
              _AnalyticsStatCard(title: 'Items Sold', value: '156', icon: Icons.inventory_2_rounded, color: Colors.orange, colorScheme: colorScheme, isLight: isLight),
              _AnalyticsStatCard(title: 'Avg Value', value: 'Rs 768', icon: Icons.insights_rounded, color: Colors.purple, colorScheme: colorScheme, isLight: isLight),
            ],
          ),
          
          const SizedBox(height: 40),
          _SectionHeader(title: 'REVENUE TREND', color: colorScheme.primary),
          const SizedBox(height: 16),
          
          Container(
            height: 260,
            padding: const EdgeInsets.fromLTRB(10, 24, 24, 20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: colorScheme.outline.withOpacity(isLight ? 0.5 : 0.05)),
              boxShadow: isLight ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20)] : null,
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true, 
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(color: colorScheme.outline.withOpacity(0.05), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (v, meta) => Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('${v.toInt()}', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (v, meta) => Text('${v.toInt()}k', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
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
                    color: colorScheme.primary,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true, 
                      gradient: LinearGradient(
                        colors: [colorScheme.primary.withOpacity(0.2), colorScheme.primary.withOpacity(0)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),
          _SectionHeader(title: 'BEST SELLING PRODUCTS', color: colorScheme.primary),
          const SizedBox(height: 16),
          _TopProductTile(name: 'Fresh Milk 1L', sales: '45 sales', revenue: 'Rs 9,000', colorScheme: colorScheme, isLight: isLight),
          _TopProductTile(name: 'Bread Wheat Large', sales: '32 sales', revenue: 'Rs 4,800', colorScheme: colorScheme, isLight: isLight),
          _TopProductTile(name: 'Eggs (Dozen)', sales: '28 sales', revenue: 'Rs 8,400', colorScheme: colorScheme, isLight: isLight),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionHeader({required this.title, required this.color});
  @override
  Widget build(BuildContext context) => Row(children: [const SizedBox(width: 4), Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color.withOpacity(0.6), letterSpacing: 2))]);
}

class _AnalyticsStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final ColorScheme colorScheme;
  final bool isLight;

  const _AnalyticsStatCard({required this.title, required this.value, required this.icon, required this.color, required this.colorScheme, required this.isLight});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.outline.withOpacity(isLight ? 0.5 : 0.05)),
        boxShadow: isLight ? [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: colorScheme.onSurface)),
          Text(title.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: colorScheme.onSurface.withOpacity(0.4), letterSpacing: 0.5)),
        ],
      ),
    );
  }
}

class _TopProductTile extends StatelessWidget {
  final String name;
  final String sales;
  final String revenue;
  final ColorScheme colorScheme;
  final bool isLight;

  const _TopProductTile({required this.name, required this.sales, required this.revenue, required this.colorScheme, required this.isLight});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface, 
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outline.withOpacity(isLight ? 0.5 : 0.05)),
        boxShadow: isLight ? [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)] : null,
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
            child: Icon(Icons.inventory_2_rounded, color: colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 2),
                Text(sales.toUpperCase(), style: TextStyle(color: colorScheme.onSurface.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              ],
            ),
          ),
          Text(revenue, style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.success, fontSize: 14)),
        ],
      ),
    );
  }
}
