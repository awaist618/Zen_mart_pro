import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../core/providers.dart';
import '../../models/user_model.dart';
import '../../models/support_ticket_model.dart';
import '../../services/support_service.dart';

class SupportListScreen extends ConsumerStatefulWidget {
  const SupportListScreen({super.key});

  @override
  ConsumerState<SupportListScreen> createState() => _SupportListScreenState();
}

class _SupportListScreenState extends ConsumerState<SupportListScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  TicketStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Support Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          _buildStatsOverview(),
          _buildFilters(),
          Expanded(child: _buildTicketList()),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    return StreamBuilder<List<SupportTicketModel>>(
      stream: ref.watch(supportServiceProvider).getAllTickets(),
      builder: (context, snapshot) {
        final tickets = snapshot.data ?? [];
        final openCount = tickets.where((t) => t.status == TicketStatus.open).length;
        final resolvedToday = tickets.where((t) => t.status == TicketStatus.resolved && _isToday(t.updatedAt)).length;
        final highPriority = tickets.where((t) => t.priority == TicketPriority.high && t.status != TicketStatus.closed).length;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              _StatCard(label: 'Open', count: openCount, color: Colors.blue),
              _StatCard(label: 'High Priority', count: highPriority, color: Colors.red),
              _StatCard(label: 'Resolved Today', count: resolvedToday, color: Colors.green),
              _StatCard(label: 'Total', count: tickets.length, color: Colors.grey),
            ],
          ),
        );
      },
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Widget _buildFilters() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _FilterChip(label: 'All', isSelected: _selectedFilter == 'All', onTap: () => setState(() => _selectedFilter = 'All')),
          _FilterChip(label: 'Customer', isSelected: _selectedFilter == 'Customer', onTap: () => setState(() => _selectedFilter = 'Customer')),
          _FilterChip(label: 'Vendor', isSelected: _selectedFilter == 'Vendor', onTap: () => setState(() => _selectedFilter = 'Vendor')),
          _FilterChip(label: 'Rider', isSelected: _selectedFilter == 'Rider', onTap: () => setState(() => _selectedFilter = 'Rider')),
        ],
      ),
    );
  }

  Widget _buildTicketList() {
    return StreamBuilder<List<SupportTicketModel>>(
      stream: ref.watch(supportServiceProvider).getAllTickets(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        var tickets = snapshot.data ?? [];

        // Apply filters
        if (_selectedFilter != 'All') {
          tickets = tickets.where((t) => t.userRole.name.toLowerCase() == _selectedFilter.toLowerCase()).toList();
        }

        if (tickets.isEmpty) {
          return const Center(child: Text('No tickets matching filters.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: tickets.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final ticket = tickets[index];
            return _AdminTicketCard(ticket: ticket);
          },
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatCard({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(count.toString(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _AdminTicketCard extends ConsumerWidget {
  final SupportTicketModel ticket;
  const _AdminTicketCard({required this.ticket});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isResolved = ticket.status == TicketStatus.resolved || ticket.status == TicketStatus.closed;

    return Container(
      decoration: BoxDecoration(
        color: isResolved ? Colors.grey[50] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ticket.priority == TicketPriority.high ? Colors.red.withOpacity(0.2) : Colors.transparent,
          width: 1,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => context.push('/support/ticket-chat/${ticket.id}'),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getRoleColor(ticket.userRole).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ticket.userRole.name.toUpperCase(),
                        style: TextStyle(
                          color: _getRoleColor(ticket.userRole),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (ticket.priority == TicketPriority.high)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.flash_on_rounded, color: Colors.red, size: 10),
                            SizedBox(width: 4),
                            Text('URGENT', style: TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    const Spacer(),
                    Text(
                      '#${ticket.id.substring(0, 5).toUpperCase()}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  ticket.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isResolved ? Colors.grey[600] : Colors.black.withOpacity(0.87),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'From: ${ticket.userName}',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.grey[700]),
                ),
                const SizedBox(height: 12),
                Text(
                  ticket.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _StatusBadge(status: ticket.status),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        ticket.category,
                        style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Spacer(),
                    if (ticket.status == TicketStatus.open || ticket.status == TicketStatus.inProgress)
                      TextButton(
                        onPressed: () {
                          ref.read(supportServiceProvider).updateTicketStatus(ticket.id, TicketStatus.resolved);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Ticket marked as Resolved')),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          backgroundColor: Colors.green.withOpacity(0.05),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Resolve', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                const Divider(height: 32),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 6),
                    Text(
                      'Last updated ${DateFormat('MMM d, hh:mm a').format(ticket.updatedAt)}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.customer: return AppColors.customer;
      case UserRole.vendor: return AppColors.vendor;
      case UserRole.rider: return AppColors.rider;
      default: return AppColors.primary;
    }
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
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(status.name.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
