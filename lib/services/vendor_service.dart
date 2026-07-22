import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class VendorService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Add a new product to Firestore
  Future<void> addProduct(ProductModel product) async {
    await _db.collection('products').add(product.toMap());
  }

  /// Get stream of products for a specific shop
  Stream<List<ProductModel>> getShopProducts(String shopId) {
    return _db
        .collection('products')
        .where('shopId', isEqualTo: shopId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList());
  }

  /// Update an existing product
  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    await _db.collection('products').doc(productId).update(data);
  }

  /// Delete a product
  Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }
}
