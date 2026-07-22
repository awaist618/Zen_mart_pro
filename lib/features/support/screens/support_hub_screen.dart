import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../core/providers.dart';
import '../../../models/user_model.dart';
import '../../../models/support_ticket_model.dart';
import '../../../services/support_service.dart';

class SupportHubScreen extends ConsumerWidget {
  const SupportHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userModelProvider).asData?.value;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Help & Support', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(user),
            const SizedBox(height: 24),
            const Text('Need help with something?', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildActionGrid(context, user.role),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('My Tickets', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => context.push('/support/tickets'),
                  child: const Text('View All'),
                ),
              ],
            ),
            _buildRecentTickets(ref, user.uid),
            const SizedBox(height: 32),
            const Text('FAQs', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildFAQList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/support/create-ticket'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('New Ticket'),
      ),
    );
  }

  Widget _buildWelcomeCard(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hi ${user.name}!', 
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('How can we help you today?', 
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          const Icon(Icons.support_agent_rounded, size: 64, color: Colors.white24),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context, UserRole role) {
    final categories = _getCategoriesForRole(role);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: categories.length > 4 ? 4 : categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return InkWell(
          onTap: () => context.push('/support/create-ticket', extra: category),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_getIconForCategory(category), color: AppColors.primary, size: 28),
                const SizedBox(height: 8),
                Text(category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
        );
      },
    );
  }

  List<String> _getCategoriesForRole(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return ['Order Issue', 'Payment', 'Refund', 'Delivery', 'Product Quality', 'Technical', 'Other'];
      case UserRole.vendor:
        return ['Shop Verification', 'Product Approval', 'Payment', 'Withdrawal', 'Technical', 'Customer Complaint', 'Other'];
      case UserRole.rider:
        return ['Delivery Problem', 'Wrong Address', 'Customer Not Available', 'Vehicle Issue', 'Earnings', 'Withdrawal', 'Technical'];
      default:
        return ['General Support', 'Technical Issue', 'Other'];
    }
  }

  IconData _getIconForCategory(String category) {
    if (category.contains('Order')) return Icons.shopping_bag_outlined;
    if (category.contains('Payment') || category.contains('Earnings')) return Icons.account_balance_wallet_outlined;
    if (category.contains('Delivery')) return Icons.local_shipping_outlined;
    if (category.contains('Technical')) return Icons.settings_outlined;
    if (category.contains('Withdrawal')) return Icons.payments_outlined;
    return Icons.help_outline;
  }

  Widget _buildRecentTickets(WidgetRef ref, String userId) {
    return StreamBuilder<List<SupportTicketModel>>(
      stream: ref.watch(supportServiceProvider).getUserTickets(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
        }
        final tickets = snapshot.data ?? [];
        if (tickets.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('No active tickets found.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          );
        }
        return Column(
          children: tickets.take(3).map((ticket) => _TicketCard(ticket: ticket)).toList(),
        );
      },
    );
  }

  Widget _buildFAQList() {
    return Column(
      children: [
        _FAQTile(question: 'How to track my order?', answer: 'Go to My Orders and tap on the track button.'),
        _FAQTile(question: 'How to request a refund?', answer: 'You can request a refund within 24 hours of delivery.'),
        _FAQTile(question: 'How to update my profile?', answer: 'Go to Profile settings to update your information.'),
      ],
    );
  }
}

class _TicketCard extends StatelessWidget {
  final SupportTicketModel ticket;
  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: ListTile(
          onTap: () => context.push('/support/ticket-chat/${ticket.id}'),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Text(ticket.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(ticket.category, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(ticket.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              ticket.status.name.toUpperCase(),
              style: TextStyle(color: _getStatusColor(ticket.status), fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.open: return Colors.blue;
      case TicketStatus.inProgress: return Colors.orange;
      case TicketStatus.resolved: return Colors.green;
      case TicketStatus.closed: return Colors.grey;
      default: return Colors.blue;
    }
  }
}

class _FAQTile extends StatelessWidget {
  final String question;
  final String answer;
  const _FAQTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(answer, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
