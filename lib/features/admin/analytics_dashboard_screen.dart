import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/providers.dart';
import '../../theme/app_colors.dart';
import '../../services/pdf_service.dart';

class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Platform Analytics', style: TextStyle(fontWeight: FontWeight.w900)),
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: colorScheme.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: TabBar(
            isScrollable: true,
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.4),
            indicatorColor: colorScheme.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            tabs: const [
              Tab(text: 'OVERVIEW'),
              Tab(text: 'FINANCIALS'),
              Tab(text: 'DISTRIBUTION'),
              Tab(text: 'REPORTS'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
              onPressed: () {
                final shops = ref.read(totalShopsCountProvider).asData?.value ?? 0;
                final riders = ref.read(totalRidersCountProvider).asData?.value ?? 0;
                final customers = ref.read(totalCustomersCountProvider).asData?.value ?? 0;
                final revenue = ref.read(monthlyRevenueProvider).asData?.value ?? 0.0;
                final pending = ref.read(pendingOrdersCountProvider).asData?.value ?? 0;

                PdfService.generatePlatformReport(
                  totalShops: shops,
                  totalRiders: riders,
                  totalCustomers: customers,
                  monthlyRevenue: revenue,
                  pendingOrders: pending,
                );
              },
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            _OverviewTab(),
            _FinancialsTab(),
            _UserShopTab(),
            _ReportsTab(),
          ],
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context, String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export as $type'),
        content: Text('Do you want to generate a $type report for the current month?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$type Report generation started...')),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingOrders = ref.watch(pendingOrdersCountProvider).asData?.value ?? 0;
    
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _SectionHeader(title: 'Growth Overview'),
        const SizedBox(height: 16),
        _buildMainChart(context),
        const SizedBox(height: 32),
        const _SectionHeader(title: 'Key Metrics'),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.4,
          children: [
            _StatCard(title: 'Order Growth', value: '+24%', icon: Icons.trending_up, color: Colors.green),
            _StatCard(title: 'New Users', value: '142', icon: Icons.person_add_alt_1, color: Colors.blue),
            _StatCard(title: 'Pending', value: pendingOrders.toString(), icon: Icons.pending_actions, color: Colors.orange),
            _StatCard(title: 'Conversion', value: '3.8%', icon: Icons.ads_click, color: Colors.purple),
          ],
        ),
      ],
    );
  }

  Widget _buildMainChart(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 240,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [const FlSpot(0, 3), const FlSpot(2, 5), const FlSpot(4, 3.5), const FlSpot(6, 6), const FlSpot(8, 4), const FlSpot(10, 7)],
              isCurved: true,
              color: theme.colorScheme.primary,
              barWidth: 4,
              belowBarData: BarAreaData(show: true, color: theme.colorScheme.primary.withValues(alpha: 0.1)),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinancialsTab extends ConsumerWidget {
  const _FinancialsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daily = ref.watch(dailyRevenueProvider).asData?.value ?? 0.0;
    final weekly = ref.watch(weeklyRevenueProvider).asData?.value ?? 0.0;
    final monthly = ref.watch(monthlyRevenueProvider).asData?.value ?? 0.0;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _RevenueRow(title: 'Daily Revenue', amount: daily, color: Colors.teal),
        _RevenueRow(title: 'Weekly Revenue', amount: weekly, color: Colors.indigo),
        _RevenueRow(title: 'Monthly Revenue', amount: monthly, color: const Color(0xFFC9A27E)),
        const SizedBox(height: 32),
        const _SectionHeader(title: 'Revenue Stream Breakdown'),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(value: 40, color: Colors.blue, title: 'Product Sales', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontSize: 10)),
                PieChartSectionData(value: 30, color: Colors.purple, title: 'Commission', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontSize: 10)),
                PieChartSectionData(value: 20, color: Colors.orange, title: 'Delivery', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontSize: 10)),
                PieChartSectionData(value: 10, color: Colors.teal, title: 'Other', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontSize: 10)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _UserShopTab extends ConsumerWidget {
  const _UserShopTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final vendors = ref.watch(totalRidersCountProvider).asData?.value ?? 0; // Using riders as proxy for now
    final customers = ref.watch(totalCustomersCountProvider).asData?.value ?? 0;
    final shops = ref.watch(totalShopsCountProvider).asData?.value ?? 0;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _SectionHeader(title: 'Distribution'),
        const SizedBox(height: 16),
        Container(
          height: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface, 
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
          ),
          child: BarChart(
            BarChartData(
              barGroups: [
                BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: vendors.toDouble(), color: const Color(0xFF6366F1), width: 20)]),
                BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: customers.toDouble() / 10, color: const Color(0xFF10B981), width: 20)]),
                BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: shops.toDouble(), color: const Color(0xFF38BDF8), width: 20)]),
              ],
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final style = TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.bold);
                      switch (value.toInt()) {
                        case 0: return Text('Vendors', style: style);
                        case 1: return Text('Users', style: style);
                        case 2: return Text('Shops', style: style);
                        default: return const Text('');
                      }
                    },
                  ),
                ),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: false),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReportsTab extends StatelessWidget {
  const _ReportsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _SectionHeader(title: 'Generated Reports'),
        const SizedBox(height: 16),
        _buildReportItem(context, 'Daily Performance Report', 'Generated at 08:00 AM', Icons.today),
        _buildReportItem(context, 'Weekly Financial Summary', 'Week 28 - 2026', Icons.date_range),
        _buildReportItem(context, 'Monthly Platform Audit', 'June 2026', Icons.calendar_month),
        _buildReportItem(context, 'Annual Tax & Revenue Statement', 'Year 2025-26', Icons.analytics),
      ],
    );
  }

  Widget _buildReportItem(BuildContext context, String title, String subtitle, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface, 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: colorScheme.primary, size: 22),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colorScheme.onSurface)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.5))),
        trailing: Icon(Icons.file_download_outlined, color: colorScheme.onSurface.withValues(alpha: 0.3)),
        onTap: () {},
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: colorScheme.onSurface, letterSpacing: 0.5));
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface, 
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 16),
          ),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: colorScheme.onSurface)),
          const SizedBox(height: 2),
          Text(title, style: TextStyle(fontSize: 10, color: colorScheme.onSurface.withValues(alpha: 0.4), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _RevenueRow extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;

  const _RevenueRow({required this.title, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface, 
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Icons.wallet, color: color),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              const SizedBox(height: 4),
              Text('Rs ${NumberFormat('#,###').format(amount)}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: colorScheme.onSurface)),
            ],
          ),
        ],
      ),
    );
  }
}
