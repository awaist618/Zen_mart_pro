import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../theme/app_colors.dart';

class SystemInfoScreen extends ConsumerWidget {
  const SystemInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopsCount = ref.watch(totalShopsCountProvider).asData?.value ?? 0;
    final ridersCount = ref.watch(totalRidersCountProvider).asData?.value ?? 0;
    final customersCount = ref.watch(totalCustomersCountProvider).asData?.value ?? 0;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('System Information', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildInfoGroup(context, 'PLATFORM STATISTICS', [
            _InfoRow(label: 'Total Customers', value: customersCount.toString()),
            _InfoRow(label: 'Total Registered Shops', value: shopsCount.toString()),
            _InfoRow(label: 'Active Delivery Riders', value: ridersCount.toString()),
          ]),
          const SizedBox(height: 32),
          _buildInfoGroup(context, 'APPLICATION DETAILS', [
            _InfoRow(label: 'App Name', value: 'Zen Mart Pro'),
            _InfoRow(label: 'Environment', value: 'Production'),
            _InfoRow(label: 'Version', value: '1.0.2'),
            _InfoRow(label: 'Build Number', value: '124'),
          ]),
          const SizedBox(height: 32),
          _buildInfoGroup(context, 'SERVER STATUS', [
            _InfoRow(label: 'Cloud Firestore', value: 'Operational', color: const Color(0xFF10B981)),
            _InfoRow(label: 'Firebase Auth', value: 'Operational', color: const Color(0xFF10B981)),
            _InfoRow(label: 'Storage Server', value: 'Connected', color: const Color(0xFF10B981)),
            _InfoRow(label: 'Push Notification Service', value: 'Active', color: const Color(0xFF10B981)),
          ]),
        ],
      ),
    );
  }

  Widget _buildInfoGroup(BuildContext context, String title, List<Widget> children) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 12),
          child: Text(title, style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.3), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surface, 
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
          ),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 14, fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: color ?? colorScheme.onSurface)),
        ],
      ),
    );
  }
}
