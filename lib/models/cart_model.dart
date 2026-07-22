import 'product_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price * quantity;

  CartItem copyWith({ProductModel? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartModel {
  final Map<String, CartItem> items;

  CartModel({this.items = const {}});

  double get totalAmount {
    double total = 0.0;
    items.forEach((key, cartItem) {
      total += cartItem.totalPrice;
    });
    return total;
  }

  int get itemCount => items.length;

  int get totalQuantity {
    int count = 0;
    items.forEach((key, cartItem) {
      count += cartItem.quantity;
    });
    return count;
  }
}
