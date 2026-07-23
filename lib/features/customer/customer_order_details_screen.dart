import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:url_launcher/url_launcher.dart';
import '../../core/providers.dart';
import '../../core/localization.dart';
import '../../models/order_model.dart';
import '../../theme/app_colors.dart';
import '../../services/pdf_service.dart';

class CustomerOrderDetailsScreen extends ConsumerWidget {
  final String orderId;
  const CustomerOrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Order Tracking', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white)),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          StreamBuilder<OrderModel?>(
            stream: ref.read(customerServiceProvider).getOrderStream(orderId),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return IconButton(
                  icon: const Icon(Icons.download_rounded, size: 22, color: AppColors.primary),
                  onPressed: () => PdfService.generateOrderInvoice(snapshot.data!),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<OrderModel?>(
        stream: ref.read(customerServiceProvider).getOrderStream(orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          final order = snapshot.data;
          if (order == null) return const Center(child: Text('Order not found', style: TextStyle(color: AppColors.textHint)));

          return Column(
            children: [
              SizedBox(
                height: 220,
                child: _OSMMap(order: order),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusTracker(context, order.status),
                      
                      if (order.status != OrderStatus.delivered && 
                          order.status != OrderStatus.cancelled && 
                          order.status != OrderStatus.rejected) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08), 
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: AppColors.primary.withOpacity(0.15), width: 1.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'DELIVERY OTP', 
                                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppColors.primary, letterSpacing: 1.5)
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Give this to your rider', 
                                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  order.deliveryOtp ?? '----', 
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 28, color: AppColors.background, letterSpacing: 4)
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),
                      const _SectionHeader(title: 'Delivery Address', icon: Icons.location_on_rounded),
                      const SizedBox(height: 16),
                      _InfoCard(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.home_rounded, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Delivery Location', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white)),
                                  const SizedBox(height: 2),
                                  Text(
                                    order.deliveryAddress, 
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      if (order.riderId != null) ...[
                        const SizedBox(height: 32),
                        const _SectionHeader(title: 'Rider Details', icon: Icons.directions_bike_rounded),
                        const SizedBox(height: 16),
                        _buildRiderCard(context, order),
                      ],

                      const SizedBox(height: 32),
                      const _SectionHeader(title: 'Order Summary', icon: Icons.receipt_long_rounded),
                      const SizedBox(height: 16),
                      _buildOrderSummary(order),
                      const SizedBox(height: 40),
                      _buildActionButtons(context, ref, order),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusTracker(BuildContext context, OrderStatus status) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ORDER STATUS', style: TextStyle(color: AppColors.textHint, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  const SizedBox(height: 6),
                  Text(
                    status.name.toUpperCase(), 
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: -0.5)
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_graph_rounded, color: AppColors.primary, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _CustomProgressBar(status: status),
        ],
      ),
    );
  }

  Widget _buildRiderCard(BuildContext context, OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.background, 
            child: Icon(Icons.person_rounded, color: AppColors.primary, size: 32)
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Professional Rider', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white)),
                SizedBox(height: 2),
                Text('Heading your way', style: TextStyle(color: AppColors.textHint, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          _SmallRoundBtn(
            icon: Icons.call_rounded, 
            color: AppColors.success, 
            onTap: () => launchUrl(Uri.parse('tel:${order.vendorPhone}'))
          ),
          const SizedBox(width: 10),
          _SmallRoundBtn(
            icon: Icons.chat_bubble_rounded, 
            color: AppColors.primary, 
            onTap: () => context.push('/chat/${order.id}/Rider')
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(OrderModel order) {
    return _InfoCard(
      child: Column(
        children: [
          ...order.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text('${item['quantity']}x', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 13)),
                      const SizedBox(width: 12),
                      Expanded(child: Text(item['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white))),
                    ],
                  ),
                ),
                Text('Rs ${item['price'] * item['quantity']}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white)),
              ],
            ),
          )),
          const Divider(color: AppColors.border, height: 32),
          _SummaryLine(label: 'Total Items', value: 'Rs ${(order.totalAmount - order.deliveryFee).toStringAsFixed(0)}'),
          const SizedBox(height: 10),
          _SummaryLine(label: 'Delivery Fee', value: 'Rs ${order.deliveryFee.toStringAsFixed(0)}', color: AppColors.success),
          const Divider(color: AppColors.border, height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Grand Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
              Text('Rs ${order.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, OrderModel order) {
    if (order.status == OrderStatus.delivered) {
      return Column(
        children: [
          ElevatedButton(
            onPressed: () {},
            child: const Text('REORDER NOW'),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => _showReviewDialog(context, ref, order),
            child: const Text('RATE EXPERIENCE'),
          ),
        ],
      );
    }
    
    if (order.status == OrderStatus.pending) {
      return OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
        child: const Text('CANCEL ORDER'),
      );
    }

    return const SizedBox.shrink();
  }

  void _showReviewDialog(BuildContext context, WidgetRef ref, OrderModel order) {
    int rating = 5;
    final reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.dialog,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: const Text('Rate your experience', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => IconButton(
                  onPressed: () => setState(() => rating = index + 1),
                  icon: Icon(Icons.star_rounded, color: index < rating ? AppColors.warning : AppColors.surface, size: 40),
                )),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: reviewController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Any specific feedback?',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('SKIP', style: TextStyle(color: AppColors.textHint))),
            ElevatedButton(
              onPressed: () async {
                await ref.read(customerServiceProvider).submitReview(
                  orderId: order.id,
                  shopId: order.shopId,
                  riderId: order.riderId,
                  customerName: order.customerName,
                  rating: rating.toDouble(),
                  review: reviewController.text.trim(),
                );
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(100, 48)),
              child: const Text('SUBMIT'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomProgressBar extends StatelessWidget {
  final OrderStatus status;
  const _CustomProgressBar({required this.status});

  double _getVal() {
    switch (status) {
      case OrderStatus.pending: return 0.1;
      case OrderStatus.preparing: return 0.3;
      case OrderStatus.confirmed: return 0.45;
      case OrderStatus.accepted: return 0.6;
      case OrderStatus.reachedVendor: return 0.7;
      case OrderStatus.pickedUp: return 0.8;
      case OrderStatus.outForDelivery: return 0.9;
      case OrderStatus.delivered: return 1.0;
      default: return 0.1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: _getVal(),
            minHeight: 8,
            backgroundColor: AppColors.background,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _StepDot(label: 'Placed', active: true),
            _StepDot(label: 'Preparing', active: _getVal() >= 0.3),
            _StepDot(label: 'Rider', active: _getVal() >= 0.6),
            _StepDot(label: 'Delivered', active: _getVal() == 1.0),
          ],
        ),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final bool active;
  const _StepDot({required this.label, required this.active});
  @override
  Widget build(BuildContext context) => Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: active ? AppColors.primary : AppColors.textDisabled));
}

class _OSMMap extends StatelessWidget {
  final OrderModel order;
  const _OSMMap({required this.order});
  @override
  Widget build(BuildContext context) {
    final pickupRaw = order.pickupLocation;
    final deliveryRaw = order.deliveryLocation;
    
    final pickup = (pickupRaw != null && pickupRaw.latitude.isFinite) 
        ? latlong.LatLng(pickupRaw.latitude, pickupRaw.longitude) 
        : const latlong.LatLng(33.6844, 73.0479);
        
    final delivery = (deliveryRaw != null && deliveryRaw.latitude.isFinite) 
        ? latlong.LatLng(deliveryRaw.latitude, deliveryRaw.longitude) 
        : const latlong.LatLng(33.7000, 73.0600);
        
    return FlutterMap(
      options: MapOptions(initialCenter: delivery, initialZoom: 14.0),
      children: [
        TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.zen_mart_pro'),
        MarkerLayer(markers: [
          Marker(point: pickup, width: 40, height: 40, child: const Icon(Icons.storefront_rounded, color: AppColors.info, size: 32)),
          Marker(point: delivery, width: 40, height: 40, child: const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 32)),
        ]),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});
  @override
  Widget build(BuildContext context) => Row(children: [Icon(icon, size: 18, color: AppColors.primary), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white))]);
}

class _InfoCard extends StatelessWidget {
  final Widget child;
  const _InfoCard({required this.child});
  @override
  Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24)), child: child);
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _SummaryLine({required this.label, required this.value, this.color});
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)), Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: color ?? Colors.white))]);
}

class _SmallRoundBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SmallRoundBtn({required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color, size: 20)));
}
