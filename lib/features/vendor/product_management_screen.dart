import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../models/product_model.dart';
import '../../theme/app_colors.dart';
import './widgets/vendor_bottom_nav.dart';

class ProductManagementScreen extends ConsumerStatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  ConsumerState<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends ConsumerState<ProductManagementScreen> with SingleTickerProviderStateMixin {
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
    final productsAsync = ref.watch(shopProductsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Inventory Management', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
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
                      hintText: 'Search products...',
                      border: InputBorder.none,
                      icon: Icon(Icons.search, size: 20),
                    ),
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF8B5CF6),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF8B5CF6),
                tabs: const [
                  Tab(text: 'All Products'),
                  Tab(text: 'Categories'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All Products Tab
          productsAsync.when(
            data: (products) {
              final filtered = products.where((p) => p.name.toLowerCase().contains(_searchQuery)).toList();
              
              if (filtered.isEmpty) {
                return _EmptyState(icon: Icons.inventory_2_outlined, message: 'No products found');
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _ProductManagementTile(product: filtered[index]),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
          ),
          // Categories Tab
          productsAsync.when(
            data: (products) {
              final categories = products.map((p) => p.category).toSet().toList();
              if (categories.isEmpty) {
                return _EmptyState(icon: Icons.category_outlined, message: 'No categories found');
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final count = products.where((p) => p.category == cat).length;
                  return _CategoryTile(name: cat, count: count);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/vendor/add-product'),
        backgroundColor: const Color(0xFF8B5CF6),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      bottomNavigationBar: const VendorBottomNav(currentIndex: 2),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String name;
  final int count;
  const _CategoryTile({required this.name, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.category_rounded, color: Color(0xFF8B5CF6), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('$count Products', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}

class _ProductManagementTile extends ConsumerWidget {
  final ProductModel product;
  const _ProductManagementTile({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
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
                    Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _StockBadge(label: 'Stock: ${product.stock}', color: product.stock < 5 ? Colors.red : Colors.green),
                        const SizedBox(width: 8),
                        _StockBadge(label: 'Sold: ${product.soldQuantity}', color: Colors.blue),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Rs ${product.price}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF8B5CF6))),
                  Switch.adaptive(
                    value: product.isAvailable,
                    onChanged: (v) {
                      ref.read(vendorServiceProvider).updateProduct(product.id, {'isAvailable': v});
                    },
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ActionButton(
                icon: Icons.edit_outlined,
                label: 'Edit',
                onTap: () {},
              ),
              _ActionButton(
                icon: Icons.payments_outlined,
                label: 'Price',
                onTap: () => _showUpdatePriceDialog(context, ref),
              ),
              _ActionButton(
                icon: Icons.inventory_2_outlined,
                label: 'Stock',
                onTap: () => _showUpdateStockDialog(context, ref),
              ),
              _ActionButton(
                icon: Icons.delete_outline_rounded,
                label: 'Delete',
                color: Colors.red,
                onTap: () => _showDeleteDialog(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showUpdatePriceDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: product.price.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Price'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(prefixText: 'Rs '),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newPrice = double.tryParse(controller.text);
              if (newPrice != null) {
                ref.read(vendorServiceProvider).updateProduct(product.id, {'price': newPrice});
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showUpdateStockDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: product.stock.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Stock'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(suffixText: ' Units'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newStock = int.tryParse(controller.text);
              if (newStock != null) {
                ref.read(vendorServiceProvider).updateProduct(product.id, {'stock': newStock});
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product?'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(vendorServiceProvider).deleteProduct(product.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StockBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionButton({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 20, color: color ?? Colors.black.withOpacity(0.6)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color ?? Colors.black.withOpacity(0.6))),
        ],
      ),
    );
  }
}
