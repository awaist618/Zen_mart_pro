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
  double _maxDistance = 10.0; // km
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/customer');
            }
          },
        ),
        title: Container(
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Search products, shops, brands...',
              hintStyle: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _openFilters,
            icon: Icon(
              Icons.tune_rounded,
              color: (_selectedCategory != null || _minRating > 0 || _freeDelivery || _onlyOffers || _onlyOpen) ? AppColors.accent : Colors.black,
            ),
          ),
        ],
      ),
      body: _query.isEmpty 
          ? const _SearchPlaceholder() 
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories Section
                  ref.watch(allCategoriesProvider).when(
                    data: (cats) {
                      final matchingCats = cats.where((c) => c.toLowerCase().contains(_query.toLowerCase())).toList();
                      if (matchingCats.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Categories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: matchingCats.map((cat) => ActionChip(
                              label: Text(cat),
                              onPressed: () => setState(() {
                                _selectedCategory = cat;
                                _searchController.text = cat;
                                _query = cat;
                              }),
                            )).toList(),
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (e, s) => const SizedBox.shrink(),
                  ),

                  // Shops Section
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
                          const Text('Shops', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 12),
                          ...filteredShops.map((shop) => _ShopSearchResultTile(shop: shop)),
                          const SizedBox(height: 24),
                        ],
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (e, s) => const SizedBox.shrink(),
                  ),

                  // Products Section
                  productsAsync.when(
                    data: (products) {
                      var filtered = products.where((p) {
                        final matchesCat = _selectedCategory == null || p.category == _selectedCategory;
                        final matchesPrice = p.price >= _priceRange.start && p.price <= _priceRange.end;
                        final matchesOffers = !_onlyOffers || p.discount > 0;
                        return matchesCat && matchesPrice && matchesOffers;
                      }).toList();

                      if (filtered.isEmpty) {
                        return const Center(child: Text('No products found matching filters.'));
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Products', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 12),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) => _ProductSearchResultTile(product: filtered[index]),
                          ),
                        ],
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Text('Error: $e'),
                  ),
                ],
              ),
            ),
    );
  }
}

class _SearchPlaceholder extends StatelessWidget {
  const _SearchPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_rounded, size: 80, color: Colors.grey.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text('Search for your favorite\nfood, grocery or stores', 
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _ShopSearchResultTile extends StatelessWidget {
  final ShopModel shop;
  const _ShopSearchResultTile({required this.shop});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => context.push('/customer/shop/${shop.id}'),
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: shop.imageUrl.isNotEmpty ? NetworkImage(shop.imageUrl) : null,
        child: shop.imageUrl.isEmpty ? const Icon(Icons.storefront) : null,
      ),
      title: Text(shop.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Row(
        children: [
          Text(shop.category, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 8),
          const Icon(Icons.star_rounded, color: Colors.orange, size: 14),
          Text(' ${shop.rating}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}

class _ProductSearchResultTile extends StatelessWidget {
  final ProductModel product;
  const _ProductSearchResultTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to product detail
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.image)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('${product.brand} • ${product.category}', style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 12)),
                  if (product.discount > 0)
                    Text('Rs ${product.price} OFF', style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Rs ${product.price}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent)),
                if (product.discount > 0)
                  Text('Rs ${product.price + product.discount}', style: TextStyle(color: Colors.grey, fontSize: 10, decoration: TextDecoration.lineThrough)),
              ],
            ),
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

  const _FilterBottomSheet({
    this.initialCategory,
    required this.initialPriceRange,
    required this.initialRating,
    required this.initialMaxDistance,
    required this.initialFreeDelivery,
    required this.initialOnlyOffers,
    required this.initialOnlyOpen,
    required this.onApply,
  });

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
    final categoriesAsync = ref.watch(allCategoriesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filters', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          
          const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          categoriesAsync.when(
            data: (cats) => Wrap(
              spacing: 8,
              children: cats.map((cat) => ChoiceChip(
                label: Text(cat),
                selected: _selectedCategory == cat,
                onSelected: (selected) => setState(() => _selectedCategory = selected ? cat : null),
                selectedColor: AppColors.accent,
                labelStyle: TextStyle(color: _selectedCategory == cat ? Colors.white : Colors.black),
              )).toList(),
            ),
            loading: () => const CircularProgressIndicator(),
            error: (e, s) => const Text('Error loading categories'),
          ),
          
          const SizedBox(height: 24),
          const Text('Price Range', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 5000,
            divisions: 20,
            activeColor: AppColors.accent,
            labels: RangeLabels('Rs ${_priceRange.start.round()}', 'Rs ${_priceRange.end.round()}'),
            onChanged: (values) => setState(() => _priceRange = values),
          ),
          
          const SizedBox(height: 24),
          const Text('Distance (within km)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Slider(
            value: _maxDistance,
            min: 1,
            max: 50,
            divisions: 49,
            activeColor: AppColors.accent,
            label: '${_maxDistance.round()} km',
            onChanged: (v) => setState(() => _maxDistance = v),
          ),

          const SizedBox(height: 24),
          const Text('Quick Filters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Free Delivery'),
                selected: _freeDelivery,
                onSelected: (v) => setState(() => _freeDelivery = v),
                selectedColor: AppColors.accent.withOpacity(0.2),
              ),
              FilterChip(
                label: const Text('Offers'),
                selected: _onlyOffers,
                onSelected: (v) => setState(() => _onlyOffers = v),
                selectedColor: AppColors.accent.withOpacity(0.2),
              ),
              FilterChip(
                label: const Text('Open Now'),
                selected: _onlyOpen,
                onSelected: (v) => setState(() => _onlyOpen = v),
                selectedColor: AppColors.accent.withOpacity(0.2),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          const Text('Minimum Rating', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(5, (index) {
                final r = index + 1.0;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('$r+ ★'),
                    selected: _minRating == r,
                    onSelected: (selected) => setState(() => _minRating = selected ? r : 0),
                    selectedColor: Colors.orange,
                    labelStyle: TextStyle(color: _minRating == r ? Colors.white : Colors.black),
                  ),
                );
              }),
            ),
          ),
          
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_selectedCategory, _priceRange, _minRating, _maxDistance, _freeDelivery, _onlyOffers, _onlyOpen);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
