import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/providers.dart';
import '../../models/order_model.dart';
import '../../theme/app_colors.dart';

class OrderDetailsScreen extends ConsumerWidget {
  final String orderId;
  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeOrdersAsync = ref.watch(activeRiderOrdersProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Order #${orderId.substring(0, 8).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: activeOrdersAsync.when(
        data: (orders) {
          final order = orders.firstWhere((o) => o.id == orderId, 
              orElse: () => throw Exception('Order not found'));
          
          return Column(
            children: [
              // LIVE TRACKING MAP AREA
              _MapPlaceholder(order: order),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatusTimeline(currentStatus: order.status),
                      const SizedBox(height: 32),
                      
                      // VENDOR CARD
                      _InfoCard(
                        orderId: order.id,
                        title: 'PICKUP FROM VENDOR',
                        name: order.shopName,
                        address: order.pickupAddress,
                        phone: order.vendorPhone,
                        icon: Icons.storefront_rounded,
                        accentColor: AppColors.rider,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // CUSTOMER CARD
                      _InfoCard(
                        orderId: order.id,
                        title: 'DELIVER TO CUSTOMER',
                        name: order.customerName,
                        address: order.deliveryAddress,
                        phone: order.customerPhone,
                        icon: Icons.person_rounded,
                        accentColor: const Color(0xFF10B981),
                      ),
                      
                      const SizedBox(height: 32),
                      const Text('Product Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: order.items.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${item['name']} x${item['quantity']}', style: const TextStyle(fontWeight: FontWeight.w500)),
                                Text('Rs ${item['price']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )).toList(),
                        ),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
      bottomSheet: activeOrdersAsync.when(
        data: (orders) {
          final order = orders.firstWhere((o) => o.id == orderId);
          return _ActionPanel(order: order, ref: ref);
        },
        loading: () => const SizedBox.shrink(),
        error: (e, s) => const SizedBox.shrink(),
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  final OrderModel order;
  const _MapPlaceholder({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        image: DecorationImage(
          image: const NetworkImage('https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1?auto=format&fit=crop&q=80&w=800'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
        ),
      ),
      child: Stack(
        children: [
          // Pickup Marker
          const Positioned(
            top: 40,
            left: 60,
            child: _MapMarker(icon: Icons.storefront_rounded, color: AppColors.rider),
          ),
          // Customer Marker
          const Positioned(
            bottom: 40,
            right: 80,
            child: _MapMarker(icon: Icons.location_on_rounded, color: Color(0xFF10B981)),
          ),
          // Route Line (SVG or simple Container)
          Center(
            child: CustomPaint(
              size: const Size(200, 100),
              painter: _RoutePainter(),
            ),
          ),
          // Tracking Info Overlay
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _TrackingStat(label: 'DISTANCE', value: '2.4 km'),
                  _TrackingStat(label: 'EST. TIME', value: '12 mins'),
                  _TrackingStat(label: 'TRAFFIC', value: 'Moderate'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _MapMarker({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        Container(width: 2, height: 4, color: color),
      ],
    );
  }
}

class _TrackingStat extends StatelessWidget {
  final String label;
  final String value;
  const _TrackingStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
      ],
    );
  }
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height / 2);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StatusTimeline extends StatelessWidget {
  final OrderStatus currentStatus;
  const _StatusTimeline({required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final steps = [
      {'status': OrderStatus.accepted, 'label': 'Accepted'},
      {'status': OrderStatus.reachedVendor, 'label': 'Reached'},
      {'status': OrderStatus.pickedUp, 'label': 'Picked Up'},
      {'status': OrderStatus.outForDelivery, 'label': 'On Way'},
      {'status': OrderStatus.delivered, 'label': 'Delivered'},
    ];

    return Row(
      children: steps.map((step) {
        final index = steps.indexOf(step);
        final isActive = OrderStatus.values.indexOf(currentStatus) >= OrderStatus.values.indexOf(step['status'] as OrderStatus);
        
        return Expanded(
          child: Column(
            children: [
              Container(
                height: 4,
                color: isActive ? AppColors.rider : Colors.grey.withOpacity(0.2),
              ),
              const SizedBox(height: 8),
              Text(
                step['label'] as String,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? AppColors.rider : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String orderId;
  final String title;
  final String name;
  final String address;
  final String phone;
  final IconData icon;
  final Color accentColor;

  const _InfoCard({
    required this.orderId,
    required this.title,
    required this.name,
    required this.address,
    required this.phone,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1, color: Colors.grey[600])),
              Icon(icon, color: accentColor, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(address, style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 13)),
          const SizedBox(height: 20),
          Row(
            children: [
              _ContactButton(
                icon: Icons.call_rounded,
                label: 'Call',
                onTap: () => launchUrl(Uri.parse('tel:$phone')),
                color: accentColor,
              ),
              const SizedBox(width: 8),
              _ContactButton(
                icon: Icons.chat_bubble_rounded,
                label: 'Chat',
                onTap: () => GoRouter.of(context).push('/chat/$orderId/$name'),
                color: accentColor,
              ),
              const Spacer(),
              _ContactButton(
                icon: Icons.directions_rounded,
                label: 'Navigate',
                onTap: () => launchUrl(Uri.parse('google.navigation:q=$address')),
                color: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ContactButton({required this.icon, required this.label, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  final OrderModel order;
  final WidgetRef ref;

  const _ActionPanel({required this.order, required this.ref});

  @override
  Widget build(BuildContext context) {
    String buttonText = 'Next Step';
    OrderStatus nextStatus = order.status;

    switch (order.status) {
      case OrderStatus.accepted:
        buttonText = 'I HAVE REACHED VENDOR';
        nextStatus = OrderStatus.reachedVendor;
        break;
      case OrderStatus.reachedVendor:
        buttonText = 'I HAVE PICKED UP ORDER';
        nextStatus = OrderStatus.pickedUp;
        break;
      case OrderStatus.pickedUp:
        buttonText = 'OUT FOR DELIVERY';
        nextStatus = OrderStatus.outForDelivery;
        break;
      case OrderStatus.outForDelivery:
        buttonText = 'MARK AS DELIVERED';
        nextStatus = OrderStatus.delivered;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: ElevatedButton(
        onPressed: () {
          ref.read(riderServiceProvider).updateOrderStatus(order.id, nextStatus);
          if (nextStatus == OrderStatus.delivered) {
             context.pop();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.rider,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(buttonText, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1)),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}
