import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:http/http.dart' as http;
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
              SizedBox(
                height: 250,
                child: _OSMMap(order: order),
              ),
              
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

class _OSMMap extends StatefulWidget {
  final OrderModel order;
  const _OSMMap({required this.order});

  @override
  State<_OSMMap> createState() => _OSMMapState();
}

class _OSMMapState extends State<_OSMMap> {
  List<latlong.LatLng> _routePoints = [];
  double _distanceKm = 0.0;
  bool _isLoadingRoute = true;

  @override
  void initState() {
    super.initState();
    _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    final pickup = widget.order.pickupLocation != null 
      ? latlong.LatLng(widget.order.pickupLocation!.latitude, widget.order.pickupLocation!.longitude)
      : latlong.LatLng(33.6844, 73.0479);
      
    final delivery = widget.order.deliveryLocation != null
      ? latlong.LatLng(widget.order.deliveryLocation!.latitude, widget.order.deliveryLocation!.longitude)
      : latlong.LatLng(33.7000, 73.0600);

    try {
      final url = 'http://router.project-osrm.org/route/v1/driving/${pickup.longitude},${pickup.latitude};${delivery.longitude},${delivery.latitude}?overview=full&geometries=geojson';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coordinates = data['routes'][0]['geometry']['coordinates'] as List;
        final distance = data['routes'][0]['distance'] as num; // in meters

        setState(() {
          _routePoints = coordinates.map((c) => latlong.LatLng(c[1], c[0])).toList();
          _distanceKm = distance / 1000.0;
          _isLoadingRoute = false;
        });
      } else {
        setState(() {
          _routePoints = [pickup, delivery];
          _isLoadingRoute = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching route: $e');
      setState(() {
        _routePoints = [pickup, delivery];
        _isLoadingRoute = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pickup = widget.order.pickupLocation != null 
      ? latlong.LatLng(widget.order.pickupLocation!.latitude, widget.order.pickupLocation!.longitude)
      : latlong.LatLng(33.6844, 73.0479);
      
    final delivery = widget.order.deliveryLocation != null
      ? latlong.LatLng(widget.order.deliveryLocation!.latitude, widget.order.deliveryLocation!.longitude)
      : latlong.LatLng(33.7000, 73.0600);

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: pickup,
            initialZoom: 14.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.zen_mart_pro',
            ),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: _routePoints.isNotEmpty ? _routePoints : [pickup, delivery],
                  color: AppColors.rider,
                  strokeWidth: 5,
                ),
              ],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: pickup,
                  width: 40,
                  height: 40,
                  child: const _MapMarker(icon: Icons.storefront_rounded, color: AppColors.rider),
                ),
                Marker(
                  point: delivery,
                  width: 40,
                  height: 40,
                  child: const _MapMarker(icon: Icons.location_on_rounded, color: Color(0xFF10B981)),
                ),
              ],
            ),
          ],
        ),
        if (!_isLoadingRoute)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.directions_rounded, size: 16, color: AppColors.rider),
                  const SizedBox(width: 6),
                  Text(
                    '${_distanceKm.toStringAsFixed(1)} KM',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
            ),
          ),
      ],
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
          if (nextStatus == OrderStatus.delivered) {
            _showOtpDialog(context, order);
          } else {
            ref.read(orderServiceProvider).updateStatus(order.id, nextStatus);
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

  void _showOtpDialog(BuildContext context, OrderModel order) {
    final otpController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify Delivery'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please ask the customer for the 4-digit verification code.'),
            const SizedBox(height: 20),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 4,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8),
              decoration: InputDecoration(
                hintText: '0000',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                counterText: '',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (otpController.text == order.deliveryOtp) {
                await ref.read(orderServiceProvider).updateStatus(order.id, OrderStatus.delivered);
                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  context.pop(); // Go back to dashboard
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid Code. Please try again.'), backgroundColor: Colors.redAccent));
              }
            },
            child: const Text('Confirm Delivery'),
          ),
        ],
      ),
    );
  }
}
