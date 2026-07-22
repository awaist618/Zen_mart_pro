import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../core/utils.dart';
import '../../models/product_model.dart';
import '../../models/shop_model.dart';
import '../../theme/app_colors.dart';

class CustomerSearchScreen extends ConsumerStatefulWidget {
  const CustomerSearchScreen({super.key});

  @override
  ConsumerState<CustomerSearchScreen> createState() => _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends ConsumerState<CustomerSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  // Filter States
  String? _selectedCategory;
  RangeValues _priceRange = const RangeValues(0, 5000);
  double _minRating = 0;
  double _maxDistance = 10.0; 
  bool _freeDelivery = false;
  bool _onlyOffers = false;
  bool _onlyOpen = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(
        initialCategory: _selectedCategory,
        initialPriceRange: _priceRange,
        initialRating: _minRating,
        initialMaxDistance: _maxDistance,
        initialFreeDelivery: _freeDelivery,
        initialOnlyOffers: _onlyOffers,
        initialOnlyOpen: _onlyOpen,
        onApply: (cat, price, rating, dist, free, offers, open) {
          setState(() {
            _selectedCategory = cat;
            _priceRange = price;
            _minRating = rating;
            _maxDistance = dist;
            _freeDelivery = free;
            _onlyOffers = offers;
            _onlyOpen = open;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(searchProductsProvider(_query));
    final shopsAsync = ref.watch(searchShopsProvider(_query));
    final userAddress = ref.watch(defaultAddressProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/customer');
            }
          },
        ),
        title: Container(
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: (v) => setState(() => _query = v),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Search foods or stores...',
              hintStyle: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 14, fontWeight: FontWeight.w500),
              prefixIcon: const Icon(Icons.search_rounded, size: 22, color: AppColors.accent),
              suffixIcon: _query.isNotEmpty ? IconButton(icon: const Icon(Icons.close_rounded, size: 18), onPressed: () {
                _searchController.clear();
                setState(() => _query = '');
              }) : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: _openFilters,
              icon: Icon(
                Icons.tune_rounded,
                color: (_selectedCategory != null || _minRating > 0 || _freeDelivery || _onlyOffers || _onlyOpen) ? AppColors.accent : const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
      body: _query.isEmpty 
          ? const _SearchPlaceholder() 
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shops Result
                  shopsAsync.when(
                    data: (shops) {
                      final filteredShops = shops.where((s) {
                        final matchesCat = _selectedCategory == null || s.category == _selectedCategory;
                        final matchesRating = s.rating >= _minRating;
                        final matchesFree = !_freeDelivery || s.hasFreeDelivery;
                        final matchesOpen = !_onlyOpen || s.isOpen;
                        final distance = MapUtils.calculateDistance(userAddress?.location, s.location);
                        final matchesDist = distance <= _maxDistance;
                        return matchesCat && matchesRating && matchesFree && matchesOpen && matchesDist;
                      }).toList();

                      if (filteredShops.isEmpty) return const SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _ResultHeader(title: 'Available Stores'),
                          const SizedBox(height: 16),
                          ...filteredShops.map((shop) => _ShopSearchCard(shop: shop)),
                          const SizedBox(height: 32),
                        ],
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (e, s) => const SizedBox.shrink(),
                  ),

                  // Products Result
                  productsAsync.when(
                    data: (products) {
                      var filtered = products.where((p) {
                        final matchesCat = _selectedCategory == null || p.category == _selectedCategory;
                        final matchesPrice = p.price >= _priceRange.start && p.price <= _priceRange.end;
                        final matchesOffers = !_onlyOffers || p.discount > 0;
                        return matchesCat && matchesPrice && matchesOffers;
                      }).toList();

                      if (filtered.isEmpty && !shopsAsync.hasValue) {
                        return const _NoResultsFound();
                      }
                      if (filtered.isEmpty) return const SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _ResultHeader(title: 'Top Matches'),
                          const SizedBox(height: 16),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 16),
                            itemBuilder: (context, index) => _ProductSearchCard(product: filtered[index]),
                          ),
                        ],
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    error: (e, s) => Text('Error: $e'),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ResultHeader extends StatelessWidget {
  final String title;
  const _ResultHeader({required this.title});
  @override
  Widget build(BuildContext context) => Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)));
}

class _SearchPlaceholder extends StatelessWidget {
  const _SearchPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.05), shape: BoxShape.circle),
            child: Icon(Icons.search_rounded, size: 64, color: AppColors.accent.withOpacity(0.3)),
          ),
          const SizedBox(height: 24),
          const Text('Search Zen Mart Pro', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
          const SizedBox(height: 8),
          const Text('Find foods, stores and daily essentials\naround your location.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500, height: 1.4)),
        ],
      ),
    );
  }
}

class _NoResultsFound extends StatelessWidget {
  const _NoResultsFound();
  @override
  Widget build(BuildContext context) => Center(child: Column(children: [const SizedBox(height: 40), Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]), const SizedBox(height: 16), const Text('No results found matching your search.', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600))]));
}

class _ShopSearchCard extends StatelessWidget {
  final ShopModel shop;
  const _ShopSearchCard({required this.shop});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/customer/shop/${shop.id}'),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
          border: Border.all(color: Colors.grey.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(shop.imageUrl, width: 64, height: 64, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(width: 64, height: 64, color: Colors.grey[100], child: const Icon(Icons.storefront, color: Colors.grey))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(shop.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1E293B))),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(shop.category, style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      const Icon(Icons.star_rounded, color: Colors.orange, size: 14),
                      Text(' ${shop.rating}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _ProductSearchCard extends StatelessWidget {
  final ProductModel product;
  const _ProductSearchCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/customer/product', extra: product),
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 8)),
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                product.imageUrl, 
                width: 80, 
                height: 80, 
                fit: BoxFit.cover, 
                errorBuilder: (c, e, s) => Container(width: 80, height: 80, color: const Color(0xFFF1F5F9), child: const Icon(Icons.image, color: Colors.grey))
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name, 
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A), letterSpacing: -0.2),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.brand} • ${product.category}', 
                    style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.w700)
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Rs ${product.price.toStringAsFixed(0)}', 
                        style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.accent, fontSize: 16)
                      ),
                      if (product.discount > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          'Rs ${product.price + product.discount}', 
                          style: TextStyle(color: Colors.grey[400], fontSize: 11, decoration: TextDecoration.lineThrough, fontWeight: FontWeight.w600)
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (product.discount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Text('OFFER', style: TextStyle(color: Color(0xFF10B981), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _FilterBottomSheet extends ConsumerStatefulWidget {
  final String? initialCategory;
  final RangeValues initialPriceRange;
  final double initialRating;
  final double initialMaxDistance;
  final bool initialFreeDelivery;
  final bool initialOnlyOffers;
  final bool initialOnlyOpen;
  final Function(String?, RangeValues, double, double, bool, bool, bool) onApply;

  const _FilterBottomSheet({this.initialCategory, required this.initialPriceRange, required this.initialRating, required this.initialMaxDistance, required this.initialFreeDelivery, required this.initialOnlyOffers, required this.initialOnlyOpen, required this.onApply});
  @override
  ConsumerState<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<_FilterBottomSheet> {
  String? _selectedCategory;
  RangeValues _priceRange = const RangeValues(0, 5000);
  double _minRating = 0;
  double _maxDistance = 10.0;
  bool _freeDelivery = false;
  bool _onlyOffers = false;
  bool _onlyOpen = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _priceRange = widget.initialPriceRange;
    _minRating = widget.initialRating;
    _maxDistance = widget.initialMaxDistance;
    _freeDelivery = widget.initialFreeDelivery;
    _onlyOffers = widget.initialOnlyOffers;
    _onlyOpen = widget.initialOnlyOpen;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(36))),
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 24),
          const Text('Search Filters', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          const SizedBox(height: 32),
          const Text('Price Range', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          RangeSlider(values: _priceRange, min: 0, max: 5000, divisions: 25, activeColor: AppColors.accent, inactiveColor: const Color(0xFFF1F5F9), labels: RangeLabels('Rs ${_priceRange.start.round()}', 'Rs ${_priceRange.end.round()}'), onChanged: (v) => setState(() => _priceRange = v)),
          const SizedBox(height: 24),
          const Text('Quick Filters', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 12),
          Wrap(spacing: 10, children: [
            _QuickChip(label: 'Free Delivery', selected: _freeDelivery, onToggle: (v) => setState(() => _freeDelivery = v)),
            _QuickChip(label: 'On Offer', selected: _onlyOffers, onToggle: (v) => setState(() => _onlyOffers = v)),
            _QuickChip(label: 'Open Stores', selected: _onlyOpen, onToggle: (v) => setState(() => _onlyOpen = v)),
          ]),
          const SizedBox(height: 24),
          const Text('Customer Rating', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(4, (i) {
                final r = (i + 2).toDouble();
                final isSel = _minRating == r;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    onTap: () => setState(() => _minRating = isSel ? 0 : r),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSel ? Colors.orange : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSel ? Colors.orange : Colors.grey.withOpacity(0.1)),
                      ),
                      child: Text(
                        '$r+ ★',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: isSel ? Colors.white : Colors.black87),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () { widget.onApply(_selectedCategory, _priceRange, _minRating, _maxDistance, _freeDelivery, _onlyOffers, _onlyOpen); Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 0), child: const Text('Apply Selection', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)))),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Function(bool) onToggle;
  const _QuickChip({required this.label, required this.selected, required this.onToggle});
  @override
  Widget build(BuildContext context) => FilterChip(label: Text(label), selected: selected, onSelected: onToggle, selectedColor: AppColors.accent.withOpacity(0.1), checkmarkColor: AppColors.accent, labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: selected ? AppColors.accent : Colors.black87), backgroundColor: const Color(0xFFF8FAFC), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: selected ? AppColors.accent : Colors.grey.withOpacity(0.1))));
}
