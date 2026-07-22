import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/providers.dart';
import '../../models/approval_model.dart';
import '../../theme/app_colors.dart';

class ApprovalCenterScreen extends ConsumerWidget {
  const ApprovalCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final approvalsAsync = ref.watch(pendingApprovalsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Approval Center', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: approvalsAsync.when(
        data: (approvals) {
          if (approvals.isEmpty) {
            return const Center(child: Text('No pending approval requests.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(_getIcon(), color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      approval.applicantName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      approval.type.name.replaceAll(RegExp(r'(?<!^)(?=[A-Z])'), ' ').toUpperCase(),
                      style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Text(
                DateFormat('MMM dd').format(approval.createdAt),
                style: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Details: ${approval.details['message'] ?? "No message provided."}',
            style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 13),
          ),
          const Divider(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showRejectDialog(context, ref),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(adminServiceProvider).updateApprovalStatus(approval.id, ApprovalStatus.approved);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Approve'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.file_present_rounded, size: 18),
              label: const Text('View Documents'),
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
