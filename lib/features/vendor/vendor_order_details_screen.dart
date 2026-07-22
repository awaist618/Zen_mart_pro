import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/providers.dart';
import '../../models/order_model.dart';
import '../../services/pdf_service.dart';

class VendorOrderDetailsScreen extends ConsumerWidget {
  final String orderId;
  const VendorOrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Order Details', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          FutureBuilder<OrderModel?>(
            future: ref.read(vendorServiceProvider).getOrder(orderId),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return IconButton(
                  icon: const Icon(Icons.print_rounded),
                  onPressed: () => PdfService.generateOrderInvoice(snapshot.data!),
                  tooltip: 'Print Invoice',
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<OrderModel?>(
        future: ref.read(vendorServiceProvider).getOrder(orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final order = snapshot.data;
          if (order == null) {
            return const Center(child: Text('Order not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusBanner(order.status),
                const SizedBox(height: 24),
                _SectionTitle(title: 'Customer Information'),
                const SizedBox(height: 12),
                _InfoCard(
                  children: [
                    _InfoRow(label: 'Name', value: order.customerName),
                    _InfoRow(label: 'Phone', value: order.customerPhone, isPhone: true),
                    _InfoRow(label: 'Address', value: order.deliveryAddress),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionTitle(title: 'Ordered Products'),
                const SizedBox(height: 12),
                _InfoCard(
                  children: [
                    ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${item['name']} x${item['quantity']}', style: const TextStyle(fontWeight: FontWeight.w500)),
                          Text('Rs ${item['price'] * item['quantity']}'),
                        ],
                      ),
                    )),
                    const Divider(),
                    _InfoRow(label: 'Delivery Fee', value: 'Rs ${order.deliveryFee}'),
                    _InfoRow(
                      label: 'Total Amount', 
                      value: 'Rs ${order.totalAmount}', 
                      valueStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8B5CF6), fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionTitle(title: 'Payment Information'),
                const SizedBox(height: 12),
                _InfoCard(
                  children: [
                    _InfoRow(label: 'Method', value: order.paymentMethod),
                    _InfoRow(
                      label: 'Status', 
                      value: order.paymentStatus.toUpperCase(),
                      valueStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: order.paymentStatus == 'paid' ? Colors.green : Colors.orange,
                      ),
                    ),
                    _InfoRow(label: 'Order Time', value: DateFormat('MMM dd, yyyy - h:mm a').format(order.createdAt)),
                  ],
                ),
                const SizedBox(height: 40),
                _buildActionButtons(context, ref, order),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBanner(OrderStatus status) {
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Center(
        child: Text(
          status.name.toUpperCase(),
          style: TextStyle(color: color, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, OrderModel order) {
    if (order.status == OrderStatus.pending) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _updateStatus(context, ref, order.id, OrderStatus.cancelled),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Reject'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _updateStatus(context, ref, order.id, OrderStatus.preparing),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              child: const Text('Accept Order'),
            ),
          ),
        ],
      );
    }

    if (order.status == OrderStatus.preparing) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _updateStatus(context, ref, order.id, OrderStatus.confirmed),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), foregroundColor: Colors.white),
          child: const Text('Ready for Pickup'),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _updateStatus(BuildContext context, WidgetRef ref, String id, OrderStatus status) async {
    await ref.read(orderServiceProvider).updateStatus(id, status);
    if (context.mounted) Navigator.pop(context);
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isPhone;
  final TextStyle? valueStyle;

  const _InfoRow({required this.label, required this.value, this.isPhone = false, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ),
          Expanded(
            child: GestureDetector(
              onTap: isPhone ? () => launchUrl(Uri.parse('tel:$value')) : null,
              child: Text(
                value,
                style: valueStyle ?? TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isPhone ? Colors.blue : Colors.black,
                  decoration: isPhone ? TextDecoration.underline : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
