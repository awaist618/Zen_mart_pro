import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../models/shop_model.dart';
import '../../theme/app_colors.dart';

class CategoryShopsScreen extends ConsumerStatefulWidget {
  final String category;
  const CategoryShopsScreen({super.key, required this.category});

  @override
  ConsumerState<CategoryShopsScreen> createState() => _CategoryShopsScreenState();
}

class _CategoryShopsScreenState extends ConsumerState<CategoryShopsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final shopsAsync = ref.watch(categoryShopsProvider(widget.category));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('${widget.category} Shops', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search in ${widget.category}...',
                  border: InputBorder.none,
                  icon: const Icon(Icons.search, size: 20),
                ),
              ),
            ),
          ),
        ),
      ),
      body: shopsAsync.when(
        data: (shops) {
          final filtered = shops.where((s) => s.name.toLowerCase().contains(_searchQuery)).toList();
          
          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.storefront_outlined, size: 64, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text('No shops found in ${widget.category}', style: const TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) => _ShopListTile(shop: filtered[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _ShopListTile extends StatelessWidget {
  final ShopModel shop;
  const _ShopListTile({required this.shop});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/customer/shop/${shop.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                image: shop.imageUrl.isNotEmpty 
                    ? DecorationImage(image: NetworkImage(shop.imageUrl), fit: BoxFit.cover)
                    : null,
              ),
              child: shop.imageUrl.isEmpty 
                  ? const Center(child: Icon(Icons.storefront, size: 48, color: Colors.grey))
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(shop.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(shop.address, style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.green, size: 16),
                        const SizedBox(width: 4),
                        Text(shop.rating.toString(), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
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
