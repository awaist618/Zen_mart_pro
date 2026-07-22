import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import './widgets/vendor_bottom_nav.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/providers.dart';
import '../../models/order_model.dart';
import '../../theme/app_colors.dart';

class VendorOrdersScreen extends ConsumerStatefulWidget {
  const VendorOrdersScreen({super.key});

  @override
  ConsumerState<VendorOrdersScreen> createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends ConsumerState<VendorOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  final List<String> _tabLabels = [
    'Pending',
    'Accepted',
    'Preparing',
    'Ready',
    'Completed',
    'Cancelled'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabLabels.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  OrderStatus? _getStatusForTab(int index) {
    switch (index) {
      case 0: return OrderStatus.pending;
      case 1: return OrderStatus.accepted;
      case 2: return OrderStatus.preparing;
      case 3: return OrderStatus.confirmed;
      case 4: return OrderStatus.delivered;
      case 5: return OrderStatus.cancelled;
      default: return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(allShopOrdersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Order Management', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                    decoration: const InputDecoration(
                      hintText: 'Search Order ID or Name...',
                      border: InputBorder.none,
                      icon: Icon(Icons.search, size: 20),
                    ),
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: const Color(0xFF8B5CF6),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF8B5CF6),
                indicatorWeight: 3,
                tabs: _tabLabels.map((label) => Tab(text: label)).toList(),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(_tabLabels.length, (index) {
          return ordersAsync.when(
            data: (orders) {
              final tabStatus = _getStatusForTab(index);
              final filtered = orders.where((order) {
                final matchesStatus = order.status == tabStatus;
                final matchesSearch = order.id.toLowerCase().contains(_searchQuery) || 
                                     order.customerName.toLowerCase().contains(_searchQuery);
                return matchesStatus && matchesSearch;
              }).toList();

              if (filtered.isEmpty) {
                return _EmptyState(label: _tabLabels[index]);
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) => _OrderCard(order: filtered[index]),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
          );
        }),
      ),
      bottomNavigationBar: const VendorBottomNav(currentIndex: 1),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String label;
  const _EmptyState({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('No $label orders found', style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: const Color(0xFF8B5CF6),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${order.id.substring(0, 8).toUpperCase()}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              _buildStatusBadge(order.status),
            ],
          ),
          const Divider(height: 24),
          Text(
            order.customerName,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            '${order.items.length} items • Rs ${order.totalAmount}',
            style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMM dd, h:mm a').format(order.createdAt),
                style: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 11),
              ),
              TextButton(
                onPressed: () => context.push('/vendor/order-details/${order.id}'),
                child: const Text('View Details'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color color;
    switch (status) {
      case OrderStatus.pending: color = Colors.orange; break;
      case OrderStatus.preparing: color = Colors.blue; break;
      case OrderStatus.confirmed: color = Colors.green; break;
      case OrderStatus.cancelled:
      case OrderStatus.rejected: color = Colors.red; break;
      default: color = Colors.purple;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SmallActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.black.withOpacity(0.4)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.6))),
        ],
      ),
    );
  }
}
