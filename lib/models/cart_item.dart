
import 'product.dart';

class CartItem {
  final Product product;
  final String selectedSize;
  final String selectedColor;
  final int quantity;

  CartItem({
    required this.product,
    required this.selectedSize,
    required this.selectedColor,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;
}
