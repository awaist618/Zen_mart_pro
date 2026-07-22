import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../theme/app_colors.dart';

class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userModelProvider).asData?.value;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final docs = user.documents ?? {};

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('My Documents', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Keep your documents up to date to maintain your verified status.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 24),
          _DocumentCard(
            title: 'CNIC Front',
            status: docs['cnic_front'] ?? 'not_uploaded',
            onUpload: () => _handleUpload(context, ref, user.uid, 'cnic_front'),
          ),
          _DocumentCard(
            title: 'CNIC Back',
            status: docs['cnic_back'] ?? 'not_uploaded',
            onUpload: () => _handleUpload(context, ref, user.uid, 'cnic_back'),
          ),
          _DocumentCard(
            title: 'Driving License',
            status: docs['license'] ?? 'not_uploaded',
            onUpload: () => _handleUpload(context, ref, user.uid, 'license'),
          ),
          _DocumentCard(
            title: 'Vehicle Registration',
            status: docs['registration'] ?? 'not_uploaded',
            onUpload: () => _handleUpload(context, ref, user.uid, 'registration'),
          ),
          _DocumentCard(
            title: 'Insurance (Optional)',
            status: docs['insurance'] ?? 'not_uploaded',
            onUpload: () => _handleUpload(context, ref, user.uid, 'insurance'),
          ),
        ],
      ),
    );
  }

  void _handleUpload(BuildContext context, WidgetRef ref, String uid, String type) async {
    final url = await ref.read(uploadServiceProvider).pickAndUploadImage(
      context: context,
      folder: 'rider_documents',
    );

    if (url != null) {
      await ref.read(riderServiceProvider).uploadDocument(uid, type, url);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document uploaded for review')),
        );
      }
    }
  }
}

class _DocumentCard extends StatelessWidget {
  final String title;
  final String status;
  final VoidCallback onUpload;

  const _DocumentCard({required this.title, required this.status, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: status == 'rejected' || status == 'not_uploaded' ? onUpload : null,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_getStatusIcon(status), color: _getStatusColor(status), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(
                        _getStatusText(status),
                        style: TextStyle(color: _getStatusColor(status), fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                if (status == 'rejected' || status == 'not_uploaded')
                  const Icon(Icons.cloud_upload_outlined, color: Colors.blue, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'approved': return Icons.verified_user_rounded;
      case 'pending': return Icons.hourglass_empty_rounded;
      case 'rejected': return Icons.error_outline_rounded;
      default: return Icons.upload_file_rounded;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved': return Colors.green;
      case 'pending': return Colors.orange;
      case 'rejected': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'approved': return 'Approved';
      case 'pending': return 'Pending Review';
      case 'rejected': return 'Rejected - Tap to Re-upload';
      default: return 'Not Uploaded';
    }
  }
}
