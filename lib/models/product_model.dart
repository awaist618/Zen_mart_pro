import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String vendorId;
  final String shopId;
  final String name;
  final String description;
  final double price;
  final double discount;
  final int stock;
  final String unit; // kg, liter, pcs, etc.
  final String imageUrl;
  final String category;
  final bool isAvailable;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.vendorId,
    required this.shopId,
    required this.name,
    required this.description,
    required this.price,
    this.discount = 0.0,
    required this.stock,
    required this.unit,
    required this.imageUrl,
    required this.category,
    this.isAvailable = true,
    required this.createdAt,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      vendorId: data['vendorId'] ?? '',
      shopId: data['shopId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      discount: (data['discount'] ?? 0.0).toDouble(),
      stock: data['stock'] ?? 0,
      unit: data['unit'] ?? 'pcs',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? 'General',
      isAvailable: data['isAvailable'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vendorId': vendorId,
      'shopId': shopId,
      'name': name,
      'description': description,
      'price': price,
      'discount': discount,
      'stock': stock,
      'unit': unit,
      'imageUrl': imageUrl,
      'category': category,
      'isAvailable': isAvailable,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
