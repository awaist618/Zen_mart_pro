import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/providers.dart';
import '../../models/review_model.dart';
import '../../theme/app_colors.dart';

class RiderReviewsScreen extends ConsumerWidget {
  const RiderReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Reusing shop reviews logic for rider reviews stream (placeholder for rider-specific review model)
    final reviewsAsync = ref.watch(shopReviewsProvider); 

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Customer Ratings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: reviewsAsync.when(
        data: (reviews) {
          if (reviews.isEmpty) {
            return const Center(child: Text('No ratings received yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: reviews.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) => _RatingCard(review: reviews[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _RatingCard extends StatelessWidget {
  final ReviewModel review;
  const _RatingCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
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
                  color: index < review.rating ? Colors.orange : Colors.grey[200],
                )),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.review,
            style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Delivered on ${DateFormat('MMM dd, yyyy').format(review.createdAt)}',
            style: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 11),
          ),
        ],
      ),
    );
  }
}
