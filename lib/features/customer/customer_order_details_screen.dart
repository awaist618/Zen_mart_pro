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
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    
    final bgColor = isLight ? AppColors.lightBackground : AppColors.premiumDarkBackground;
    final cardColor = isLight ? AppColors.lightSurface : AppColors.premiumDarkSurface;
    final primaryColor = isLight ? AppColors.lightPrimary : AppColors.premiumDarkPrimary;
    final textColor = isLight ? AppColors.lightTextPrimary : AppColors.premiumDarkTextPrimary;
    final secondaryTextColor = isLight ? AppColors.lightTextSecondary : AppColors.premiumDarkTextSecondary;
    final dividerColor = isLight ? AppColors.lightBorder : AppColors.premiumDarkDivider;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Order Details', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: textColor)),
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: textColor),
          onPressed: () => context.pop(),
        ),
        actions: [
          StreamBuilder<OrderModel?>(
            stream: ref.read(customerServiceProvider).getOrderStream(orderId),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return IconButton(
                  icon: Icon(Icons.download_rounded, size: 22, color: primaryColor),
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
            return Center(child: CircularProgressIndicator(color: primaryColor));
          }
          final order = snapshot.data;
          if (order == null) return Center(child: Text('Order not found', style: TextStyle(color: secondaryTextColor)));

          return Column(
            children: [
              SizedBox(
                height: 220,
                child: _OSMMap(order: order, primaryColor: primaryColor),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusTracker(context, order.status, cardColor, textColor, secondaryTextColor, primaryColor, dividerColor, isLight),
                      
                      if (order.status != OrderStatus.delivered && 
                          order.status != OrderStatus.cancelled && 
                          order.status != OrderStatus.rejected) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.08), 
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: primaryColor.withValues(alpha: 0.15), width: 1.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'DELIVERY OTP', 
                                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: primaryColor, letterSpacing: 1.5)
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Give this to your rider', 
                                    style: TextStyle(color: secondaryTextColor, fontSize: 13, fontWeight: FontWeight.w500)
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [BoxShadow(color: primaryColor.withValues(alpha: 0.2), blurRadius: 15)],
                                ),
                                child: Text(
                                  order.deliveryOtp ?? '----', 
                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28, color: AppColors.premiumDarkBackground, letterSpacing: 4)
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),
                      _SectionHeader(title: 'Delivery Address', icon: Icons.location_on_rounded, primaryColor: primaryColor, textColor: textColor),
                      const SizedBox(height: 16),
                      _InfoCard(
                        cardColor: cardColor,
                        dividerColor: dividerColor,
                        isLight: isLight,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                              child: Icon(Icons.home_rounded, color: primaryColor, size: 20),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Delivery Location', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: textColor)),
                                  const SizedBox(height: 2),
                                  Text(
                                    order.deliveryAddress, 
                                    style: TextStyle(color: secondaryTextColor, fontSize: 13, fontWeight: FontWeight.w500)
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      if (order.riderId != null) ...[
                        const SizedBox(height: 32),
                        _SectionHeader(title: 'Rider Details', icon: Icons.directions_bike_rounded, primaryColor: primaryColor, textColor: textColor),
                        const SizedBox(height: 16),
                        _buildRiderCard(context, order, cardColor, textColor, secondaryTextColor, primaryColor, bgColor),
                      ],

                      const SizedBox(height: 32),
                      _SectionHeader(title: 'Order Summary', icon: Icons.receipt_long_rounded, primaryColor: primaryColor, textColor: textColor),
                      const SizedBox(height: 16),
                      _buildOrderSummary(order, cardColor, textColor, secondaryTextColor, primaryColor, dividerColor, isLight, bgColor),
                      const SizedBox(height: 40),
                      _buildActionButtons(context, ref, order, primaryColor, isLight),
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

  Widget _buildStatusTracker(BuildContext context, OrderStatus status, Color cardColor, Color textColor, Color secondaryTextColor, Color primary, Color divider, bool isLight) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: isLight ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20)] : null,
        border: isLight ? Border.all(color: divider) : Border.all(color: divider.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ORDER STATUS', style: TextStyle(color: secondaryTextColor.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  const SizedBox(height: 6),
                  Text(
                    status.name.toUpperCase(), 
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: -0.5)
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.auto_graph_rounded, color: primary, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _CustomProgressBar(status: status, primaryColor: primary, bgColor: isLight ? AppColors.lightSecondaryBackground : AppColors.premiumDarkSecondaryBackground),
        ],
      ),
    );
  }

  Widget _buildRiderCard(BuildContext context, OrderModel order, Color cardColor, Color textColor, Color secondaryTextColor, Color primary, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: primary.withOpacity(0.1), 
            child: Icon(Icons.person_rounded, color: primary, size: 32)
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Professional Rider', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: textColor)),
                const SizedBox(height: 2),
                Text('Heading your way', style: TextStyle(color: secondaryTextColor, fontSize: 12, fontWeight: FontWeight.w600)),
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
            color: primary, 
            onTap: () => context.push('/chat/${order.id}/Rider')
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(OrderModel order, Color cardColor, Color textColor, Color secondaryTextColor, Color primary, Color divider, bool isLight, Color bgColor) {
    return _InfoCard(
      cardColor: cardColor,
      dividerColor: divider,
      isLight: isLight,
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isLight ? AppColors.lightSecondaryBackground : AppColors.premiumDarkSecondaryBackground, 
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: Text('${item['quantity']}x', style: TextStyle(fontWeight: FontWeight.w900, color: primary, fontSize: 11)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(item['name'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor))),
                    ],
                  ),
                ),
                Text('Rs ${item['price'] * item['quantity']}', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: textColor)),
              ],
            ),
          )),
          Divider(color: divider.withOpacity(isLight ? 1 : 0.2), height: 32),
          _SummaryLine(label: 'Total Items', value: 'Rs ${(order.totalAmount - order.deliveryFee).toStringAsFixed(0)}', textColor: textColor, secondaryTextColor: secondaryTextColor),
          const SizedBox(height: 10),
          _SummaryLine(label: 'Delivery Fee', value: 'Rs ${order.deliveryFee.toStringAsFixed(0)}', color: AppColors.success, textColor: textColor, secondaryTextColor: secondaryTextColor),
          Divider(color: divider.withOpacity(isLight ? 1 : 0.2), height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Grand Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textColor)),
              Text('Rs ${order.totalAmount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, OrderModel order, Color primary, bool isLight) {
    if (order.status == OrderStatus.delivered) {
      return Column(
        children: [
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('REORDER NOW', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => _showReviewDialog(context, ref, order, isLight, primary),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('RATE EXPERIENCE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
          ),
        ],
      );
    }
    
    if (order.status == OrderStatus.pending) {
      return OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error, 
          side: const BorderSide(color: AppColors.error, width: 1.5),
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: const Text('CANCEL ORDER', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
      );
    }

    return const SizedBox.shrink();
  }

  void _showReviewDialog(BuildContext context, WidgetRef ref, OrderModel order, bool isLight, Color primary) {
    int shopRating = 5;
    final Map<String, int> productRatings = {
      for (var item in order.items) item['productId']: 5
    };
    final reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: isLight ? Colors.white : AppColors.dialog,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text('Rate your experience', style: TextStyle(fontWeight: FontWeight.w900, color: isLight ? Colors.black : Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rate Store: ${order.shopName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) => InkWell(
                    onTap: () => setState(() => shopRating = index + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(Icons.star_rounded, color: index < shopRating ? AppColors.warning : (isLight ? Colors.grey[200] : Colors.white12), size: 28),
                    ),
                  )),
                ),
                const Divider(height: 32),
                Text('Rate Products:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 12),
                ...order.items.map((item) {
                  final pid = item['productId'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['name'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        Row(
                          children: List.generate(5, (index) => InkWell(
                            onTap: () => setState(() => productRatings[pid] = index + 1),
                            child: Icon(Icons.star_rounded, color: index < productRatings[pid]! ? AppColors.warning : Colors.grey[200], size: 24),
                          )),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                TextField(
                  controller: reviewController,
                  maxLines: 3,
                  style: TextStyle(color: isLight ? Colors.black : Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Share more details about your experience...',
                    hintStyle: TextStyle(color: isLight ? Colors.grey : Colors.white38),
                    filled: true,
                    fillColor: isLight ? Colors.grey[100] : Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('SKIP', style: TextStyle(color: AppColors.textHint, fontWeight: FontWeight.w800))),
            ElevatedButton(
              onPressed: () async {
                final List<Map<String, dynamic>> productRatingsList = [];
                productRatings.forEach((key, value) {
                  productRatingsList.add({
                    'productId': key,
                    'rating': value,
                  });
                });

                await ref.read(customerServiceProvider).submitReview(
                  orderId: order.id,
                  shopId: order.shopId,
                  riderId: order.riderId,
                  customerName: order.customerName,
                  rating: shopRating.toDouble(),
                  review: reviewController.text.trim(),
                  productRatings: productRatingsList,
                );
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(100, 48), backgroundColor: primary),
              child: const Text('SUBMIT', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomProgressBar extends StatelessWidget {
  final OrderStatus status;
  final Color primaryColor;
  final Color bgColor;
  const _CustomProgressBar({required this.status, required this.primaryColor, required this.bgColor});

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
            backgroundColor: bgColor,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _StepDot(label: 'Placed', active: true, primary: primaryColor),
            _StepDot(label: 'Preparing', active: _getVal() >= 0.3, primary: primaryColor),
            _StepDot(label: 'Rider', active: _getVal() >= 0.6, primary: primaryColor),
            _StepDot(label: 'Delivered', active: _getVal() == 1.0, primary: primaryColor),
          ],
        ),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final bool active;
  final Color primary;
  const _StepDot({required this.label, required this.active, required this.primary});
  @override
  Widget build(BuildContext context) => Text(
    label, 
    style: TextStyle(
      fontSize: 10, 
      fontWeight: FontWeight.w900, 
      color: active ? primary : AppColors.textDisabled,
      letterSpacing: 0.5
    )
  );
}

class _OSMMap extends StatelessWidget {
  final OrderModel order;
  final Color primaryColor;
  const _OSMMap({required this.order, required this.primaryColor});
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
          Marker(point: delivery, width: 40, height: 40, child: Icon(Icons.location_on_rounded, color: primaryColor, size: 32)),
        ]),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color primaryColor;
  final Color textColor;
  const _SectionHeader({required this.title, required this.icon, required this.primaryColor, required this.textColor});
  @override
  Widget build(BuildContext context) => Row(children: [Icon(icon, size: 18, color: primaryColor), const SizedBox(width: 10), Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: textColor, letterSpacing: -0.2))]);
}

class _InfoCard extends StatelessWidget {
  final Widget child;
  final Color cardColor;
  final Color dividerColor;
  final bool isLight;
  const _InfoCard({required this.child, required this.cardColor, required this.dividerColor, required this.isLight});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, 
    padding: const EdgeInsets.all(24), 
    decoration: BoxDecoration(
      color: cardColor, 
      borderRadius: BorderRadius.circular(32),
      boxShadow: isLight ? [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)] : null,
      border: isLight ? Border.all(color: dividerColor) : Border.all(color: dividerColor.withOpacity(0.3)),
    ), 
    child: child
  );
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final Color textColor;
  final Color secondaryTextColor;
  const _SummaryLine({required this.label, required this.value, this.color, required this.textColor, required this.secondaryTextColor});
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(color: secondaryTextColor, fontSize: 14, fontWeight: FontWeight.w600)), Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: color ?? textColor))]);
}

class _SmallRoundBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SmallRoundBtn({required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color, size: 20)));
}
