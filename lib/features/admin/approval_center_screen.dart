import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/providers.dart';
import '../../models/approval_model.dart';
import '../../theme/app_colors.dart';

class ApprovalCenterScreen extends ConsumerWidget {
  const ApprovalCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final approvalsAsync = ref.watch(pendingApprovalsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Approval Center', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: approvalsAsync.when(
        data: (approvals) {
          if (approvals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_user_rounded, size: 64, color: colorScheme.onSurface.withValues(alpha: 0.1)),
                  const SizedBox(height: 16),
                  Text('No pending requests.', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4), fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            itemCount: approvals.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) => _ApprovalListTile(approval: approvals[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _ApprovalListTile extends ConsumerWidget {
  final ApprovalModel approval;
  const _ApprovalListTile({required this.approval});

  IconData _getIcon() {
    switch (approval.type) {
      case ApprovalType.vendorRegistration: return Icons.person_add_rounded;
      case ApprovalType.riderRegistration: return Icons.directions_bike_rounded;
      case ApprovalType.shopApproval: return Icons.storefront_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(_getIcon(), color: colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      approval.applicantName,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onSurface),
                    ),
                    Text(
                      approval.type.name.replaceAll(RegExp(r'(?<!^)(?=[A-Z])'), ' ').toUpperCase(),
                      style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 10, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
              Text(
                DateFormat('MMM dd').format(approval.createdAt),
                style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.3), fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              approval.details['message'] ?? "No message provided.",
              style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 13, height: 1.4),
            ),
          ),
          const Divider(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showRejectDialog(context, ref),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    minimumSize: const Size(0, 48),
                  ),
                  child: const Text('REJECT'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(adminServiceProvider).updateApprovalStatus(approval.id, ApprovalStatus.approved);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 48),
                  ),
                  child: const Text('APPROVE'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.file_present_rounded, size: 18, color: colorScheme.primary),
              label: Text('VIEW DOCUMENTS', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)),
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Request?'),
        content: const TextField(
          decoration: InputDecoration(hintText: 'Enter rejection reason...'),
          maxLines: 2,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(adminServiceProvider).updateApprovalStatus(approval.id, ApprovalStatus.rejected);
              Navigator.pop(context);
            },
            child: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
