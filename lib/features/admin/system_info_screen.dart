import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../theme/app_colors.dart';

class SystemInfoScreen extends ConsumerWidget {
  const SystemInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopsCount = ref.watch(totalShopsCountProvider).asData?.value ?? 0;
    final ridersCount = ref.watch(totalRidersCountProvider).asData?.value ?? 0;
    final customersCount = ref.watch(totalCustomersCountProvider).asData?.value ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('System Information', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildInfoGroup('PLATFORM STATISTICS', [
            _InfoRow(label: 'Total Customers', value: customersCount.toString()),
            _InfoRow(label: 'Total Registered Shops', value: shopsCount.toString()),
            _InfoRow(label: 'Active Delivery Riders', value: ridersCount.toString()),
          ]),
          const SizedBox(height: 24),
          _buildInfoGroup('APPLICATION DETAILS', [
            _InfoRow(label: 'App Name', value: 'Zen Mart Pro'),
            _InfoRow(label: 'Environment', value: 'Production'),
            _InfoRow(label: 'Version', value: '1.0.2'),
            _InfoRow(label: 'Build Number', value: '124'),
          ]),
          const SizedBox(height: 24),
          _buildInfoGroup('SERVER STATUS', [
            _InfoRow(label: 'Cloud Firestore', value: 'Operational', color: Colors.green),
            _InfoRow(label: 'Firebase Auth', value: 'Operational', color: Colors.green),
            _InfoRow(label: 'Storage Server', value: 'Connected', color: Colors.green),
            _InfoRow(label: 'Push Notification Service', value: 'Active', color: Colors.green),
          ]),
        ],
      ),
    );
  }

  Widget _buildInfoGroup(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 12),
          child: Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _InfoRow({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
        ],
      ),
    );
  }
}
