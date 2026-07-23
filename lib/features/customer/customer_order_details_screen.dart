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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('order_summary'.tr(ref), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Theme.of(context).textTheme.displayLarge?.color,
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
                  icon: const Icon(Icons.download_rounded, size: 22),
                  onPressed: () => PdfService.generateOrderInvoice(snapshot.data!),
                  tooltip: 'Invoice',
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
            return const Center(child: CircularProgressIndicator());
          }
          final order = snapshot.data;
          if (order == null) return const Center(child: Text('Order not found'));

          return Column(
            children: [
              // MAP AREA
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
                      _buildStatusTracker(order.status),
                      
                      // IMPROVED OTP DISPLAY: Show for all active delivery phases
                      if (order.status != OrderStatus.delivered && 
                          order.status != OrderStatus.cancelled && 
                          order.status != OrderStatus.rejected) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.08), 
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: AppColors.accent.withOpacity(0.15), width: 1.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'DELIVERY OTP', 
                                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppColors.accent, letterSpacing: 1.5)
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Give this to your rider', 
                                    style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.w600)
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.1), blurRadius: 10)],
                                ),
                                child: Text(
                                  order.deliveryOtp ?? '----', 
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 28, color: AppColors.accent, letterSpacing: 4)
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),
                      _SectionHeader(title: 'Delivery Address', icon: Icons.location_on_rounded),
                      const SizedBox(height: 16),
                      _InfoCard(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.home_rounded, color: AppColors.accent, size: 20),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Home / Default', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                                  const SizedBox(height: 4),
                                  Text(
                                    order.deliveryAddress, 
                                    style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 13, height: 1.4, fontWeight: FontWeight.w500)
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (order.riderId != null) ...[
                        _SectionHeader(title: 'Rider Details', icon: Icons.directions_bike_rounded),
                        const SizedBox(height: 16),
                        _buildRiderCard(context, order),
                        const SizedBox(height: 32),
                      ],
                      _SectionHeader(title: 'Bill Summary', icon: Icons.receipt_long_rounded),
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

  Widget _buildStatusTracker(OrderStatus status) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 25, offset: const Offset(0, 10)),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ORDER STATUS', style: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  const SizedBox(height: 6),
                  Text(
                    status.name.toUpperCase(), 
                    style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: -0.5)
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.accent.withOpacity(0.2), AppColors.accent.withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_graph_rounded, color: AppColors.accent, size: 24),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 8)),
        ],
        border: Border.all(color: AppColors.accent.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle, 
              border: Border.all(color: AppColors.accent.withOpacity(0.3), width: 2)
            ),
            child: const CircleAvatar(
              radius: 26,
              backgroundColor: Color(0xFFF1F5F9), 
              child: Icon(Icons.person_rounded, color: AppColors.accent, size: 32)
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Arriving Soon', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A), letterSpacing: -0.2)),
                const SizedBox(height: 2),
                Text('Professional Delivery Partner', style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          _SmallRoundBtn(
            icon: Icons.call_rounded, 
            color: const Color(0xFF10B981), 
            onTap: () => launchUrl(Uri.parse('tel:${order.vendorPhone}'))
          ),
          const SizedBox(width: 10),
          _SmallRoundBtn(
            icon: Icons.chat_bubble_rounded, 
            color: AppColors.accent, 
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
                      Text('${item['quantity']}x', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.accent, fontSize: 13)),
                      const SizedBox(width: 12),
                      Expanded(child: Text(item['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155)))),
                    ],
                  ),
                ),
                Text('Rs ${item['price'] * item['quantity']}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              ],
            ),
          )),
          const Divider(height: 32, thickness: 1),
          _SummaryLine(label: 'Item Total', value: 'Rs ${(order.totalAmount - order.deliveryFee).toStringAsFixed(0)}'),
          const SizedBox(height: 10),
          _SummaryLine(label: 'Delivery Fee', value: 'Rs ${order.deliveryFee.toStringAsFixed(0)}', isFree: order.deliveryFee == 0),
          
          const Divider(height: 32, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Grand Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
              Text('Rs ${order.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: AppColors.accent)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _InfoBadge(label: order.paymentMethod.toUpperCase(), icon: Icons.payments_rounded),
              const SizedBox(width: 10),
              _InfoBadge(
                label: order.paymentStatus.toUpperCase(), 
                icon: Icons.check_circle_rounded,
                color: order.paymentStatus == 'paid' ? Colors.green : Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, OrderModel order) {
    return Column(
      children: [
        if (order.status == OrderStatus.delivered)
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 64),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 8,
              shadowColor: AppColors.accent.withOpacity(0.4),
            ),
            child: const Text('Reorder Now', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ),
        const SizedBox(height: 16),
        if (order.status == OrderStatus.delivered)
          OutlinedButton(
            onPressed: () => _showReviewDialog(context, ref, order),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 64),
              side: const BorderSide(color: AppColors.accent, width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Rate Your Experience', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.accent)),
          ),
        if (order.status == OrderStatus.pending)
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.cancel_rounded, size: 18),
            label: const Text('Cancel My Order', style: TextStyle(fontWeight: FontWeight.w800)),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
          ),
      ],
    );
  }

  void _showReviewDialog(BuildContext context, WidgetRef ref, OrderModel order) {
    int rating = 5;
    final reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: const Text('Rate your experience', style: TextStyle(fontWeight: FontWeight.w900)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => IconButton(
                  onPressed: () => setState(() => rating = index + 1),
                  icon: Icon(Icons.star_rounded, color: index < rating ? Colors.orange : Colors.grey[300], size: 40),
                )),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: reviewController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Any specific feedback?',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Skip', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w700))),
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
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Submit'),
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
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            color: AppColors.accent,
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
  Widget build(BuildContext context) => Column(children: [Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: active ? AppColors.accent : Colors.grey[400]))]);
}

class _OSMMap extends StatelessWidget {
  final OrderModel order;
  const _OSMMap({required this.order});
  @override
  Widget build(BuildContext context) {
    final pickupRaw = order.pickupLocation;
    final deliveryRaw = order.deliveryLocation;
    
    final pickup = (pickupRaw != null && pickupRaw.latitude.isFinite && pickupRaw.longitude.isFinite) 
        ? latlong.LatLng(pickupRaw.latitude, pickupRaw.longitude) 
        : const latlong.LatLng(33.6844, 73.0479);
        
    final delivery = (deliveryRaw != null && deliveryRaw.latitude.isFinite && deliveryRaw.longitude.isFinite) 
        ? latlong.LatLng(deliveryRaw.latitude, deliveryRaw.longitude) 
        : const latlong.LatLng(33.7000, 73.0600);
        
    return FlutterMap(
      options: MapOptions(
        initialCenter: delivery, 
        initialZoom: 14.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', 
          userAgentPackageName: 'com.example.zen_mart_pro',
        ),
        MarkerLayer(markers: [
          Marker(
            point: pickup, 
            width: 40, 
            height: 40, 
            child: const Icon(Icons.storefront_rounded, color: Colors.blue, size: 32)
          ),
          Marker(
            point: delivery, 
            width: 40, 
            height: 40, 
            child: const Icon(Icons.location_on_rounded, color: AppColors.accent, size: 32)
          ),
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
  Widget build(BuildContext context) => Row(children: [Icon(icon, size: 18, color: AppColors.accent), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)))]);
}

class _InfoCard extends StatelessWidget {
  final Widget child;
  const _InfoCard({required this.child});
  @override
  Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 4))]), child: child);
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;
  final bool isFree;
  const _SummaryLine({required this.label, required this.value, this.isFree = false});
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 13, fontWeight: FontWeight.w600)), Text(isFree ? 'FREE' : value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: isFree ? Colors.green : const Color(0xFF1E293B)))]);
}

class _InfoBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;
  const _InfoBadge({required this.label, required this.icon, this.color});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: (color ?? AppColors.accent).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Row(children: [Icon(icon, size: 12, color: color ?? AppColors.accent), const SizedBox(width: 6), Text(label, style: TextStyle(color: color ?? AppColors.accent, fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 0.5))]));
}

class _SmallRoundBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SmallRoundBtn({required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 20)));
}
