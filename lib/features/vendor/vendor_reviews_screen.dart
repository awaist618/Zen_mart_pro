import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/providers.dart';
import '../../models/review_model.dart';
import '../../theme/app_colors.dart';

class VendorReviewsScreen extends ConsumerStatefulWidget {
  const VendorReviewsScreen({super.key});

  @override
  ConsumerState<VendorReviewsScreen> createState() => _VendorReviewsScreenState();
}

class _VendorReviewsScreenState extends ConsumerState<VendorReviewsScreen> {
  int? _filterRating;

  @override
  Widget build(BuildContext context) {
    final reviewsAsync = ref.watch(shopReviewsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Customer Reviews', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _filterRating == null,
                  onSelected: () => setState(() => _filterRating = null),
                ),
                ...List.generate(5, (index) {
                  final rating = 5 - index;
                  return _FilterChip(
                    label: '$rating Stars',
                    isSelected: _filterRating == rating,
                    onSelected: () => setState(() => _filterRating = rating),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
      body: reviewsAsync.when(
        data: (reviews) {
          final filtered = _filterRating == null 
              ? reviews 
              : reviews.where((r) => r.rating == _filterRating).toList();

          if (filtered.isEmpty) {
            return Center(child: Text(_filterRating == null ? 'No reviews yet.' : 'No reviews with $_filterRating stars.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) => _ReviewCard(review: filtered[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({required this.label, required this.isSelected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(),
        selectedColor: const Color(0xFF8B5CF6),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class _ReviewCard extends ConsumerWidget {
  final ReviewModel review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(review.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Row(
                children: List.generate(5, (index) => Icon(
                  Icons.star_rounded,
                  size: 18,
                  color: index < review.rating ? Colors.orange : Colors.grey[300],
                )),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Order: #${review.orderId.substring(0, 8).toUpperCase()}',
            style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          FutureBuilder(
            future: ref.read(vendorServiceProvider).getOrder(review.orderId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text('Loading products...', style: TextStyle(fontSize: 12, color: Colors.grey));
              }
              final order = snapshot.data;
              if (order == null || order.items.isEmpty) {
                return const SizedBox.shrink();
              }
              final productNames = order.items.map((item) => item['name'] ?? 'Product').join(', ');
              return Text(
                'Products: $productNames',
                style: const TextStyle(fontSize: 12, color: Color(0xFF6366F1), fontWeight: FontWeight.w500),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            review.review,
            style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 12),
          Text(
            DateFormat('MMM dd, yyyy').format(review.createdAt),
            style: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 11),
          ),
          if (review.reply != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your Reply:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF8B5CF6))),
                  const SizedBox(height: 4),
                  Text(review.reply!, style: const TextStyle(fontSize: 13, height: 1.4)),
                ],
              ),
            ),
          ],
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ReviewActionButton(
                icon: Icons.reply_rounded,
                label: review.reply == null ? 'Reply' : 'Edit Reply',
                onTap: () => _showReplyDialog(context, ref),
              ),
              _ReviewActionButton(
                icon: Icons.report_gmailerrorred_rounded,
                label: 'Report',
                color: Colors.redAccent,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showReplyDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: review.reply);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reply to Review'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Type your response...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final user = ref.read(userModelProvider).asData?.value;
              if (user?.shopId != null) {
                ref.read(vendorServiceProvider).replyToReview(user!.shopId!, review.id, controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Send Reply'),
          ),
        ],
      ),
    );
  }
}

class _ReviewActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ReviewActionButton({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color ?? Colors.black.withOpacity(0.6)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color ?? Colors.black.withOpacity(0.6))),
        ],
      ),
    );
  }
}
