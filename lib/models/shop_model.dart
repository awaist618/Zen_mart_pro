import 'package:cloud_firestore/cloud_firestore.dart';

class ShopModel {
  final String id;
  final String name;
  final String vendorId;
  final String vendorName;
  final String address;
  final String category;
  final String imageUrl;
  final double rating;
  final String status; // active, disabled
  final int activeOrders;
  final DateTime createdAt;

  ShopModel({
    required this.id,
    required this.name,
    required this.vendorId,
    required this.vendorName,
    required this.address,
    required this.category,
    required this.imageUrl,
    this.rating = 0.0,
    required this.status,
    this.activeOrders = 0,
    required this.createdAt,
  });

  factory ShopModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ShopModel(
      id: doc.id,
      name: data['name'] ?? '',
      vendorId: data['vendorId'] ?? '',
      vendorName: data['vendorName'] ?? 'Unknown Vendor',
      address: data['address'] ?? 'No Address',
      category: data['category'] ?? 'General',
      imageUrl: data['imageUrl'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'active',
      activeOrders: data['activeOrders'] ?? 0,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'vendorId': vendorId,
      'vendorName': vendorName,
      'address': address,
      'category': category,
      'imageUrl': imageUrl,
      'rating': rating,
      'status': status,
      'activeOrders': activeOrders,
      'createdAt': createdAt,
    };
  }
}
