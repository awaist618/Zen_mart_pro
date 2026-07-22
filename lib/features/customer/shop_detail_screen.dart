import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/providers.dart';
import '../../theme/app_colors.dart';
import '../../models/product_model.dart';
import '../../models/shop_model.dart';

class ShopDetailScreen extends ConsumerStatefulWidget {
  final String shopId;
  const ShopDetailScreen({super.key, required this.shopId});

  @override
  ConsumerState<ShopDetailScreen> createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends ConsumerState<ShopDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shopAsync = ref.watch(shopDetailProvider(widget.shopId));
    final productsAsync = ref.watch(shopProductsByIdProvider(widget.shopId));
    final cart = ref.watch(cartProvider);

    return shopAsync.when(
      data: (shop) {
        if (shop == null) return const Scaffold(body: Center(child: Text('Shop not found')));

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              _buildSliverAppBar(context, shop),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(shop.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                                Text(shop.category, style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 16)),
                              ],
                            ),
                          ),
                          _buildActionIcons(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildShopStats(shop),
                      const SizedBox(height: 24),
                      Text(shop.description, style: TextStyle(color: Colors.black.withOpacity(0.6), height: 1.5)),
                      const SizedBox(height: 24),
                      _ContactBar(phone: shop.phone, address: shop.address),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.accent,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppColors.accent,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'Products'),
                      Tab(text: 'Reviews'),
                    ],
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildProductsTab(productsAsync),
                _buildReviewsTab(),
              ],
            ),
          ),
          bottomNavigationBar: cart.itemCount > 0 ? _buildCartSummary(context, cart) : null,
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildActionIcons() {
    return Row(
      children: [
        _CircleIconButton(icon: Icons.share_outlined, onTap: () {}),
        const SizedBox(width: 12),
        _CircleIconButton(icon: Icons.favorite_border_rounded, color: Colors.redAccent, onTap: () {}),
      ],
    );
  }

  Widget _buildShopStats(ShopModel shop) {
    return Row(
      children: [
        _InfoChip(icon: Icons.star_rounded, label: '${shop.rating} (124)', color: Colors.orange),
        const SizedBox(width: 12),
        _InfoChip(icon: Icons.access_time_rounded, label: shop.deliveryTime, color: Colors.blue),
        const SizedBox(width: 12),
        _InfoChip(icon: Icons.delivery_dining_rounded, label: shop.hasFreeDelivery ? 'Free' : 'Rs ${shop.deliveryFee}', color: Colors.green),
      ],
    );
  }

  Widget _buildProductsTab(AsyncValue<List<ProductModel>> productsAsync) {
    return productsAsync.when(
      data: (products) {
        final filtered = products.where((p) => p.name.toLowerCase().contains(_searchQuery)).toList();
        
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black.withOpacity(0.05)),
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                  decoration: const InputDecoration(
                    hintText: 'Search products in this store...',
                    border: InputBorder.none,
                    icon: Icon(Icons.search, size: 20),
                  ),
                ),
              ),
            ),
            Expanded(
              child: filtered.isEmpty 
                ? const Center(child: Text('No products found.'))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) => _ProductTile(product: filtered[index]),
                  ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildReviewsTab() {
    return const Center(child: Text('No reviews yet.'));
  }

  Widget _buildSliverAppBar(BuildContext context, ShopModel shop) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.accent,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: shop.imageUrl.isNotEmpty 
            ? Image.network(shop.imageUrl, fit: BoxFit.cover)
            : Container(color: const Color(0xFF0F172A), child: const Icon(Icons.storefront, size: 80, color: Colors.white24)),
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context, dynamic cart) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('View Cart (${cart.totalQuantity} items)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Rs ${cart.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Icon(icon, color: color ?? Colors.black, size: 20),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}

class _ContactBar extends StatelessWidget {
  final String phone;
  final String address;
  const _ContactBar({required this.phone, required this.address});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(address, style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        IconButton(
          onPressed: () => launchUrl(Uri.parse('tel:$phone')),
          icon: const Icon(Icons.call_rounded, color: AppColors.accent),
          style: IconButton.styleFrom(backgroundColor: AppColors.accent.withOpacity(0.1)),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.map_rounded, color: AppColors.accent),
          style: IconButton.styleFrom(backgroundColor: AppColors.accent.withOpacity(0.1)),
        ),
      ],
    );
  }
}

class _ProductTile extends ConsumerWidget {
  final ProductModel product;
  const _ProductTile({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => context.push('/customer/product', extra: product),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black.withOpacity(0.03)),
        ),
        child: Row(
          children: [
            Hero(
              tag: 'product_${product.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  product.imageUrl,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(width: 90, height: 90, color: Colors.grey[200], child: const Icon(Icons.image)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Rs ${product.price}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.accent, fontSize: 16)),
                      GestureDetector(
                        onTap: () {
                          ref.read(cartProvider.notifier).addItem(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${product.name} added to cart'), duration: const Duration(seconds: 1)),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                          child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
