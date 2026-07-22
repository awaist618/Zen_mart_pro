import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../core/providers.dart';
import '../../../models/support_ticket_model.dart';
import '../../../services/support_service.dart';

class MyTicketsScreen extends ConsumerWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userModelProvider).asData?.value;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('My Tickets', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<List<SupportTicketModel>>(
        stream: ref.watch(supportServiceProvider).getUserTickets(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final tickets = snapshot.data ?? [];
          if (tickets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.confirmation_number_outlined, size: 64, color: Colors.grey.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text('No tickets found.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.push('/support/create-ticket'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Create New Ticket'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: tickets.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return _TicketCard(ticket: ticket);
            },
          );
        },
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final SupportTicketModel ticket;
  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          contentPadding: const EdgeInsets.all(20),
          title: Row(
            children: [
              Expanded(child: Text(ticket.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              _StatusBadge(status: ticket.status),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(ticket.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.category_outlined, size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(ticket.category, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  const Spacer(),
                  Text(
                    'Updated ${_formatDate(ticket.updatedAt)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  final TicketStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case TicketStatus.open: color = Colors.blue; break;
      case TicketStatus.assigned: color = Colors.purple; break;
      case TicketStatus.inProgress: color = Colors.orange; break;
      case TicketStatus.waitingForUser: color = Colors.cyan; break;
      case TicketStatus.resolved: color = Colors.green; break;
      case TicketStatus.closed: color = Colors.grey; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
